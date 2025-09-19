//
//  CameraButton.swift
//  Kenteken Scanner
//
//  Created by Menno Spijker on 18/09/2025.
//

import SwiftUI

struct CameraButton: View {
    var action: () -> Void
    
    var body: some View {
        Button(action: action) {
            SwiftUI.Image(systemName: "camera")
                .symbolRenderingMode(.multicolor)
                .font(.system(size: 18))
                .foregroundColor(.accentColor)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}
