//
//  SupabaseConfig.swift
//  NaughtyKnitters
//

import Foundation

enum SupabaseConfig {
    static let urlString = "https://tyrmrbcwxydmdrztkdul.supabase.co"

    /// Publishable / anon key (safe for client apps; RLS still applies).
    static let anonKey = "sb_publishable_vKpexTY0_4eLpGEOryyUaw_eFg1kxDS"

    static var url: URL {
        guard let url = URL(string: urlString) else {
            preconditionFailure("Invalid SUPABASE_URL in SupabaseConfig.")
        }
        return url
    }

    static var isConfigured: Bool {
        urlString.hasPrefix("https://")
            && !urlString.contains("<PASTE_")
            && !anonKey.contains("<PASTE_")
            && !anonKey.isEmpty
    }
}
