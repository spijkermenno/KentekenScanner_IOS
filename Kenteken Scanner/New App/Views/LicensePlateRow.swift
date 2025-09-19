//
//  LicensePlateRow.swift
//  Kenteken Scanner
//
//  Created by Menno Spijker on 19/09/2025.
//

import SwiftUI

struct LicensePlateRow: View {
    let plateText: String

    var body: some View {
        ZStack {
            SwiftUI.Image("kentekenplaat")
                .resizable()
                .aspectRatio(contentMode: .fit)

            Text("   \(plateText)")
                .font(.custom("GillSans", size: 42))
                .foregroundColor(.black)
                .lineLimit(1)
                .minimumScaleFactor(0.5)
        }
        .frame(height: 100)
        .background(Color.clear)
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}

#Preview {
    LicensePlateRow(plateText: "AB-123-C")
}
