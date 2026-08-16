//
//  VendorViewModel.swift
//  NaughtyKnitters
//

import Foundation
import Observation

@Observable
@MainActor
final class VendorViewModel {
    var vendors: [Vendor] = []
    var regions: [Region] = []
    var perks: [RetailPerk] = []
    var events: [CommunityEvent] = []

    var selectedCraftTags: Set<String> = []
    var searchQuery: String = ""
    var selectedRegionPack: RegionPack? = .vancouverIslandCore
    var isFeaturedOnly: Bool = false
    var isLoading: Bool = false
    var errorMessage: String?
    var isUsingMockFallback: Bool = false

    private let dataProvider: any VendorDataProviding

    init(dataProvider: (any VendorDataProviding)? = nil) {
        self.dataProvider = dataProvider ?? SupabaseService.shared
    }

    var filteredVendors: [Vendor] {
        vendors.filter { vendor in
            matchesCraftTags(vendor)
                && matchesSearch(vendor)
                && matchesRegionPack(vendor)
                && matchesFeatured(vendor)
        }
        .sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
    }

    var mappableVendors: [Vendor] {
        filteredVendors.filter { $0.coordinate != nil }
    }

    var upcomingEvents: [CommunityEvent] {
        events
            .sorted { lhs, rhs in
                (lhs.startTime ?? .distantFuture) < (rhs.startTime ?? .distantFuture)
            }
    }

    /// Fetches live vendors, regions, perks, and events on launch.
    /// Keeps `Vendor.sampleData` (and related samples) only when the network request fails.
    func loadInitialData() async {
        isLoading = true
        errorMessage = nil
        isUsingMockFallback = false
        defer { isLoading = false }

        #if DEBUG
        do {
            try ModelDecodingSmoke.verify()
        } catch {
            errorMessage = "Decode smoke test failed: \(error.localizedDescription)"
        }
        #endif

        do {
            async let fetchedRegions = dataProvider.fetchRegions()
            async let fetchedVendors = dataProvider.fetchVendors()
            async let fetchedPerks = dataProvider.fetchPerks()
            async let fetchedEvents = dataProvider.fetchEvents()

            let liveRegions = try await fetchedRegions
            let liveVendors = try await fetchedVendors
            let livePerks = try await fetchedPerks
            let liveEvents = try await fetchedEvents

            regions = liveRegions
            vendors = liveVendors
            perks = livePerks
            events = liveEvents
            isUsingMockFallback = false
        } catch {
            applyMockFallback(reason: error.localizedDescription)
        }
    }

    /// Backwards-compatible alias used by previews / older call sites.
    func load() async {
        await loadInitialData()
    }

    func toggleCraftTag(_ tag: String) {
        if selectedCraftTags.contains(tag) {
            selectedCraftTags.remove(tag)
        } else {
            selectedCraftTags.insert(tag)
        }
    }

    func clearFilters() {
        selectedCraftTags.removeAll()
        searchQuery = ""
        isFeaturedOnly = false
        selectedRegionPack = .vancouverIslandCore
    }

    func region(for vendor: Vendor) -> Region? {
        guard let regionId = vendor.regionId else { return nil }
        return regions.first { $0.id == regionId }
    }

    func groupingKey(for vendor: Vendor) -> String {
        if let region = region(for: vendor) {
            return region.subArea ?? region.name
        }
        return "Greater Victoria & Gulf Islands"
    }

    func activePerks(for vendor: Vendor) -> [RetailPerk] {
        perks.filter { $0.vendorId == vendor.id && $0.isActive }
    }

    func hasActivePerk(for vendor: Vendor) -> Bool {
        !activePerks(for: vendor).isEmpty
    }

    // MARK: - Private

    private func applyMockFallback(reason: String) {
        regions = Region.sampleData
        vendors = Vendor.sampleData
        perks = RetailPerk.sampleData
        events = CommunityEvent.sampleData
        isUsingMockFallback = true
        errorMessage = reason
    }

    private func matchesCraftTags(_ vendor: Vendor) -> Bool {
        guard !selectedCraftTags.isEmpty else { return true }
        return !selectedCraftTags.isDisjoint(with: Set(vendor.craftTags))
    }

    private func matchesSearch(_ vendor: Vendor) -> Bool {
        let query = searchQuery.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !query.isEmpty else { return true }

        let haystack = [
            vendor.name,
            vendor.address ?? "",
            vendor.vendorType.displayName,
            vendor.craftTags.joined(separator: " "),
            region(for: vendor)?.name ?? "",
            region(for: vendor)?.subArea ?? ""
        ]
        .joined(separator: " ")
        .lowercased()

        return haystack.contains(query.lowercased())
    }

    private func matchesRegionPack(_ vendor: Vendor) -> Bool {
        guard let selectedRegionPack else { return true }
        guard let region = region(for: vendor) else { return true }
        return region.regionPack == selectedRegionPack
    }

    private func matchesFeatured(_ vendor: Vendor) -> Bool {
        !isFeaturedOnly || vendor.isFeatured
    }
}
