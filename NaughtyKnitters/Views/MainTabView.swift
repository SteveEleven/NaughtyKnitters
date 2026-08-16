//
//  MainTabView.swift
//  NaughtyKnitters
//

import SwiftUI

struct MainTabView: View {
    @State private var viewModel = VendorViewModel()

    var body: some View {
        TabView {
            VendorMapView(viewModel: viewModel)
                .tabItem {
                    Label("Map", systemImage: "map.fill")
                }

            VendorListView(viewModel: viewModel)
                .tabItem {
                    Label("Directory", systemImage: "list.bullet.rectangle")
                }

            EventsCalendarView(viewModel: viewModel)
                .tabItem {
                    Label("Community", systemImage: "calendar")
                }

            StashJournalPlaceholderView()
                .tabItem {
                    Label("My Stash", systemImage: "tray.full.fill")
                }
        }
        .tint(.pink)
        .task {
            await viewModel.loadInitialData()
        }
    }
}

#Preview {
    MainTabView()
}
