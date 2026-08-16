//
//  VendorListView.swift
//  NaughtyKnitters
//

import SwiftUI

struct VendorListView: View {
    @Bindable var viewModel: VendorViewModel

    private var groupedVendors: [(key: String, vendors: [Vendor])] {
        let groups = Dictionary(grouping: viewModel.filteredVendors) { viewModel.groupingKey(for: $0) }
        return groups
            .map { (key: $0.key, vendors: $0.value.sorted { $0.name < $1.name }) }
            .sorted { $0.key < $1.key }
    }

    var body: some View {
        NavigationStack {
            List {
                Section {
                    CraftFilterBar(viewModel: viewModel)
                        .listRowInsets(EdgeInsets())
                        .listRowBackground(Color.clear)
                }

                if viewModel.filteredVendors.isEmpty {
                    ContentUnavailableView(
                        "No yarn stops found",
                        systemImage: "magnifyingglass",
                        description: Text("Try clearing craft filters or searching another sub-area.")
                    )
                } else {
                    ForEach(groupedVendors, id: \.key) { group in
                        Section(group.key) {
                            ForEach(group.vendors) { vendor in
                                NavigationLink {
                                    VendorDetailView(vendor: vendor, viewModel: viewModel)
                                } label: {
                                    VendorRow(
                                        vendor: vendor,
                                        hasPerk: viewModel.hasActivePerk(for: vendor),
                                        perkCount: viewModel.activePerks(for: vendor).count
                                    )
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Directory")
            .searchable(text: $viewModel.searchQuery, prompt: "Search shops, farms, mills…")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Menu {
                        Picker("Region pack", selection: Binding(
                            get: { viewModel.selectedRegionPack },
                            set: { viewModel.selectedRegionPack = $0 }
                        )) {
                            Text("All packs").tag(RegionPack?.none)
                            ForEach(RegionPack.allCases) { pack in
                                Text(pack.displayName).tag(Optional(pack))
                            }
                        }

                        Toggle("Featured only", isOn: $viewModel.isFeaturedOnly)

                        Button("Clear filters", role: .destructive) {
                            viewModel.clearFilters()
                        }
                    } label: {
                        Image(systemName: "line.3.horizontal.decrease.circle")
                    }
                }
            }
        }
    }
}

private struct VendorRow: View {
    let vendor: Vendor
    let hasPerk: Bool
    let perkCount: Int

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: vendor.vendorType.systemImage)
                .font(.title3)
                .foregroundStyle(.white)
                .frame(width: 40, height: 40)
                .background(vendor.vendorType.mapColor, in: RoundedRectangle(cornerRadius: 10, style: .continuous))

            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 6) {
                    Text(vendor.name)
                        .font(.headline)

                    if vendor.isFeatured {
                        Text("Featured")
                            .font(.caption2.weight(.bold))
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.orange.opacity(0.2), in: Capsule())
                            .foregroundStyle(.orange)
                    }
                }

                Text(vendor.vendorType.displayName)
                    .font(.caption)
                    .foregroundStyle(.secondary)

                if let address = vendor.address {
                    Text(address)
                        .font(.caption2)
                        .foregroundStyle(.tertiary)
                        .lineLimit(1)
                }

                FlowTagRow(tags: vendor.craftTags, perkCount: hasPerk ? perkCount : 0)
            }
        }
        .padding(.vertical, 4)
    }
}

private struct FlowTagRow: View {
    let tags: [String]
    let perkCount: Int

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 6) {
                ForEach(tags, id: \.self) { tag in
                    Text(tag)
                        .font(.caption2)
                        .padding(.horizontal, 7)
                        .padding(.vertical, 3)
                        .background(Color.pink.opacity(0.12), in: Capsule())
                        .foregroundStyle(.pink)
                }

                if perkCount > 0 {
                    Label("\(perkCount) perk\(perkCount == 1 ? "" : "s")", systemImage: "ticket.fill")
                        .font(.caption2.weight(.semibold))
                        .padding(.horizontal, 7)
                        .padding(.vertical, 3)
                        .background(Color.green.opacity(0.15), in: Capsule())
                        .foregroundStyle(.green)
                }
            }
        }
    }
}

#Preview {
    VendorListView(viewModel: {
        let vm = VendorViewModel()
        vm.vendors = Vendor.sampleData
        vm.regions = Region.sampleData
        vm.perks = RetailPerk.sampleData
        return vm
    }())
}
