//
//  FavoritesView.swift
//  Kenteken Scanner
//
//  Created by Menno Spijker on 19/09/2025.
//

import SwiftUI

struct FavoritesView: View {
    @Environment(\.dismiss) private var dismiss
    var onSelect: (String) -> Void
    @StateObject private var viewModel = FavoritesViewModel()

    var body: some View {
        NavigationView {
            List {
                if viewModel.favorites.isEmpty {
                    Text("Geen favorieten opgeslagen.")
                        .foregroundColor(.secondary)
                } else {
                    ForEach(viewModel.favorites, id: \.self) { licensePlate in
                        LicensePlateRow(plateText: licensePlate)
                            .contentShape(Rectangle())
                            .onTapGesture {
                                onSelect(licensePlate)
                            }
                            .listRowSeparator(.hidden)
                            .listRowInsets(.init(top: 6, leading: 16, bottom: 12, trailing: 16))
                            .background(Color.clear)
                    }
                }
            }
            .listStyle(.plain)
            .navigationTitle("Favorieten")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Sluiten") { dismiss() }
                }
            }
        }
        .onAppear {
            viewModel.loadFavorites()
        }
    }
}

#Preview {
    FavoritesView { _ in }
}
