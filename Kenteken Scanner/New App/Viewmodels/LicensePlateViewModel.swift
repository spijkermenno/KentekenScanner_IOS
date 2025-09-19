//
//  LicensePlateViewModel.swift
//  Kenteken Scanner
//
//  Created by Menno Spijker on 19/09/2025.
//

import Foundation

@MainActor
final class LicensePlateViewModel: ObservableObject {
    @Published var licensePlate: String = ""
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var vehicle: VehicleItem?

    private let service: LicensePlateService
    private let addToRecents: AddToRecentsUseCase
    private let validateLicensePlateUseCase: ValidateLicensePlateUseCase
    private let logEventUseCase: LogAnalyticsEventUseCase
    private let logErrorUseCase: LogAnalyticsErrorUseCase

    init(
        service: LicensePlateService = .init(),
        addToRecents: AddToRecentsUseCase = .init(),
        validateLicensePlateUseCase: ValidateLicensePlateUseCase = .init(),
        logEventUseCase: LogAnalyticsEventUseCase = .init(),
        logErrorUseCase: LogAnalyticsErrorUseCase = .init()
    ) {
        self.service = service
        self.addToRecents = addToRecents
        self.validateLicensePlateUseCase = validateLicensePlateUseCase
        self.logEventUseCase = logEventUseCase
        self.logErrorUseCase = logErrorUseCase
    }

    func checkLicensePlate() {
        isLoading = true
        vehicle = nil
        errorMessage = nil

        Task {
            do {
                let formatted = try validateLicensePlateUseCase.execute(licensePlate)
                let result = try await service.fetchLicensePlate(formatted)
                vehicle = VehicleItem(value: result)
                addToRecents(formatted)
                logEventUseCase("search", parameters: ["license_plate": formatted])
            } catch ValidateLicensePlateUseCase.ValidationError.invalidLicensePlate {
                errorMessage = "Ongeldig kenteken."
            } catch {
                errorMessage = "Het kenteken \(licensePlate) kan niet worden gevonden."
                logErrorUseCase("license_plate_search_failed")
            }
            isLoading = false
        }
    }
}
