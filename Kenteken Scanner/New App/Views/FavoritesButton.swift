//
//  FavoritesButton.swift
//  Kenteken Scanner
//
//  Created by Menno Spijker on 18/09/2025.
//

import SwiftUI

struct FavoritesButton: View {
    var action: () -> Void
    
    var body: some View {
        Button(action: action) {
            SwiftUI.Image(systemName: "star")
                .symbolRenderingMode(.multicolor)
                .font(.system(size: 18))
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}
