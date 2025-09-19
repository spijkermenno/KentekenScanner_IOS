//
//  RecentsButton.swift
//  Kenteken Scanner
//
//  Created by Menno Spijker on 18/09/2025.
//

import SwiftUI

struct RecentsButton: View {
    var action: () -> Void
    
    var body: some View {
        Button(action: action) {
            SwiftUI.Image(systemName: "clock.arrow.circlepath")
                .symbolRenderingMode(.multicolor)
                .font(.system(size: 18))
                .foregroundColor(.accentColor)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}
