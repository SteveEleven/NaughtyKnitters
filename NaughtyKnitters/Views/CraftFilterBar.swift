//
//  CraftFilterBar.swift
//  NaughtyKnitters
//

import SwiftUI

struct CraftFilterBar: View {
    @Bindable var viewModel: VendorViewModel

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(CraftCategory.allCases) { craft in
                    let isSelected = viewModel.selectedCraftTags.contains(craft.rawValue)
                    Button {
                        viewModel.toggleCraftTag(craft.rawValue)
                    } label: {
                        Label(craft.rawValue, systemImage: craft.systemImage)
                            .font(.caption.weight(.semibold))
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(
                                Capsule()
                                    .fill(isSelected ? Color.pink : Color(.systemBackground).opacity(0.92))
                            )
                            .foregroundStyle(isSelected ? .white : .primary)
                            .overlay(
                                Capsule()
                                    .strokeBorder(Color.pink.opacity(isSelected ? 0 : 0.35), lineWidth: 1)
                            )
                    }
                    .buttonStyle(.plain)
                }

                Button {
                    viewModel.isFeaturedOnly.toggle()
                } label: {
                    Label("Featured", systemImage: "star.fill")
                        .font(.caption.weight(.semibold))
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(
                            Capsule()
                                .fill(viewModel.isFeaturedOnly ? Color.orange : Color(.systemBackground).opacity(0.92))
                        )
                        .foregroundStyle(viewModel.isFeaturedOnly ? .white : .primary)
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
        }
    }
}

#Preview {
    CraftFilterBar(viewModel: VendorViewModel())
}
