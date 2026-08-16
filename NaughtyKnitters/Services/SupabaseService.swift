//
//  SupabaseService.swift
//  NaughtyKnitters
//

import Foundation
import Supabase

protocol VendorDataProviding: Sendable {
    func fetchRegions() async throws -> [Region]
    func fetchVendors() async throws -> [Vendor]
    func fetchPerks() async throws -> [RetailPerk]
    func fetchEvents() async throws -> [CommunityEvent]
}

/// Live Supabase PostgREST client. Falls back to bundled mock data only when
/// credentials are still placeholders or a request fails at the ViewModel layer.
final class SupabaseService: VendorDataProviding, @unchecked Sendable {
    static let shared = SupabaseService()

    private let client: SupabaseClient?

    init(client: SupabaseClient? = nil) {
        if let client {
            self.client = client
        } else if SupabaseConfig.isConfigured {
            self.client = SupabaseClient(
                supabaseURL: SupabaseConfig.url,
                supabaseKey: SupabaseConfig.anonKey
            )
        } else {
            self.client = nil
        }
    }

    var isLive: Bool { client != nil }

    func fetchRegions() async throws -> [Region] {
        let client = try requireClient()
        let regions: [Region] = try await client
            .from("regions")
            .select()
            .eq("is_active", value: true)
            .order("name")
            .execute()
            .value
        return regions
    }

    func fetchVendors() async throws -> [Vendor] {
        let client = try requireClient()
        let vendors: [Vendor] = try await client
            .from("vendors")
            .select()
            .order("name")
            .execute()
            .value
        return vendors
    }

    func fetchPerks() async throws -> [RetailPerk] {
        let client = try requireClient()
        let perks: [RetailPerk] = try await client
            .from("retail_perks")
            .select()
            .execute()
            .value
        return perks
    }

    func fetchEvents() async throws -> [CommunityEvent] {
        let client = try requireClient()
        let events: [CommunityEvent] = try await client
            .from("events")
            .select()
            .order("start_time", ascending: true)
            .execute()
            .value
        return events
    }

    private func requireClient() throws -> SupabaseClient {
        guard let client else {
            throw SupabaseServiceError.notConfigured
        }
        return client
    }
}

enum SupabaseServiceError: LocalizedError {
    case notConfigured
    case emptyResponse(String)
    case network(String)

    var errorDescription: String? {
        switch self {
        case .notConfigured:
            return "Supabase credentials are still placeholders. Paste URL + anon key in SupabaseConfig.swift."
        case .emptyResponse(let table):
            return "No rows returned from \(table)."
        case .network(let message):
            return message
        }
    }
}
