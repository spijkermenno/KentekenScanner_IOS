import Foundation

enum AnalyticsEventName: String {
    case appOpened = "AppOpened"
    case licensePlateSearch = "LicensePlateSearch"
    case imageUpload = "UploadImage"
    case adImpression = "AdImpression"
    case adClick = "AdClick"
    case licensePlateNotFound = "LicensePlateNotFound"
}

class AnalyticsManager {
    static let shared = AnalyticsManager()

    private let apiBaseURL = "https://pixelwonders.nl/api"
    private let apiEndpoint = "/track-event"
    private let bearerToken = "inqH5JU2nOqj4kK2mXDOd1Uv2SURkPabTEMdkGdJ"

    private init() {}

    func trackEvent(eventName: AnalyticsEventName, parameters: [String: Any]? = nil) {
        print("Tracking event: \(eventName.rawValue)")

        if let parameters = parameters {
            print("Event parameters: \(parameters)")
        }

        // Call the separate function to make the API request
        sendEventToAPI(eventName: eventName, parameters: parameters)
    }

    private func sendEventToAPI(eventName: AnalyticsEventName, parameters: [String: Any]?) {
        // Create the URL for the analytics API endpoint
        let apiUrl = apiBaseURL + apiEndpoint

        // Create the request
        var request = URLRequest(url: URL(string: apiUrl)!)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        // Add Bearer token to the Authorization header
        request.addValue("Bearer \(bearerToken)", forHTTPHeaderField: "Authorization")

        // Prepare the request body
        var requestBody: [String: Any] = ["event_name": eventName.rawValue]
        
        requestBody["uuid"] = StorageHelper().generateAndSaveIDIfNeeded()
        
        if let parameters = parameters {
            requestBody["parameters"] = parameters
        }

        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
        } catch {
            print("Error encoding request body: \(error)")
            return
        }

        // Perform the request
        DispatchQueue.main.async {
            let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
                // Handle the response or error
                if let error = error {
                    print("Error tracking event: \(error)")
                } else {
                    print("Event tracked successfully")
                }
            }

            task.resume()
        }
    }
}

// Example usage:
// AnalyticsManager.shared.trackEvent(eventName: .licensePlateSearch, parameters: ["PlateNumber": "ABC123"])
