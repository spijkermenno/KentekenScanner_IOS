//
//  NotificationsView.swift
//  Kenteken Scanner
//
//  Created by Menno Spijker on 19/09/2025.
//

import SwiftUI

struct NotificationsView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = NotificationsViewModel()

    let onSelect: (String) -> Void

    var body: some View {
        NavigationView {
            List {
                if viewModel.notifications.isEmpty {
                    Text("Er zijn nog geen notificaties ingesteld.")
                        .foregroundColor(.secondary)
                } else {
                    ForEach(viewModel.notifications) { item in
                        HStack {
                            LicensePlateRow(plateText: item.licensePlate)
                            Spacer()
                            Text(item.date)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            onSelect(item.licensePlate)
                            dismiss()
                        }
                        .listRowSeparator(.hidden)
                        .listRowInsets(.init(top: 6, leading: 16, bottom: 12, trailing: 16))
                        .background(Color.clear)
                    }
                }
            }
            .listStyle(.plain)
            .navigationTitle("Notificaties")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Sluiten") { dismiss() }
                }
            }
            .onAppear {
                viewModel.load()
            }
        }
    }
}
