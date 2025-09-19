//
//  FavoritesViewModel.swift
//  Kenteken Scanner
//
//  Created by Menno Spijker on 19/09/2025.
//

import Foundation

@MainActor
final class FavoritesViewModel: ObservableObject {
    @Published var favorites: [String] = []

    private let getFavorites: GetFavoritesUseCase
    private let addFavorite: AddFavoriteUseCase

    init(
        getFavorites: GetFavoritesUseCase = .init(),
        addFavorite: AddFavoriteUseCase = .init()
    ) {
        self.getFavorites = getFavorites
        self.addFavorite = addFavorite
    }

    func loadFavorites() {
        favorites = getFavorites.execute()
    }

    func addFavoritePlate(_ licensePlate: String) {
        addFavorite.execute(licensePlate: licensePlate)
        loadFavorites()
    }
}
