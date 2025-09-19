//
//  NotificationsButton.swift
//  Kenteken Scanner
//
//  Created by Menno Spijker on 18/09/2025.
//

import SwiftUI

struct NotificationsButton: View {
    var action: () -> Void
    
    var body: some View {
        Button(action: action) {
            SwiftUI.Image(systemName: "bell")
                .symbolRenderingMode(.multicolor)
                .font(.system(size: 18))
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}
