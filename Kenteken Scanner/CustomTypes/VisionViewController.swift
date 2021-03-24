//
//  VisionViewController.swift
//  Kenteken Scanner
//
//  Created by Menno Spijker on 24/03/2021.
//

import Foundation
import UIKit
import AVFoundation
import Vision

class VisionViewController: CameraViewController {
    var request: VNRecognizeTextRequest!

    override func viewDidLoad() {
        // Set up vision request before letting ViewController set up the camera
        // so that it exists when the first buffer is received.
        request = VNRecognizeTextRequest(completionHandler: recognizeTextHandler)
        
        super.viewDidLoad()
    }
    
    func recognizeTextHandler(request: VNRequest, error: Error?) {
        var numbers = [String]()
        var redBoxes = [CGRect]() // Shows all recognized text lines
        var greenBoxes = [CGRect]() // Shows words that might be serials
        
        guard let results = request.results as? [VNRecognizedTextObservation] else {
            return
        }
            
        let maximumCandidates = 1
        
        for visionResult in results {
            guard let candidate = visionResult.topCandidates(maximumCandidates).first else { continue }
            
            //Prints scanned text
            print(candidate.string)
            
            if let result = candidate.string.extractLicenceplate() {
                print(result)
            }
        }
    }
}


extension String {
    func extractLicenceplate() ->String? {
        if KentekenFactory().getSidecode(self) != -2 {
            return KentekenFactory().format(self)
        }
        return nil
    }
}
