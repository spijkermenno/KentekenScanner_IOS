//
//  BannerAdView.swift
//  Kenteken Scanner
//
//  Created by Menno Spijker on 18/09/2025.
//

import SwiftUI
import GoogleMobileAds

struct BannerAdView: UIViewRepresentable {
    let adUnitID: String = "ca-app-pub-3940256099942544/2435281174"

    func makeUIView(context: Context) -> BannerView {
        let banner = BannerView(adSize: AdSizeBanner)
        banner.adUnitID = adUnitID
        banner.rootViewController = UIApplication.shared.windows.first?.rootViewController
        banner.load(Request())
        return banner
    }

    func updateUIView(_ uiView: BannerView, context: Context) {}
}

struct RemoveAdsButton: View {
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            Text("Advertenties verwijderen?")
                .foregroundColor(.blue)
                .font(.system(size: 16, weight: .semibold))
        }
    }
}
