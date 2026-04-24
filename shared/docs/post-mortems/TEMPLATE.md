# Post-Mortem: [Incident Name / Brief Description]

**Date of Incident:** YYYY-MM-DD
**Authors:** [Names]
**Status:** [Draft / Under Review / Published]
**Impact Severity:** [P0 / P1 / P2]

## 1. Summary
*Provide a high-level summary of what happened, the impact, and how it was resolved in 2-3 sentences.*

## 2. Impact
*Quantify the impact on users, revenue, and systems.*
- **User Impact:** [e.g., 50 field agents unable to sync for 2 hours]
- **Data Loss/Corruption:** [Yes/No - detail if yes]
- **Duration of Outage:** [X hours, Y minutes]

## 3. Timeline
*Provide a detailed, chronological timeline of events. Use UTC.*
- **YYYY-MM-DD HH:MM (UTC) -** First alert fired in PagerDuty.
- **YYYY-MM-DD HH:MM (UTC) -** On-call engineer acknowledged.
- **YYYY-MM-DD HH:MM (UTC) -** Mitigation applied.
- **YYYY-MM-DD HH:MM (UTC) -** Full recovery confirmed.

## 4. Root Cause Analysis
*Explain exactly why this happened. Use the "5 Whys" methodology if helpful.*
- **Why did the outage happen?** [Because X]
- **Why did X happen?** [Because Y]

## 5. What Went Well
*List things that worked as intended during the response.*
- [e.g., Automated alerts fired immediately.]
- [e.g., Runbook step 2 worked perfectly to restore database state.]

## 6. What Went Wrong
*List things that failed, were confusing, or delayed the response.*
- [e.g., Took 20 minutes to find the correct Supabase project.]
- [e.g., Dashboard logs were delayed by 5 minutes.]

## 7. Action Items
*List specific, actionable tasks to prevent recurrence, assigned to an owner with a due date. Blameless language only.*

| Action Item | Owner | Priority | Ticket/Issue | Due Date |
| :--- | :--- | :--- | :--- | :--- |
| Update runbook with correct project ID | @name | High | #123 | YYYY-MM-DD |
| Increase connection pool size to 100 | @name | Critical | #124 | YYYY-MM-DD |
| Add a dashboard alert for memory usage > 80% | @name | Medium | #125 | YYYY-MM-DD |

## 8. Lessons Learned
*General takeaways for the engineering team.*
- [e.g., We need to test database failover more frequently.]
