//
//  LicensePlateInputField.swift
//  Kenteken Scanner
//
//  Created by Menno Spijker on 18/09/2025.
//

import SwiftUI

struct LicensePlateInputField: View {
    @Binding var plateText: String
    var onCommit: () -> Void

    var body: some View {
        HStack(spacing: 0) {
            ZStack {
                SwiftUI.Image("europeStar")
                    .resizable()
                    .scaledToFit()
                    .padding(4)
            }
            .frame(width: 50, height: 78)
            .background(Color("KentekenBlue"))

            TextField("00-XXX-0", text: $plateText, onCommit: onCommit)
                .frame(height: 78)
                .font(.system(size: 36, weight: .bold, design: .default))
                .multilineTextAlignment(.center)
                .foregroundColor(.black)
                .textInputAutocapitalization(.never)
                .disableAutocorrection(true)
                .keyboardType(.asciiCapable)
                .submitLabel(.search)
                .padding(.horizontal, 8)
        }
        .frame(width: 290, height: 78)
        .background(Color("kentekenYellow"))
        .cornerRadius(12)
    }
}

#Preview {
    // Dummy binding for preview
    LicensePlateInputField(
        plateText: .constant("31SLDL"),
        onCommit: {}
    )
}
