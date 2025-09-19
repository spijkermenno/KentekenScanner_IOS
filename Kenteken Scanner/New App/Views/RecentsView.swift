//
//  RecentsView.swift
//  Kenteken Scanner
//
//  Created by Menno Spijker on 19/09/2025.
//

import SwiftUI

struct RecentsView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = RecentsViewModel()
    @State private var showEmptyAlert = false

    let onSelect: (String) -> Void

    var body: some View {
        NavigationView {
            List {
                ForEach(viewModel.items) { item in
                    LicensePlateRow(plateText: item.displayPlate)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            onSelect(item.rawPlate)
                            dismiss()
                        }
                        .listRowSeparator(.hidden)
                        .listRowInsets(.init(top: 6, leading: 16, bottom: 12, trailing: 16))
                        .background(Color.clear)
                }
            }
            .listStyle(.plain)
            .navigationTitle("Recente kentekens")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Sluiten") { dismiss() }
                }
            }
            .onAppear {
                viewModel.load()
                showEmptyAlert = viewModel.isEmpty
            }
            .alert("Geen data", isPresented: $showEmptyAlert) {
                Button("OK") { dismiss() }
            } message: {
                Text("Er zijn nog geen kentekens opgeslagen.")
            }
        }
    }
}
