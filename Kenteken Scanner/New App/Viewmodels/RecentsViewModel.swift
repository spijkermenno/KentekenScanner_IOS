//
//  RecentsViewModel.swift
//  Kenteken Scanner
//
//  Created by Menno Spijker on 19/09/2025.
//

import Foundation

@MainActor
final class RecentsViewModel: ObservableObject {
    struct Item: Identifiable, Hashable {
        let id: String
        let rawPlate: String
        let displayPlate: String
    }

    @Published var items: [Item] = []

    private let loadRecents: LoadRecentsUseCase
    private let formatPlate: FormatLicensePlateUseCase

    init(
        loadRecents: LoadRecentsUseCase = .init(),
        formatPlate: FormatLicensePlateUseCase = .init()
    ) {
        self.loadRecents = loadRecents
        self.formatPlate = formatPlate
    }

    func load() {
        let recents = loadRecents()
        self.items = recents.map { raw in
            Item(id: raw, rawPlate: raw, displayPlate: formatPlate(raw))
        }
    }

    var isEmpty: Bool { items.isEmpty }
}
