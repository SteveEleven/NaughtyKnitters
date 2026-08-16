//
//  StashJournalPlaceholderView.swift
//  NaughtyKnitters
//

import SwiftUI

struct StashJournalPlaceholderView: View {
    var body: some View {
        NavigationStack {
            ContentUnavailableView {
                Label("My Stash", systemImage: "tray.full.fill")
            } description: {
                Text("Track skeins, WIPs, and farm-gate hauls. Journaling lands in a later build.")
            } actions: {
                Button("Coming soon") {}
                    .buttonStyle(.borderedProminent)
                    .tint(.pink)
                    .disabled(true)
            }
            .navigationTitle("My Stash")
        }
    }
}

#Preview {
    StashJournalPlaceholderView()
}
