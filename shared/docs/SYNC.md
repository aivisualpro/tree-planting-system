# Sync Engine Design

This document outlines the architecture, pseudocode, and edge-case handling for the offline-first Synchronization Engine.

## Opinionated Design Choices & Tradeoffs

1. **Pull vs Push Priority:**
   - *Assumption Pushback*: A common mistake is pushing local outbox changes immediately upon network reconnect.
   - *Recommendation*: **Always PULL before PUSH.** Pulling deltas first updates local records to the latest server `version`. If you push first, you drastically increase the chance of a version conflict because the local app hasn't seen the server's changes yet.
2. **Batching vs Individual Requests:**
   - *Tradeoff*: Sending 100 outbox items in a single HTTP batch vs 100 individual requests.
   - *Recommendation*: Use **Micro-Batches (N=5) or Individual Requests**. In remote field conditions with 2G/3G, connections drop mid-request. If a batch of 50 fails on item 49, you must retry the whole batch. Committing one-by-one ensures steady forward progress even on terrible networks.

---

## 1. Connectivity Listener & Triggers

**Responsibility:** Monitor OS network state and wake the sync engine.

```pseudocode
class ConnectivityListener {
  onStart() {
    listenToOSNetworkState((isOnline) => {
      if (isOnline) {
        WorkManager.enqueue(SyncTask)
      }
    })
  }
}

class ManualTrigger {
  onUserPressSyncButton() {
    UI.showLoading()
    WorkManager.cancelAllPendingSyncs() // prevent race conditions
    SyncEngine.runFullCycle()
  }
}
```

---

## 2. The Core Sync Cycle

**Responsibility:** Orchestrate the Pull, Push, and Media phases.

```pseudocode
class SyncEngine {
  async runFullCycle() {
    try {
      if (!Network.isOnline) return "aborted_offline"
      
      const token = await Auth.getValidToken()
      if (!token) throw TokenExpiredError()

      // Phase 1: Pull changes from server
      await DeltaPuller.execute()

      // Phase 2: Push local JSON data
      await OutboxProcessor.execute()

      // Phase 3: Push binary media
      await MediaUploader.execute()

      return "success"
    } catch (error) {
      RetryScheduler.handleFailure(error)
      throw error
    }
  }
}
```

---

## 3. Delta Pull (Server -> Client)

**Responsibility:** Fetch only rows modified since the last successful pull.

```pseudocode
class DeltaPuller {
  async execute() {
    const lastSyncTime = await LocalPrefs.get("last_successful_pull_timestamp")
    
    // Pagination handles >10,000 users / huge data dumps gracefully
    let hasMore = true
    let page = 0
    
    while(hasMore) {
      const serverRecords = await Supabase.rpc('get_delta_visits', { 
        last_sync: lastSyncTime,
        limit: 100,
        offset: page * 100
      })
      
      if (serverRecords.isEmpty) {
        hasMore = false
        break
      }

      await LocalDB.transaction(() => {
        for (record of serverRecords) {
          const localRecord = LocalDB.get(record.client_uuid)
          
          if (!localRecord || record.version > localRecord.version) {
            // Server wins or is new
            LocalDB.upsert(record)
          } else if (record.deleted_at != null) {
            // Tombstone processing
            LocalDB.hardDelete(record.client_uuid) 
          }
        }
      })
      page++
    }

    await LocalPrefs.set("last_successful_pull_timestamp", currentTime)
  }
}
```

---

## 4. Outbox Processor (Client -> Server)

**Responsibility:** Push pending local data to the server sequentially.

```pseudocode
class OutboxProcessor {
  async execute() {
    const pendingItems = await LocalDB.query("SELECT * FROM outbox WHERE status = 'pending'")
    
    for (item of pendingItems) {
      await LocalDB.update(item.id, { status: 'syncing' })
      
      try {
        // Upsert uses ON CONFLICT (client_uuid) DO UPDATE ...
        // and WHERE server.version <= client.version
        const serverResult = await Supabase.table(item.table).upsert(item.payload)
        
        await LocalDB.transaction(() => {
          LocalDB.update(item.table, { version: serverResult.version })
          LocalDB.deleteOutbox(item.id)
        })
        
      } catch (error) {
        if (error.isVersionConflict) {
          await ConflictLogger.log(item, error)
          await LocalDB.update(item.id, { status: 'failed', error: 'Version Conflict' })
        } else {
          // Revert to pending for the RetryScheduler
          await LocalDB.update(item.id, { status: 'pending' })
          throw error
        }
      }
    }
  }
}
```

---

## 5. Media Uploader

**Responsibility:** Upload large binary files (photos, signatures) using TUS resumable uploads.

```pseudocode
class MediaUploader {
  async execute() {
    const pendingMedia = await LocalDB.query("SELECT * FROM visit_media WHERE upload_status = 'pending'")
    
    for (media of pendingMedia) {
      if (!FileSystem.exists(media.local_path)) {
         await ConflictLogger.log(media, "File missing from disk")
         await LocalDB.update(media.id, { upload_status: 'failed' })
         continue
      }

      try {
        await LocalDB.update(media.id, { upload_status: 'uploading' })
        
        // TUS handles chunking and resumes naturally
        const storagePath = await Supabase.Storage.uploadResumable(
           path: `visits/${media.sha256}`,
           file: media.local_path
        )
        
        // Update the media record with the final cloud path
        await Supabase.table('visit_media').update({ 
           id: media.id, 
           storage_path: storagePath, 
           upload_status: 'completed' 
        })
        
        await LocalDB.update(media.id, { upload_status: 'completed', storage_path: storagePath })

      } catch (error) {
        await LocalDB.update(media.id, { upload_status: 'pending' })
        throw error
      }
    }
  }
}
```

---

## 6. Retry Scheduler

**Responsibility:** Implement exponential backoff for failed sync attempts.

```pseudocode
class RetryScheduler {
  handleFailure(error) {
    let attempt = LocalPrefs.increment("current_sync_attempt")
    
    if (attempt > 10) {
      UI.showPersistentError("Sync permanently failed. Please contact IT.")
      LocalPrefs.set("current_sync_attempt", 0)
      return
    }

    // Exponential backoff: 30s, 60s, 2m, 4m, 8m, 16m, 32m, 1h
    let delayMinutes = min(60, 0.5 * (2 ^ (attempt - 1)))
    
    WorkManager.enqueue(SyncTask, {
       initialDelay: delayMinutes,
       constraints: { networkType: CONNECTED }
    })
  }
}
```

---

## 7. Edge Cases Handled

| Edge Case | How It's Handled |
| :--- | :--- |
| **App killed mid-sync** | The Outbox relies on transactional SQL. An item marked `syncing` will be reset to `pending` on app boot if no WorkManager task is active. No data corruption. |
| **Token expired** | The `SyncEngine.runFullCycle()` explicitly checks/refreshes the token before starting. Supabase SDK handles auto-refresh; if it completely expires, sync throws an Auth error, triggers the UI to show a login prompt, and aborts sync. |
| **Media file deleted locally before sync** | `MediaUploader` checks `FileSystem.exists()`. If missing, it fails the row, logs it to `sync_log`, but allows the JSON data (the Visit) to remain synced. |
| **Clock skew** | Delta pulls use the **Server's Timestamp**, not the client's. The client asks the server for "records updated since X", where X was the timestamp *returned by the server* on the last pull. |
| **Duplicate submissions** | `upsert` in Supabase is strictly tied to `client_uuid`. Even if a network timeout causes the client to send the exact same row twice, the database uniqueness constraint ensures it safely overwrites itself without duplication. |
| **Partial batch failure** | Because we process items sequentially inside a `for` loop (not an HTTP bulk array), an error on item 4 means items 1-3 were successfully committed. The retry will pick up starting at item 4. |
