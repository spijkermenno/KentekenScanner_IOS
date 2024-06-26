import UIKit

typealias HTTPHeaders = [String: String]

final class ImageUploader {

    let uploadImage: UIImage
    let number: Int
    let boundary = "example.boundary.\(ProcessInfo.processInfo.globallyUniqueString)"
    let fieldName = "image"
    let kentekenID: Int
        
    let endpointURI: URL

    var parameters: Parameters? {
        return [
            "number": number
        ]
    }
    var headers: HTTPHeaders {
        return [
            "Content-Type": "multipart/form-data; boundary=\(boundary)",
            "Accept": "application/json"
        ]
    }

    init(uploadImage: UIImage, number: Int, kentekenID: Int) {
        self.uploadImage = uploadImage
        self.number = number
        self.kentekenID = kentekenID
        endpointURI = .init(string: "https://pixelwonders.nl/api/gekentekende-voertuigen/\(kentekenID)/upload-image")!
    }
    
    func uploadImage(completionHandler: @escaping (ImageUploadResult) -> Void) {
        print("image uploader...")
        let imageData = uploadImage.jpegData(compressionQuality: 0.2)!
        let mimeType = imageData.mimeType!

        var request = URLRequest(url: endpointURI, method: "POST", headers: headers)
        request.httpBody = createHttpBody(binaryData: imageData, mimeType: mimeType)
        
        let session = URLSession(configuration: .default)
        let task = session.dataTask(with: request) { (data, urlResponse, error) in
            let statusCode = (urlResponse as? HTTPURLResponse)?.statusCode ?? 0
            if let data = data, case (200..<300) = statusCode {
                do {
                    let value = try Response(from: data, statusCode: statusCode)
                    AnalyticsManager.shared.trackEvent(
                        eventName: .imageUpload,
                        parameters: ["success": true]
                    )
                    
                    completionHandler(.success(value))
                } catch {
                    let _error = ResponseError(statusCode: statusCode, error: AnyError(error))
                    AnalyticsManager.shared.trackEvent(
                        eventName: .imageUpload,
                        parameters: ["success": false]
                    )
                    
                    completionHandler(.failure(_error))
                }
            }
            _ = error ?? NSError(domain: "Unknown", code: 499, userInfo: nil)
            let _error = ResponseError(statusCode: statusCode, error: AnyError(error))
            completionHandler(.failure(_error))
        }
        task.resume()
    }
    
    private func createHttpBody(binaryData: Data, mimeType: String) -> Data {
        var postContent = "--\(boundary)\r\n"
        let fileName = "\(UUID().uuidString).jpg"
        postContent += "Content-Disposition: form-data; name=\"\(fieldName)\"; filename=\"\(fileName)\"\r\n"
        postContent += "Content-Type: \(mimeType)\r\n\r\n"

        var data = Data()
        guard let postData = postContent.data(using: .utf8) else { return data }
        data.append(postData)
        data.append(binaryData)

        if let parameters = parameters {
            var content = ""
            parameters.forEach {
                content += "\r\n--\(boundary)\r\n"
                content += "Content-Disposition: form-data; name=\"\($0.key)\"\r\n\r\n"
                content += "\($0.value)"
            }
            if let postData = content.data(using: .utf8) { data.append(postData) }
        }

        guard let endData = "\r\n--\(boundary)--\r\n".data(using: .utf8) else { return data }
        data.append(endData)
        return data
    }
}

extension URLRequest {

    init(url: URL, method: String, headers: HTTPHeaders?) {
        self.init(url: url)
        httpMethod = method

        if let headers = headers {
            headers.forEach {
                setValue($0.1, forHTTPHeaderField: $0.0)
            }
        }
    }
}

extension Data {

    var mimeType: String? {
        var values = [UInt8](repeating: 0, count: 1)
        copyBytes(to: &values, count: 1)

        switch values[0] {
        case 0xFF:
            return "image/jpeg"
        case 0x89:
            return "image/png"
        case 0x47:
            return "image/gif"
        case 0x49, 0x4D:
            return "image/tiff"
        default:
            return nil
        }
    }
}

struct AnyError: Error {

    let error: Error?

    init(_ error: Error?) {
        self.error = error
    }
}
