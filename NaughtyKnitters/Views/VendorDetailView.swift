//
//  VendorDetailView.swift
//  NaughtyKnitters
//

import MapKit
import SwiftUI
import UIKit

struct VendorDetailView: View {
    let vendor: Vendor
    @Bindable var viewModel: VendorViewModel

    private var activePerks: [RetailPerk] {
        viewModel.activePerks(for: vendor)
    }

    private var region: Region? {
        viewModel.region(for: vendor)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                header
                actionButtons
                aboutSection
                if !activePerks.isEmpty {
                    perksSection
                }
                if let coordinate = vendor.coordinate {
                    miniMap(coordinate)
                }
            }
            .padding()
        }
        .navigationTitle(vendor.name)
        .navigationBarTitleDisplayMode(.inline)
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 10) {
                Image(systemName: vendor.vendorType.systemImage)
                    .font(.title2)
                    .foregroundStyle(.white)
                    .frame(width: 52, height: 52)
                    .background(vendor.vendorType.mapColor, in: RoundedRectangle(cornerRadius: 14, style: .continuous))

                VStack(alignment: .leading, spacing: 4) {
                    Text(vendor.vendorType.displayName)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(vendor.vendorType.mapColor)

                    if vendor.isFeatured {
                        Label("Featured stop", systemImage: "star.fill")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(.orange)
                    }

                    if let region {
                        Text([region.name, region.subArea].compactMap { $0 }.joined(separator: " · "))
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }

            if let address = vendor.address {
                Label(address, systemImage: "mappin.and.ellipse")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Label(vendor.accessModel, systemImage: "door.left.hand.open")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(vendor.craftTags, id: \.self) { tag in
                        Text(tag)
                            .font(.caption.weight(.medium))
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(Color.pink.opacity(0.12), in: Capsule())
                            .foregroundStyle(.pink)
                    }
                }
            }
        }
    }

    private var actionButtons: some View {
        HStack(spacing: 12) {
            actionButton(title: "Call", systemImage: "phone.fill", enabled: vendor.phone != nil) {
                openURL(scheme: "tel", value: vendor.phone)
            }
            actionButton(title: "Email", systemImage: "envelope.fill", enabled: vendor.email != nil) {
                openURL(scheme: "mailto", value: vendor.email)
            }
            actionButton(title: "Directions", systemImage: "arrow.triangle.turn.up.right.diamond.fill", enabled: vendor.coordinate != nil) {
                openDirections()
            }
            actionButton(title: "Website", systemImage: "safari.fill", enabled: vendor.websiteUrl != nil) {
                if let websiteUrl = vendor.websiteUrl, let url = URL(string: websiteUrl) {
                    UIApplication.shared.open(url)
                }
            }
        }
    }

    private func actionButton(title: String, systemImage: String, enabled: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(spacing: 6) {
                Image(systemName: systemImage)
                    .font(.title3)
                Text(title)
                    .font(.caption2.weight(.semibold))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(enabled ? Color.pink.opacity(0.12) : Color(.tertiarySystemFill), in: RoundedRectangle(cornerRadius: 14, style: .continuous))
            .foregroundStyle(enabled ? .pink : .secondary)
        }
        .buttonStyle(.plain)
        .disabled(!enabled)
    }

    private var aboutSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("About")
                .font(.headline)

            if let handle = vendor.instagramHandle {
                Label("@\(handle)", systemImage: "camera.fill")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            if let affiliateCode = vendor.affiliateCode {
                Label("Affiliate: \(affiliateCode)", systemImage: "tag.fill")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    private var perksSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Active Perks")
                    .font(.headline)
                Spacer()
                Text("\(activePerks.count)")
                    .font(.caption.weight(.bold))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.orange.opacity(0.2), in: Capsule())
                    .foregroundStyle(.orange)
            }

            ForEach(activePerks) { perk in
                PerkRedemptionCard(perk: perk)
            }
        }
    }

    private func miniMap(_ coordinate: CLLocationCoordinate2D) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Location")
                .font(.headline)

            Map(initialPosition: .region(
                MKCoordinateRegion(
                    center: coordinate,
                    span: MKCoordinateSpan(latitudeDelta: 0.03, longitudeDelta: 0.03)
                )
            )) {
                Annotation(vendor.name, coordinate: coordinate) {
                    Image(systemName: vendor.vendorType.systemImage)
                        .foregroundStyle(.white)
                        .padding(8)
                        .background(vendor.vendorType.mapColor, in: Circle())
                }
            }
            .frame(height: 180)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .allowsHitTesting(false)
        }
    }

    private func openURL(scheme: String, value: String?) {
        guard let value, let url = URL(string: "\(scheme):\(value)") else { return }
        UIApplication.shared.open(url)
    }

    private func openDirections() {
        guard let coordinate = vendor.coordinate else { return }
        let placemark = MKPlacemark(coordinate: coordinate)
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = vendor.name
        mapItem.openInMaps(launchOptions: [
            MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving
        ])
    }
}

private struct PerkRedemptionCard: View {
    let perk: RetailPerk
    @State private var isRedeeming = false
    @State private var stampCount = 0

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(perk.offerTitle)
                        .font(.subheadline.weight(.semibold))
                    Text(perk.perkType.replacingOccurrences(of: "_", with: " ").capitalized)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                Image(systemName: "ticket.fill")
                    .foregroundStyle(.orange)
            }

            if perk.spendThreshold > 0 {
                Text("Spend $\(perk.spendThreshold, specifier: "%.0f")+ to unlock")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            if let promoCode = perk.promoCode {
                Text("Code: \(promoCode)")
                    .font(.caption.monospaced())
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color(.tertiarySystemFill), in: Capsule())
            }

            Text(perk.redemptionMode)
                .font(.caption2)
                .foregroundStyle(.tertiary)

            Button {
                withAnimation {
                    isRedeeming = true
                    stampCount += 1
                }
            } label: {
                Label(
                    stampCount == 0 ? "Redeem at counter" : "Stamped ×\(stampCount)",
                    systemImage: stampCount == 0 ? "hand.tap.fill" : "checkmark.seal.fill"
                )
                .font(.subheadline.weight(.semibold))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
                .background(isRedeeming ? Color.green : Color.orange, in: RoundedRectangle(cornerRadius: 12))
                .foregroundStyle(.white)
            }
            .buttonStyle(.plain)
        }
        .padding()
        .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .strokeBorder(Color.orange.opacity(0.35), lineWidth: 1)
        )
    }
}

#Preview {
    NavigationStack {
        VendorDetailView(
            vendor: Vendor.sampleData[0],
            viewModel: {
                let vm = VendorViewModel()
                vm.vendors = Vendor.sampleData
                vm.regions = Region.sampleData
                vm.perks = RetailPerk.sampleData
                return vm
            }()
        )
    }
}
