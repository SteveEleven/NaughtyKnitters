//
//  VendorMapView.swift
//  NaughtyKnitters
//

import MapKit
import SwiftUI

struct VendorMapView: View {
    @Bindable var viewModel: VendorViewModel
    @State private var selectedVendor: Vendor?
    @State private var cameraPosition: MapCameraPosition = .region(
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 48.55, longitude: -123.45),
            span: MKCoordinateSpan(latitudeDelta: 0.55, longitudeDelta: 0.55)
        )
    )

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                Map(position: $cameraPosition) {
                    ForEach(mappableVendors) { vendor in
                        if let coordinate = vendor.coordinate {
                            Annotation(vendor.name, coordinate: coordinate, anchor: .bottom) {
                                Button {
                                    withAnimation(.spring(response: 0.35)) {
                                        selectedVendor = vendor
                                    }
                                } label: {
                                    VendorMapPin(vendor: vendor, isSelected: selectedVendor?.id == vendor.id)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                }
                .mapStyle(.standard(elevation: .realistic))
                .ignoresSafeArea(edges: .bottom)

                VStack(spacing: 0) {
                    CraftFilterBar(viewModel: viewModel)
                        .background(.ultraThinMaterial)

                    Spacer()

                    if let selectedVendor {
                        VendorPreviewCard(
                            vendor: selectedVendor,
                            region: viewModel.region(for: selectedVendor),
                            perkCount: viewModel.activePerks(for: selectedVendor).count
                        ) {
                            withAnimation { self.selectedVendor = nil }
                        }
                        .padding(.horizontal, 16)
                        .padding(.bottom, 12)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                    }
                }
            }
            .navigationTitle("Naughty Knitters")
            .navigationBarTitleDisplayMode(.inline)
            .navigationDestination(for: Vendor.self) { vendor in
                VendorDetailView(vendor: vendor, viewModel: viewModel)
            }
        }
    }

    private var mappableVendors: [Vendor] {
        viewModel.mappableVendors
    }
}

private struct VendorMapPin: View {
    let vendor: Vendor
    let isSelected: Bool

    var body: some View {
        VStack(spacing: 0) {
            Image(systemName: vendor.vendorType.systemImage)
                .font(.system(size: 14, weight: .bold))
                .foregroundStyle(.white)
                .frame(width: 34, height: 34)
                .background(vendor.vendorType.mapColor, in: Circle())
                .overlay {
                    Circle()
                        .strokeBorder(.white, lineWidth: 2)
                }
                .shadow(color: .black.opacity(0.25), radius: 3, y: 2)
                .scaleEffect(isSelected ? 1.18 : 1)

            Triangle()
                .fill(vendor.vendorType.mapColor)
                .frame(width: 12, height: 8)
                .offset(y: -2)
        }
    }
}

private struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
        path.closeSubpath()
        return path
    }
}

private struct VendorPreviewCard: View {
    let vendor: Vendor
    let region: Region?
    let perkCount: Int
    let onDismiss: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 6) {
                        if vendor.isFeatured {
                            Image(systemName: "star.fill")
                                .foregroundStyle(.orange)
                                .font(.caption)
                        }
                        Text(vendor.name)
                            .font(.headline)
                    }

                    Text(vendor.vendorType.displayName)
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    if let region {
                        Text(region.subArea ?? region.name)
                            .font(.caption2)
                            .foregroundStyle(.tertiary)
                    }
                }

                Spacer()

                Button(action: onDismiss) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(.secondary)
                        .font(.title3)
                }
                .buttonStyle(.plain)
            }

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 6) {
                    ForEach(vendor.craftTags, id: \.self) { tag in
                        Text(tag)
                            .font(.caption2.weight(.medium))
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.pink.opacity(0.12), in: Capsule())
                            .foregroundStyle(.pink)
                    }

                    if perkCount > 0 {
                        Text("\(perkCount) perk\(perkCount == 1 ? "" : "s")")
                            .font(.caption2.weight(.semibold))
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.orange.opacity(0.15), in: Capsule())
                            .foregroundStyle(.orange)
                    }
                }
            }

            NavigationLink(value: vendor) {
                Text("View profile")
                    .font(.subheadline.weight(.semibold))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(Color.pink, in: RoundedRectangle(cornerRadius: 12))
                    .foregroundStyle(.white)
            }
        }
        .padding(16)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
        .shadow(color: .black.opacity(0.15), radius: 12, y: 4)
    }
}

#Preview {
    VendorMapView(viewModel: {
        let vm = VendorViewModel()
        vm.vendors = Vendor.sampleData
        vm.regions = Region.sampleData
        vm.perks = RetailPerk.sampleData
        return vm
    }())
}
