//
//  ContentView.swift
//  Kenteken Scanner
//
//  Created by Menno Spijker on 18/09/2025.
//

import SwiftUI
import GoogleMobileAds

struct ContentView: View {
    @State private var isShowingRecents: Bool = false
    @State private var isShowingFavorites: Bool = false
    @State private var isShowingActiveNotifications: Bool = false
    @State private var isShowingCameraView: Bool = false
    
    @StateObject private var iap = IAPViewModel()
    @StateObject private var licensePlateViewModel = LicensePlateViewModel()
    @StateObject private var favoritesViewModel = FavoritesViewModel()
    
    var body: some View {
        VStack(spacing: 16) {
            LicensePlateInputField(
                plateText: $licensePlateViewModel.licensePlate,
                onCommit: { licensePlateViewModel.checkLicensePlate() }
            )

            HStack(spacing: 5) {
                RecentsButton { isShowingRecents = true }
                FavoritesButton { isShowingFavorites = true }
                NotificationsButton { isShowingActiveNotifications = true }
                CameraButton { isShowingCameraView = true }
            }
            .frame(height: 60)

            Spacer()
            
            if !iap.removedAds {
                RemoveAdsButton {
                    if let product = iap.products.first {
                        iap.purchase(product)
                    }
                }
                
                BannerAdView()
                    .frame(width: 320, height: 100)
            }
        }
        .padding(40)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .overlay {
            if iap.isLoading || licensePlateViewModel.isLoading {
                ZStack {
                    Color.black.opacity(0.4).ignoresSafeArea()
                    ProgressView("Bezig…")
                        .progressViewStyle(CircularProgressViewStyle())
                        .tint(.white)
                }
            }
        }
        .alert("Foutmelding", isPresented: .constant(iap.errorMessage != nil || licensePlateViewModel.errorMessage != nil)) {
            Button("OK") {
                iap.errorMessage = nil
                licensePlateViewModel.errorMessage = nil
            }
        } message: {
            Text(iap.errorMessage ?? licensePlateViewModel.errorMessage ?? "")
        }
        .sheet(isPresented: $isShowingRecents) {
            RecentsView { licensePlate in
                licensePlateViewModel.licensePlate = licensePlate
                licensePlateViewModel.checkLicensePlate()
                isShowingRecents = false
            }
        }
        .sheet(isPresented: $isShowingFavorites) {
            FavoritesView { licensePlate in
                licensePlateViewModel.licensePlate = licensePlate
                licensePlateViewModel.checkLicensePlate()
                isShowingFavorites = false
            }
        }
        .sheet(isPresented: $isShowingActiveNotifications) {
            NotificationsView { licensePlate in
                licensePlateViewModel.licensePlate = licensePlate
                licensePlateViewModel.checkLicensePlate()
                isShowingActiveNotifications = false
            }
        }
        .sheet(isPresented: $isShowingCameraView) {
            Text("Camera")
                .font(.title)
                .padding()
        }
        .sheet(item: $licensePlateViewModel.vehicle) { voertuig in
            Text("Resultaat: \(licensePlateViewModel.licensePlate)")
                .font(.title2)
                .padding()
        }
        .onAppear {
            iap.loadProducts()
            favoritesViewModel.addFavoritePlate("AB123C") // testfavorite
        }
    }
}

#Preview {
    ContentView()
}
