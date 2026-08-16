//
//  EventsCalendarView.swift
//  NaughtyKnitters
//

import SwiftUI

struct EventsCalendarView: View {
    @Bindable var viewModel: VendorViewModel

    var body: some View {
        NavigationStack {
            Group {
                if viewModel.upcomingEvents.isEmpty {
                    ContentUnavailableView(
                        "No community events yet",
                        systemImage: "calendar.badge.exclamationmark",
                        description: Text("Sit-and-knits, markets, and workshops for Greater Victoria & the Gulf Islands will land here.")
                    )
                } else {
                    List(viewModel.upcomingEvents) { event in
                        EventRow(event: event, vendorName: vendorName(for: event))
                    }
                }
            }
            .navigationTitle("Community & Markets")
        }
    }

    private func vendorName(for event: CommunityEvent) -> String? {
        guard let vendorId = event.vendorId else { return nil }
        return viewModel.vendors.first { $0.id == vendorId }?.name
    }
}

private struct EventRow: View {
    let event: CommunityEvent
    let vendorName: String?

    private var formattedDate: String {
        guard let startTime = event.startTime else { return "Date TBA" }
        return startTime.formatted(date: .abbreviated, time: .shortened)
    }

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: iconName)
                .font(.title3)
                .foregroundStyle(.white)
                .frame(width: 40, height: 40)
                .background(event.isSponsored ? Color.pink : Color.indigo, in: RoundedRectangle(cornerRadius: 10, style: .continuous))

            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(event.title)
                        .font(.headline)
                    if event.isSponsored {
                        Text("Sponsored")
                            .font(.caption2.weight(.bold))
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.pink.opacity(0.15), in: Capsule())
                            .foregroundStyle(.pink)
                    }
                }

                Text(event.eventType.replacingOccurrences(of: "_", with: " ").capitalized)
                    .font(.caption)
                    .foregroundStyle(.secondary)

                if let venueName = event.venueName {
                    Label(venueName, systemImage: "mappin")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                if let vendorName {
                    Text(vendorName)
                        .font(.caption2)
                        .foregroundStyle(.tertiary)
                }

                Text(formattedDate)
                    .font(.caption.weight(.medium))
                    .foregroundStyle(.primary)
            }
        }
        .padding(.vertical, 4)
    }

    private var iconName: String {
        switch event.eventType {
        case "workshop": return "scissors"
        case "market": return "basket.fill"
        case "sit_and_knit": return "cup.and.saucer.fill"
        default: return "calendar"
        }
    }
}

#Preview {
    EventsCalendarView(viewModel: {
        let vm = VendorViewModel()
        vm.events = CommunityEvent.sampleData
        vm.vendors = Vendor.sampleData
        return vm
    }())
}
