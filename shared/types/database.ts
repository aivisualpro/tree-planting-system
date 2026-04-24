export type Json =
  | string
  | number
  | boolean
  | null
  | { [key: string]: Json | undefined }
  | Json[]

export type Database = {
  graphql_public: {
    Tables: {
      [_ in never]: never
    }
    Views: {
      [_ in never]: never
    }
    Functions: {
      graphql: {
        Args: {
          extensions?: Json
          operationName?: string
          query?: string
          variables?: Json
        }
        Returns: Json
      }
    }
    Enums: {
      [_ in never]: never
    }
    CompositeTypes: {
      [_ in never]: never
    }
  }
  public: {
    Tables: {
      activities: {
        Row: {
          core_area_id: string
          designated_to: string[] | null
          id: string
          name_en: string
          visit_requirements: Json | null
        }
        Insert: {
          core_area_id: string
          designated_to?: string[] | null
          id?: string
          name_en: string
          visit_requirements?: Json | null
        }
        Update: {
          core_area_id?: string
          designated_to?: string[] | null
          id?: string
          name_en?: string
          visit_requirements?: Json | null
        }
        Relationships: [
          {
            foreignKeyName: "activities_core_area_id_fkey"
            columns: ["core_area_id"]
            isOneToOne: false
            referencedRelation: "core_areas"
            referencedColumns: ["id"]
          },
        ]
      }
      activity_units: {
        Row: {
          activity_id: string
          country_id: string | null
          id: string
          unit_id: string
        }
        Insert: {
          activity_id: string
          country_id?: string | null
          id?: string
          unit_id: string
        }
        Update: {
          activity_id?: string
          country_id?: string | null
          id?: string
          unit_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "activity_units_activity_id_fkey"
            columns: ["activity_id"]
            isOneToOne: false
            referencedRelation: "activities"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "activity_units_country_id_fkey"
            columns: ["country_id"]
            isOneToOne: false
            referencedRelation: "countries"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "activity_units_unit_id_fkey"
            columns: ["unit_id"]
            isOneToOne: false
            referencedRelation: "units"
            referencedColumns: ["id"]
          },
        ]
      }
      audit_log: {
        Row: {
          actor_id: string | null
          id: string
          new_row: Json | null
          occurred_at: string
          old_row: Json | null
          operation: Database["public"]["Enums"]["audit_operation"]
          row_id: string
          table_name: string
        }
        Insert: {
          actor_id?: string | null
          id?: string
          new_row?: Json | null
          occurred_at?: string
          old_row?: Json | null
          operation: Database["public"]["Enums"]["audit_operation"]
          row_id: string
          table_name: string
        }
        Update: {
          actor_id?: string | null
          id?: string
          new_row?: Json | null
          occurred_at?: string
          old_row?: Json | null
          operation?: Database["public"]["Enums"]["audit_operation"]
          row_id?: string
          table_name?: string
        }
        Relationships: [
          {
            foreignKeyName: "audit_log_actor_id_fkey"
            columns: ["actor_id"]
            isOneToOne: false
            referencedRelation: "profiles"
            referencedColumns: ["id"]
          },
        ]
      }
      churches: {
        Row: {
          community_id: string | null
          country_id: string
          created_at: string
          created_by: string | null
          deleted_at: string | null
          id: string
          name_en: string
          region: string | null
          subwatershed_id: string | null
          updated_at: string
          updated_by: string | null
          version: number
        }
        Insert: {
          community_id?: string | null
          country_id: string
          created_at?: string
          created_by?: string | null
          deleted_at?: string | null
          id?: string
          name_en: string
          region?: string | null
          subwatershed_id?: string | null
          updated_at?: string
          updated_by?: string | null
          version?: number
        }
        Update: {
          community_id?: string | null
          country_id?: string
          created_at?: string
          created_by?: string | null
          deleted_at?: string | null
          id?: string
          name_en?: string
          region?: string | null
          subwatershed_id?: string | null
          updated_at?: string
          updated_by?: string | null
          version?: number
        }
        Relationships: [
          {
            foreignKeyName: "churches_community_id_fkey"
            columns: ["community_id"]
            isOneToOne: false
            referencedRelation: "communities"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "churches_country_id_fkey"
            columns: ["country_id"]
            isOneToOne: false
            referencedRelation: "countries"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "churches_created_by_fkey"
            columns: ["created_by"]
            isOneToOne: false
            referencedRelation: "profiles"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "churches_subwatershed_id_fkey"
            columns: ["subwatershed_id"]
            isOneToOne: false
            referencedRelation: "subwatersheds"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "churches_updated_by_fkey"
            columns: ["updated_by"]
            isOneToOne: false
            referencedRelation: "profiles"
            referencedColumns: ["id"]
          },
        ]
      }
      communities: {
        Row: {
          created_at: string
          created_by: string | null
          deleted_at: string | null
          id: string
          latitude: number | null
          longitude: number | null
          name_en: string
          subwatershed_id: string
          updated_at: string
          updated_by: string | null
          version: number
          year: number | null
        }
        Insert: {
          created_at?: string
          created_by?: string | null
          deleted_at?: string | null
          id?: string
          latitude?: number | null
          longitude?: number | null
          name_en: string
          subwatershed_id: string
          updated_at?: string
          updated_by?: string | null
          version?: number
          year?: number | null
        }
        Update: {
          created_at?: string
          created_by?: string | null
          deleted_at?: string | null
          id?: string
          latitude?: number | null
          longitude?: number | null
          name_en?: string
          subwatershed_id?: string
          updated_at?: string
          updated_by?: string | null
          version?: number
          year?: number | null
        }
        Relationships: [
          {
            foreignKeyName: "communities_created_by_fkey"
            columns: ["created_by"]
            isOneToOne: false
            referencedRelation: "profiles"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "communities_subwatershed_id_fkey"
            columns: ["subwatershed_id"]
            isOneToOne: false
            referencedRelation: "subwatersheds"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "communities_updated_by_fkey"
            columns: ["updated_by"]
            isOneToOne: false
            referencedRelation: "profiles"
            referencedColumns: ["id"]
          },
        ]
      }
      core_areas: {
        Row: {
          code: string
          id: string
          name_en: string
        }
        Insert: {
          code: string
          id?: string
          name_en: string
        }
        Update: {
          code?: string
          id?: string
          name_en?: string
        }
        Relationships: []
      }
      countries: {
        Row: {
          code: string
          created_at: string
          id: string
          latitude: number | null
          longitude: number | null
          name_en: string
          updated_at: string
        }
        Insert: {
          code: string
          created_at?: string
          id?: string
          latitude?: number | null
          longitude?: number | null
          name_en: string
          updated_at?: string
        }
        Update: {
          code?: string
          created_at?: string
          id?: string
          latitude?: number | null
          longitude?: number | null
          name_en?: string
          updated_at?: string
        }
        Relationships: []
      }
      groups: {
        Row: {
          community_id: string
          created_at: string
          created_by: string | null
          deleted_at: string | null
          id: string
          name_en: string
          updated_at: string
          updated_by: string | null
          version: number
        }
        Insert: {
          community_id: string
          created_at?: string
          created_by?: string | null
          deleted_at?: string | null
          id?: string
          name_en: string
          updated_at?: string
          updated_by?: string | null
          version?: number
        }
        Update: {
          community_id?: string
          created_at?: string
          created_by?: string | null
          deleted_at?: string | null
          id?: string
          name_en?: string
          updated_at?: string
          updated_by?: string | null
          version?: number
        }
        Relationships: [
          {
            foreignKeyName: "groups_community_id_fkey"
            columns: ["community_id"]
            isOneToOne: false
            referencedRelation: "communities"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "groups_created_by_fkey"
            columns: ["created_by"]
            isOneToOne: false
            referencedRelation: "profiles"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "groups_updated_by_fkey"
            columns: ["updated_by"]
            isOneToOne: false
            referencedRelation: "profiles"
            referencedColumns: ["id"]
          },
        ]
      }
      profiles: {
        Row: {
          assigned_countries: string[] | null
          created_at: string
          id: string
          language_code: string
          passcode_hash: string | null
          primary_country_id: string | null
          role: Database["public"]["Enums"]["user_role"]
          updated_at: string
          view_all_visits: boolean | null
          whatsapp: string | null
        }
        Insert: {
          assigned_countries?: string[] | null
          created_at?: string
          id: string
          language_code?: string
          passcode_hash?: string | null
          primary_country_id?: string | null
          role?: Database["public"]["Enums"]["user_role"]
          updated_at?: string
          view_all_visits?: boolean | null
          whatsapp?: string | null
        }
        Update: {
          assigned_countries?: string[] | null
          created_at?: string
          id?: string
          language_code?: string
          passcode_hash?: string | null
          primary_country_id?: string | null
          role?: Database["public"]["Enums"]["user_role"]
          updated_at?: string
          view_all_visits?: boolean | null
          whatsapp?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "fk_primary_country"
            columns: ["primary_country_id"]
            isOneToOne: false
            referencedRelation: "countries"
            referencedColumns: ["id"]
          },
        ]
      }
      schools: {
        Row: {
          community_id: string | null
          country_id: string
          created_at: string
          created_by: string | null
          deleted_at: string | null
          id: string
          name_en: string
          region: string | null
          subwatershed_id: string | null
          updated_at: string
          updated_by: string | null
          version: number
        }
        Insert: {
          community_id?: string | null
          country_id: string
          created_at?: string
          created_by?: string | null
          deleted_at?: string | null
          id?: string
          name_en: string
          region?: string | null
          subwatershed_id?: string | null
          updated_at?: string
          updated_by?: string | null
          version?: number
        }
        Update: {
          community_id?: string | null
          country_id?: string
          created_at?: string
          created_by?: string | null
          deleted_at?: string | null
          id?: string
          name_en?: string
          region?: string | null
          subwatershed_id?: string | null
          updated_at?: string
          updated_by?: string | null
          version?: number
        }
        Relationships: [
          {
            foreignKeyName: "schools_community_id_fkey"
            columns: ["community_id"]
            isOneToOne: false
            referencedRelation: "communities"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "schools_country_id_fkey"
            columns: ["country_id"]
            isOneToOne: false
            referencedRelation: "countries"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "schools_created_by_fkey"
            columns: ["created_by"]
            isOneToOne: false
            referencedRelation: "profiles"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "schools_subwatershed_id_fkey"
            columns: ["subwatershed_id"]
            isOneToOne: false
            referencedRelation: "subwatersheds"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "schools_updated_by_fkey"
            columns: ["updated_by"]
            isOneToOne: false
            referencedRelation: "profiles"
            referencedColumns: ["id"]
          },
        ]
      }
      subwatersheds: {
        Row: {
          country_id: string
          created_at: string
          created_by: string | null
          deleted_at: string | null
          id: string
          latitude: number | null
          longitude: number | null
          name_en: string
          updated_at: string
          updated_by: string | null
          version: number
        }
        Insert: {
          country_id: string
          created_at?: string
          created_by?: string | null
          deleted_at?: string | null
          id?: string
          latitude?: number | null
          longitude?: number | null
          name_en: string
          updated_at?: string
          updated_by?: string | null
          version?: number
        }
        Update: {
          country_id?: string
          created_at?: string
          created_by?: string | null
          deleted_at?: string | null
          id?: string
          latitude?: number | null
          longitude?: number | null
          name_en?: string
          updated_at?: string
          updated_by?: string | null
          version?: number
        }
        Relationships: [
          {
            foreignKeyName: "subwatersheds_country_id_fkey"
            columns: ["country_id"]
            isOneToOne: false
            referencedRelation: "countries"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "subwatersheds_created_by_fkey"
            columns: ["created_by"]
            isOneToOne: false
            referencedRelation: "profiles"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "subwatersheds_updated_by_fkey"
            columns: ["updated_by"]
            isOneToOne: false
            referencedRelation: "profiles"
            referencedColumns: ["id"]
          },
        ]
      }
      sync_log: {
        Row: {
          attempt_count: number | null
          client_uuid: string
          error_message: string | null
          id: string
          operation: string
          server_received_at: string
          status: string
          user_id: string | null
        }
        Insert: {
          attempt_count?: number | null
          client_uuid: string
          error_message?: string | null
          id?: string
          operation: string
          server_received_at?: string
          status: string
          user_id?: string | null
        }
        Update: {
          attempt_count?: number | null
          client_uuid?: string
          error_message?: string | null
          id?: string
          operation?: string
          server_received_at?: string
          status?: string
          user_id?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "sync_log_user_id_fkey"
            columns: ["user_id"]
            isOneToOne: false
            referencedRelation: "profiles"
            referencedColumns: ["id"]
          },
        ]
      }
      translations: {
        Row: {
          entity_id: string
          entity_type: Database["public"]["Enums"]["translation_entity_type"]
          field: string
          id: string
          locale: string
          updated_at: string
          updated_by: string | null
          value: string
        }
        Insert: {
          entity_id: string
          entity_type: Database["public"]["Enums"]["translation_entity_type"]
          field: string
          id?: string
          locale: string
          updated_at?: string
          updated_by?: string | null
          value: string
        }
        Update: {
          entity_id?: string
          entity_type?: Database["public"]["Enums"]["translation_entity_type"]
          field?: string
          id?: string
          locale?: string
          updated_at?: string
          updated_by?: string | null
          value?: string
        }
        Relationships: [
          {
            foreignKeyName: "translations_updated_by_fkey"
            columns: ["updated_by"]
            isOneToOne: false
            referencedRelation: "profiles"
            referencedColumns: ["id"]
          },
        ]
      }
      tree_species: {
        Row: {
          common_name_en: string | null
          country_id: string | null
          created_at: string
          created_by: string | null
          deleted_at: string | null
          id: string
          scientific_name: string
          updated_at: string
          updated_by: string | null
          version: number
        }
        Insert: {
          common_name_en?: string | null
          country_id?: string | null
          created_at?: string
          created_by?: string | null
          deleted_at?: string | null
          id?: string
          scientific_name: string
          updated_at?: string
          updated_by?: string | null
          version?: number
        }
        Update: {
          common_name_en?: string | null
          country_id?: string | null
          created_at?: string
          created_by?: string | null
          deleted_at?: string | null
          id?: string
          scientific_name?: string
          updated_at?: string
          updated_by?: string | null
          version?: number
        }
        Relationships: [
          {
            foreignKeyName: "tree_species_country_id_fkey"
            columns: ["country_id"]
            isOneToOne: false
            referencedRelation: "countries"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "tree_species_created_by_fkey"
            columns: ["created_by"]
            isOneToOne: false
            referencedRelation: "profiles"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "tree_species_updated_by_fkey"
            columns: ["updated_by"]
            isOneToOne: false
            referencedRelation: "profiles"
            referencedColumns: ["id"]
          },
        ]
      }
      units: {
        Row: {
          code: string
          id: string
          name_en: string
        }
        Insert: {
          code: string
          id?: string
          name_en: string
        }
        Update: {
          code?: string
          id?: string
          name_en?: string
        }
        Relationships: []
      }
      visit_media: {
        Row: {
          client_uuid: string
          content_type: string
          created_at: string
          created_by: string | null
          deleted_at: string | null
          id: string
          kind: Database["public"]["Enums"]["media_kind"]
          sha256: string
          size_bytes: number
          storage_path: string | null
          updated_at: string
          updated_by: string | null
          upload_status: Database["public"]["Enums"]["media_upload_status"]
          uploaded_at: string | null
          version: number
          visit_id: string
        }
        Insert: {
          client_uuid: string
          content_type: string
          created_at?: string
          created_by?: string | null
          deleted_at?: string | null
          id?: string
          kind: Database["public"]["Enums"]["media_kind"]
          sha256: string
          size_bytes: number
          storage_path?: string | null
          updated_at?: string
          updated_by?: string | null
          upload_status?: Database["public"]["Enums"]["media_upload_status"]
          uploaded_at?: string | null
          version?: number
          visit_id: string
        }
        Update: {
          client_uuid?: string
          content_type?: string
          created_at?: string
          created_by?: string | null
          deleted_at?: string | null
          id?: string
          kind?: Database["public"]["Enums"]["media_kind"]
          sha256?: string
          size_bytes?: number
          storage_path?: string | null
          updated_at?: string
          updated_by?: string | null
          upload_status?: Database["public"]["Enums"]["media_upload_status"]
          uploaded_at?: string | null
          version?: number
          visit_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "visit_media_created_by_fkey"
            columns: ["created_by"]
            isOneToOne: false
            referencedRelation: "profiles"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "visit_media_updated_by_fkey"
            columns: ["updated_by"]
            isOneToOne: false
            referencedRelation: "profiles"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "visit_media_visit_id_fkey"
            columns: ["visit_id"]
            isOneToOne: false
            referencedRelation: "v_visits_detail"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "visit_media_visit_id_fkey"
            columns: ["visit_id"]
            isOneToOne: false
            referencedRelation: "visits"
            referencedColumns: ["id"]
          },
        ]
      }
      visit_trees: {
        Row: {
          count: number
          created_at: string
          created_by: string | null
          deleted_at: string | null
          id: string
          tree_species_id: string
          updated_at: string
          updated_by: string | null
          version: number
          visit_id: string
        }
        Insert: {
          count: number
          created_at?: string
          created_by?: string | null
          deleted_at?: string | null
          id?: string
          tree_species_id: string
          updated_at?: string
          updated_by?: string | null
          version?: number
          visit_id: string
        }
        Update: {
          count?: number
          created_at?: string
          created_by?: string | null
          deleted_at?: string | null
          id?: string
          tree_species_id?: string
          updated_at?: string
          updated_by?: string | null
          version?: number
          visit_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "visit_trees_created_by_fkey"
            columns: ["created_by"]
            isOneToOne: false
            referencedRelation: "profiles"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "visit_trees_tree_species_id_fkey"
            columns: ["tree_species_id"]
            isOneToOne: false
            referencedRelation: "mv_top_species"
            referencedColumns: ["species_id"]
          },
          {
            foreignKeyName: "visit_trees_tree_species_id_fkey"
            columns: ["tree_species_id"]
            isOneToOne: false
            referencedRelation: "tree_species"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "visit_trees_updated_by_fkey"
            columns: ["updated_by"]
            isOneToOne: false
            referencedRelation: "profiles"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "visit_trees_visit_id_fkey"
            columns: ["visit_id"]
            isOneToOne: false
            referencedRelation: "v_visits_detail"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "visit_trees_visit_id_fkey"
            columns: ["visit_id"]
            isOneToOne: false
            referencedRelation: "visits"
            referencedColumns: ["id"]
          },
        ]
      }
      visits: {
        Row: {
          activity_id: string
          actual_end_at: string | null
          actual_start_at: string | null
          assignee: string | null
          attendance: number | null
          cancellation_comments: string | null
          cancellation_reason: string | null
          church_id: string | null
          client_uuid: string
          comments: string | null
          community_id: string | null
          core_area_id: string
          country_id: string
          created_at: string
          created_by: string | null
          deleted_at: string | null
          feedback: string | null
          feedback_score: number | null
          gps_latitude: number | null
          gps_longitude: number | null
          group_id: string | null
          id: string
          individual_name: string | null
          is_group: boolean | null
          is_public: boolean | null
          planting_end_date: string | null
          planting_start_date: string | null
          scheduled_by: string | null
          scheduled_date: string | null
          scheduled_end_time: string | null
          scheduled_start_time: string | null
          school_id: string | null
          signature_media_id: string | null
          status: Database["public"]["Enums"]["visit_status"]
          subwatershed_id: string | null
          total_trees_planted: number | null
          updated_at: string
          updated_by: string | null
          version: number
          visit_type: string | null
          visited_by: string | null
        }
        Insert: {
          activity_id: string
          actual_end_at?: string | null
          actual_start_at?: string | null
          assignee?: string | null
          attendance?: number | null
          cancellation_comments?: string | null
          cancellation_reason?: string | null
          church_id?: string | null
          client_uuid: string
          comments?: string | null
          community_id?: string | null
          core_area_id: string
          country_id: string
          created_at?: string
          created_by?: string | null
          deleted_at?: string | null
          feedback?: string | null
          feedback_score?: number | null
          gps_latitude?: number | null
          gps_longitude?: number | null
          group_id?: string | null
          id?: string
          individual_name?: string | null
          is_group?: boolean | null
          is_public?: boolean | null
          planting_end_date?: string | null
          planting_start_date?: string | null
          scheduled_by?: string | null
          scheduled_date?: string | null
          scheduled_end_time?: string | null
          scheduled_start_time?: string | null
          school_id?: string | null
          signature_media_id?: string | null
          status?: Database["public"]["Enums"]["visit_status"]
          subwatershed_id?: string | null
          total_trees_planted?: number | null
          updated_at?: string
          updated_by?: string | null
          version?: number
          visit_type?: string | null
          visited_by?: string | null
        }
        Update: {
          activity_id?: string
          actual_end_at?: string | null
          actual_start_at?: string | null
          assignee?: string | null
          attendance?: number | null
          cancellation_comments?: string | null
          cancellation_reason?: string | null
          church_id?: string | null
          client_uuid?: string
          comments?: string | null
          community_id?: string | null
          core_area_id?: string
          country_id?: string
          created_at?: string
          created_by?: string | null
          deleted_at?: string | null
          feedback?: string | null
          feedback_score?: number | null
          gps_latitude?: number | null
          gps_longitude?: number | null
          group_id?: string | null
          id?: string
          individual_name?: string | null
          is_group?: boolean | null
          is_public?: boolean | null
          planting_end_date?: string | null
          planting_start_date?: string | null
          scheduled_by?: string | null
          scheduled_date?: string | null
          scheduled_end_time?: string | null
          scheduled_start_time?: string | null
          school_id?: string | null
          signature_media_id?: string | null
          status?: Database["public"]["Enums"]["visit_status"]
          subwatershed_id?: string | null
          total_trees_planted?: number | null
          updated_at?: string
          updated_by?: string | null
          version?: number
          visit_type?: string | null
          visited_by?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "fk_signature"
            columns: ["signature_media_id"]
            isOneToOne: false
            referencedRelation: "visit_media"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "visits_activity_id_fkey"
            columns: ["activity_id"]
            isOneToOne: false
            referencedRelation: "activities"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "visits_assignee_fkey"
            columns: ["assignee"]
            isOneToOne: false
            referencedRelation: "profiles"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "visits_church_id_fkey"
            columns: ["church_id"]
            isOneToOne: false
            referencedRelation: "churches"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "visits_community_id_fkey"
            columns: ["community_id"]
            isOneToOne: false
            referencedRelation: "communities"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "visits_core_area_id_fkey"
            columns: ["core_area_id"]
            isOneToOne: false
            referencedRelation: "core_areas"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "visits_country_id_fkey"
            columns: ["country_id"]
            isOneToOne: false
            referencedRelation: "countries"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "visits_created_by_fkey"
            columns: ["created_by"]
            isOneToOne: false
            referencedRelation: "profiles"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "visits_group_id_fkey"
            columns: ["group_id"]
            isOneToOne: false
            referencedRelation: "groups"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "visits_scheduled_by_fkey"
            columns: ["scheduled_by"]
            isOneToOne: false
            referencedRelation: "profiles"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "visits_school_id_fkey"
            columns: ["school_id"]
            isOneToOne: false
            referencedRelation: "schools"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "visits_subwatershed_id_fkey"
            columns: ["subwatershed_id"]
            isOneToOne: false
            referencedRelation: "subwatersheds"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "visits_updated_by_fkey"
            columns: ["updated_by"]
            isOneToOne: false
            referencedRelation: "profiles"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "visits_visited_by_fkey"
            columns: ["visited_by"]
            isOneToOne: false
            referencedRelation: "profiles"
            referencedColumns: ["id"]
          },
        ]
      }
    }
    Views: {
      mv_country_kpis: {
        Row: {
          country_id: string | null
          total_attendance: number | null
          total_trees: number | null
          total_visits: number | null
        }
        Relationships: [
          {
            foreignKeyName: "visits_country_id_fkey"
            columns: ["country_id"]
            isOneToOne: false
            referencedRelation: "countries"
            referencedColumns: ["id"]
          },
        ]
      }
      mv_top_species: {
        Row: {
          common_name_en: string | null
          country_id: string | null
          species_id: string | null
          total_planted: number | null
        }
        Relationships: [
          {
            foreignKeyName: "tree_species_country_id_fkey"
            columns: ["country_id"]
            isOneToOne: false
            referencedRelation: "countries"
            referencedColumns: ["id"]
          },
        ]
      }
      mv_user_activity: {
        Row: {
          trees_planted_by_user: number | null
          user_id: string | null
          visits_created: number | null
        }
        Relationships: [
          {
            foreignKeyName: "visits_created_by_fkey"
            columns: ["user_id"]
            isOneToOne: false
            referencedRelation: "profiles"
            referencedColumns: ["id"]
          },
        ]
      }
      pg_all_foreign_keys: {
        Row: {
          fk_columns: unknown[] | null
          fk_constraint_name: unknown
          fk_schema_name: unknown
          fk_table_name: unknown
          fk_table_oid: unknown
          is_deferrable: boolean | null
          is_deferred: boolean | null
          match_type: string | null
          on_delete: string | null
          on_update: string | null
          pk_columns: unknown[] | null
          pk_constraint_name: unknown
          pk_index_name: unknown
          pk_schema_name: unknown
          pk_table_name: unknown
          pk_table_oid: unknown
        }
        Relationships: []
      }
      tap_funky: {
        Row: {
          args: string | null
          is_definer: boolean | null
          is_strict: boolean | null
          is_visible: boolean | null
          kind: unknown
          langoid: unknown
          name: unknown
          oid: unknown
          owner: unknown
          returns: string | null
          returns_set: boolean | null
          schema: unknown
          volatility: string | null
        }
        Relationships: []
      }
      v_visits_detail: {
        Row: {
          activity_id: string | null
          activity_name: string | null
          actual_end_at: string | null
          actual_start_at: string | null
          assignee: string | null
          attendance: number | null
          cancellation_comments: string | null
          cancellation_reason: string | null
          church_id: string | null
          client_uuid: string | null
          comments: string | null
          community_id: string | null
          core_area_id: string | null
          core_area_name: string | null
          country_id: string | null
          country_name: string | null
          created_at: string | null
          created_by: string | null
          deleted_at: string | null
          feedback: string | null
          feedback_score: number | null
          gps_latitude: number | null
          gps_longitude: number | null
          group_id: string | null
          id: string | null
          individual_name: string | null
          is_group: boolean | null
          is_public: boolean | null
          media_count: number | null
          planted_species: string | null
          planting_end_date: string | null
          planting_start_date: string | null
          scheduled_by: string | null
          scheduled_date: string | null
          scheduled_end_time: string | null
          scheduled_start_time: string | null
          school_id: string | null
          signature_media_id: string | null
          status: Database["public"]["Enums"]["visit_status"] | null
          subwatershed_id: string | null
          total_trees_planted: number | null
          updated_at: string | null
          updated_by: string | null
          version: number | null
          visit_type: string | null
          visited_by: string | null
        }
        Relationships: [
          {
            foreignKeyName: "fk_signature"
            columns: ["signature_media_id"]
            isOneToOne: false
            referencedRelation: "visit_media"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "visits_activity_id_fkey"
            columns: ["activity_id"]
            isOneToOne: false
            referencedRelation: "activities"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "visits_assignee_fkey"
            columns: ["assignee"]
            isOneToOne: false
            referencedRelation: "profiles"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "visits_church_id_fkey"
            columns: ["church_id"]
            isOneToOne: false
            referencedRelation: "churches"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "visits_community_id_fkey"
            columns: ["community_id"]
            isOneToOne: false
            referencedRelation: "communities"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "visits_core_area_id_fkey"
            columns: ["core_area_id"]
            isOneToOne: false
            referencedRelation: "core_areas"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "visits_country_id_fkey"
            columns: ["country_id"]
            isOneToOne: false
            referencedRelation: "countries"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "visits_created_by_fkey"
            columns: ["created_by"]
            isOneToOne: false
            referencedRelation: "profiles"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "visits_group_id_fkey"
            columns: ["group_id"]
            isOneToOne: false
            referencedRelation: "groups"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "visits_scheduled_by_fkey"
            columns: ["scheduled_by"]
            isOneToOne: false
            referencedRelation: "profiles"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "visits_school_id_fkey"
            columns: ["school_id"]
            isOneToOne: false
            referencedRelation: "schools"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "visits_subwatershed_id_fkey"
            columns: ["subwatershed_id"]
            isOneToOne: false
            referencedRelation: "subwatersheds"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "visits_updated_by_fkey"
            columns: ["updated_by"]
            isOneToOne: false
            referencedRelation: "profiles"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "visits_visited_by_fkey"
            columns: ["visited_by"]
            isOneToOne: false
            referencedRelation: "profiles"
            referencedColumns: ["id"]
          },
        ]
      }
    }
    Functions: {
      _cleanup: { Args: never; Returns: boolean }
      _contract_on: { Args: { "": string }; Returns: unknown }
      _currtest: { Args: never; Returns: number }
      _db_privs: { Args: never; Returns: unknown[] }
      _extensions: { Args: never; Returns: unknown[] }
      _get: { Args: { "": string }; Returns: number }
      _get_latest: { Args: { "": string }; Returns: number[] }
      _get_note: { Args: { "": string }; Returns: string }
      _is_verbose: { Args: never; Returns: boolean }
      _prokind: { Args: { p_oid: unknown }; Returns: unknown }
      _query: { Args: { "": string }; Returns: string }
      _refine_vol: { Args: { "": string }; Returns: string }
      _table_privs: { Args: never; Returns: unknown[] }
      _temptypes: { Args: { "": string }; Returns: string }
      _todo: { Args: never; Returns: string }
      admin_refresh_materialized_views: { Args: never; Returns: undefined }
      admin_restore_visit: { Args: { target_visit_id: string }; Returns: undefined }
      admin_soft_delete_visit: { Args: { target_visit_id: string }; Returns: undefined }
      bulk_cancel_visits: { Args: { reason: string; visit_ids: string[] }; Returns: undefined }
      bulk_reassign_visits: { Args: { new_assignee_id: string; visit_ids: string[] }; Returns: undefined }
      col_is_null:
        | {
            Args: {
              column_name: unknown
              description?: string
              schema_name: unknown
              table_name: unknown
            }
            Returns: string
          }
        | {
            Args: {
              column_name: unknown
              description?: string
              table_name: unknown
            }
            Returns: string
          }
      col_not_null:
        | {
            Args: {
              column_name: unknown
              description?: string
              schema_name: unknown
              table_name: unknown
            }
            Returns: string
          }
        | {
            Args: {
              column_name: unknown
              description?: string
              table_name: unknown
            }
            Returns: string
          }
      current_user_id: { Args: never; Returns: string }
      current_user_role: {
        Args: never
        Returns: Database["public"]["Enums"]["user_role"]
      }
      dashboard_kpis: {
        Args: {
          from_date: string
          target_country_ids: string[]
          to_date: string
        }
        Returns: Json
      }
      diag:
        | {
            Args: { msg: unknown }
            Returns: {
              error: true
            } & "Could not choose the best candidate function between: public.diag(msg => text), public.diag(msg => anyelement). Try renaming the parameters or the function itself in the database so function overloading can be resolved"
          }
        | {
            Args: { msg: string }
            Returns: {
              error: true
            } & "Could not choose the best candidate function between: public.diag(msg => text), public.diag(msg => anyelement). Try renaming the parameters or the function itself in the database so function overloading can be resolved"
          }
      diag_test_name: { Args: { "": string }; Returns: string }
      do_tap:
        | { Args: never; Returns: string[] }
        | { Args: { "": string }; Returns: string[] }
      fail:
        | { Args: never; Returns: string }
        | { Args: { "": string }; Returns: string }
      findfuncs: { Args: { "": string }; Returns: string[] }
      finish: { Args: { exception_on_failure?: boolean }; Returns: string[] }
      has_country_access: {
        Args: { target_country_id: string }
        Returns: boolean
      }
      has_unique: { Args: { "": string }; Returns: string }
      in_todo: { Args: never; Returns: boolean }
      is_admin: { Args: never; Returns: boolean }
      is_empty: { Args: { "": string }; Returns: string }
      is_super_admin: { Args: never; Returns: boolean }
      isnt_empty: { Args: { "": string }; Returns: string }
      lives_ok: { Args: { "": string }; Returns: string }
      no_plan: { Args: never; Returns: boolean[] }
      num_failed: { Args: never; Returns: number }
      os_name: { Args: never; Returns: string }
      pass:
        | { Args: never; Returns: string }
        | { Args: { "": string }; Returns: string }
      pg_version: { Args: never; Returns: string }
      pg_version_num: { Args: never; Returns: number }
      pgtap_version: { Args: never; Returns: number }
      pull_visits_since: {
        Args: { limit_?: number; since: string }
        Returns: {
          activity_id: string
          actual_end_at: string | null
          actual_start_at: string | null
          assignee: string | null
          attendance: number | null
          cancellation_comments: string | null
          cancellation_reason: string | null
          church_id: string | null
          client_uuid: string
          comments: string | null
          community_id: string | null
          core_area_id: string
          country_id: string
          created_at: string
          created_by: string | null
          deleted_at: string | null
          feedback: string | null
          feedback_score: number | null
          gps_latitude: number | null
          gps_longitude: number | null
          group_id: string | null
          id: string
          individual_name: string | null
          is_group: boolean | null
          is_public: boolean | null
          planting_end_date: string | null
          planting_start_date: string | null
          scheduled_by: string | null
          scheduled_date: string | null
          scheduled_end_time: string | null
          scheduled_start_time: string | null
          school_id: string | null
          signature_media_id: string | null
          status: Database["public"]["Enums"]["visit_status"]
          subwatershed_id: string | null
          total_trees_planted: number | null
          updated_at: string
          updated_by: string | null
          version: number
          visit_type: string | null
          visited_by: string | null
        }[]
        SetofOptions: {
          from: "*"
          to: "visits"
          isOneToOne: false
          isSetofReturn: true
        }
      }
      push_visit_batch: {
        Args: { media_payload: Json; trees_payload: Json; visits_payload: Json }
        Returns: undefined
      }
      runtests:
        | { Args: never; Returns: string[] }
        | { Args: { "": string }; Returns: string[] }
      skip:
        | { Args: { "": string }; Returns: string }
        | { Args: { how_many: number; why: string }; Returns: string }
      throws_ok: { Args: { "": string }; Returns: string }
      todo:
        | { Args: { how_many: number }; Returns: boolean[] }
        | { Args: { how_many: number; why: string }; Returns: boolean[] }
        | { Args: { why: string }; Returns: boolean[] }
        | { Args: { how_many: number; why: string }; Returns: boolean[] }
      todo_end: { Args: never; Returns: boolean[] }
      todo_start:
        | { Args: never; Returns: boolean[] }
        | { Args: { "": string }; Returns: boolean[] }
    }
    Enums: {
      audit_operation: "INSERT" | "UPDATE" | "DELETE"
      media_kind: "group_photo" | "activity_photo" | "signature"
      media_upload_status: "pending" | "uploading" | "completed" | "failed"
      sync_status: "draft" | "pending" | "syncing" | "synced" | "failed"
      translation_entity_type:
        | "country"
        | "tree_species"
        | "activity"
        | "core_area"
      user_role:
        | "super_admin"
        | "admin"
        | "coordinator"
        | "field_user"
        | "viewer"
      visit_status:
        | "draft"
        | "scheduled"
        | "completed"
        | "cancelled"
        | "approved"
        | "rejected"
    }
    CompositeTypes: {
      _time_trial_type: {
        a_time: number | null
      }
    }
  }
}

type DatabaseWithoutInternals = Omit<Database, "__InternalSupabase">

type DefaultSchema = DatabaseWithoutInternals[Extract<keyof Database, "public">]

export type Tables<
  DefaultSchemaTableNameOrOptions extends
    | keyof (DefaultSchema["Tables"] & DefaultSchema["Views"])
    | { schema: keyof DatabaseWithoutInternals },
  TableName extends DefaultSchemaTableNameOrOptions extends {
    schema: keyof DatabaseWithoutInternals
  }
    ? keyof (DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"] &
        DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Views"])
    : never = never,
> = DefaultSchemaTableNameOrOptions extends {
  schema: keyof DatabaseWithoutInternals
}
  ? (DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"] &
      DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Views"])[TableName] extends {
      Row: infer R
    }
    ? R
    : never
  : DefaultSchemaTableNameOrOptions extends keyof (DefaultSchema["Tables"] &
        DefaultSchema["Views"])
    ? (DefaultSchema["Tables"] &
        DefaultSchema["Views"])[DefaultSchemaTableNameOrOptions] extends {
        Row: infer R
      }
      ? R
      : never
    : never

export type TablesInsert<
  DefaultSchemaTableNameOrOptions extends
    | keyof DefaultSchema["Tables"]
    | { schema: keyof DatabaseWithoutInternals },
  TableName extends DefaultSchemaTableNameOrOptions extends {
    schema: keyof DatabaseWithoutInternals
  }
    ? keyof DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"]
    : never = never,
> = DefaultSchemaTableNameOrOptions extends {
  schema: keyof DatabaseWithoutInternals
}
  ? DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"][TableName] extends {
      Insert: infer I
    }
    ? I
    : never
  : DefaultSchemaTableNameOrOptions extends keyof DefaultSchema["Tables"]
    ? DefaultSchema["Tables"][DefaultSchemaTableNameOrOptions] extends {
        Insert: infer I
      }
      ? I
      : never
    : never

export type TablesUpdate<
  DefaultSchemaTableNameOrOptions extends
    | keyof DefaultSchema["Tables"]
    | { schema: keyof DatabaseWithoutInternals },
  TableName extends DefaultSchemaTableNameOrOptions extends {
    schema: keyof DatabaseWithoutInternals
  }
    ? keyof DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"]
    : never = never,
> = DefaultSchemaTableNameOrOptions extends {
  schema: keyof DatabaseWithoutInternals
}
  ? DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"][TableName] extends {
      Update: infer U
    }
    ? U
    : never
  : DefaultSchemaTableNameOrOptions extends keyof DefaultSchema["Tables"]
    ? DefaultSchema["Tables"][DefaultSchemaTableNameOrOptions] extends {
        Update: infer U
      }
      ? U
      : never
    : never

export type Enums<
  DefaultSchemaEnumNameOrOptions extends
    | keyof DefaultSchema["Enums"]
    | { schema: keyof DatabaseWithoutInternals },
  EnumName extends DefaultSchemaEnumNameOrOptions extends {
    schema: keyof DatabaseWithoutInternals
  }
    ? keyof DatabaseWithoutInternals[DefaultSchemaEnumNameOrOptions["schema"]]["Enums"]
    : never = never,
> = DefaultSchemaEnumNameOrOptions extends {
  schema: keyof DatabaseWithoutInternals
}
  ? DatabaseWithoutInternals[DefaultSchemaEnumNameOrOptions["schema"]]["Enums"][EnumName]
  : DefaultSchemaEnumNameOrOptions extends keyof DefaultSchema["Enums"]
    ? DefaultSchema["Enums"][DefaultSchemaEnumNameOrOptions]
    : never

export type CompositeTypes<
  PublicCompositeTypeNameOrOptions extends
    | keyof DefaultSchema["CompositeTypes"]
    | { schema: keyof DatabaseWithoutInternals },
  CompositeTypeName extends PublicCompositeTypeNameOrOptions extends {
    schema: keyof DatabaseWithoutInternals
  }
    ? keyof DatabaseWithoutInternals[PublicCompositeTypeNameOrOptions["schema"]]["CompositeTypes"]
    : never = never,
> = PublicCompositeTypeNameOrOptions extends {
  schema: keyof DatabaseWithoutInternals
}
  ? DatabaseWithoutInternals[PublicCompositeTypeNameOrOptions["schema"]]["CompositeTypes"][CompositeTypeName]
  : PublicCompositeTypeNameOrOptions extends keyof DefaultSchema["CompositeTypes"]
    ? DefaultSchema["CompositeTypes"][PublicCompositeTypeNameOrOptions]
    : never

export const Constants = {
  graphql_public: {
    Enums: {},
  },
  public: {
    Enums: {
      audit_operation: ["INSERT", "UPDATE", "DELETE"],
      media_kind: ["group_photo", "activity_photo", "signature"],
      media_upload_status: ["pending", "uploading", "completed", "failed"],
      sync_status: ["draft", "pending", "syncing", "synced", "failed"],
      translation_entity_type: [
        "country",
        "tree_species",
        "activity",
        "core_area",
      ],
      user_role: [
        "super_admin",
        "admin",
        "coordinator",
        "field_user",
        "viewer",
      ],
      visit_status: ["draft", "scheduled", "completed", "cancelled", "approved", "rejected"],
    },
  },
} as const

