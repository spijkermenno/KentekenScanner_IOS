/*
See LICENSE folder for this sample’s licensing information.

Abstract:
Vision view controller.
			Recognizes text using a Vision VNRecognizeTextRequest request handler in pixel buffers from an AVCaptureOutput.
			Displays bounding boxes around recognized text results in real time.
*/

import Foundation
import UIKit
import AVFoundation
import Vision

class VisionViewController: CameraViewController {
	var request: VNRecognizeTextRequest!
	// Temporal string tracker
	let numberTracker = StringTracker()
    var ctx: ViewController!
    var requesting = false
	
	override func viewDidLoad() {
		// Set up vision request before letting ViewController set up the camera
		// so that it exists when the first buffer is received.
		request = VNRecognizeTextRequest(completionHandler: recognizeTextHandler)

		super.viewDidLoad()
    }
    
    func setContext(ctx_: ViewController) {
        self.ctx = ctx_
    }
	
	// MARK: - Text recognition
	
	// Vision recognition handler.
	func recognizeTextHandler(request: VNRequest, error: Error?) {
	
		guard let results = request.results as? [VNRecognizedTextObservation] else {
			return
		}
        
		
            let maximumCandidates = 1
            var possibleKenteken = ""
            
            for visionResult in results {
                guard let candidate = visionResult.topCandidates(maximumCandidates).first else {
                    continue
                }
                var query = ""
                
                if candidate.string.count == 3 || candidate.string.count == 2 || candidate.string.count == 4 {
                    if possibleKenteken != "" {
                        if KentekenFactory().getSidecode(possibleKenteken + candidate.string) != -2 {
                            query = possibleKenteken + candidate.string
                        }
                    } else {
                        possibleKenteken = candidate.string
                    }
                } else if candidate.string.count == 6 || candidate.string.count == 8 {
                    query = candidate.string
                }
                            
                if query != "" && KentekenFactory().getSidecode(query) != -2 {
                    let kenteken: String = query

                    DispatchQueue.main.async {
                        self.previewView.session?.stopRunning()
                        self.dismiss(animated: true, completion: nil)
                        
                        // request kenteken
                        APIManager(viewController: self.ctx).getGekentekendeVoertuig(kenteken: kenteken) { result in
                            switch result {
                            case .success(let gekentekendeVoertuig):
                                DispatchQueue.main.async {
                                   // kenteken retrieved
                                    print("retrieved... \(gekentekendeVoertuig.kenteken)")
                                }
                            case .failure(let error):
                                print("Error: \(error)")
                            }
                        }
                        
                        //self.networkReqHandler.kentekenRequest(kenteken: kenteken, view: self.ctx)
                        
                        GoogleAnalyticsHelper().logEventMultipleItems(
                            eventkey: "search",
                            items: [
                                "type" : "camera",
                                "kenteken" : kenteken,
                                "uuid" : UUID().uuidString
                            ]
                        )
                    }
                }
            }
	}
	
	override func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
		if let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) {
			// Configure for running in real-time.
			request.recognitionLevel = .fast
			// Language correction won't help recognizing phone numbers. It also
			// makes recognition slower.
			request.usesLanguageCorrection = false
			// Only run on the region of interest for maximum speed.
			request.regionOfInterest = regionOfInterest
			
			let requestHandler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, orientation: textOrientation, options: [:])
			do {
				try requestHandler.perform([request])
			} catch {
				print(error)
			}
		}
	}
	
	// MARK: - Bounding box drawing
	
	// Draw a box on screen. Must be called from main queue.
	var boxLayer = [CAShapeLayer]()
	func draw(rect: CGRect, color: CGColor) {
		let layer = CAShapeLayer()
		layer.opacity = 0.5
		layer.borderColor = color
		layer.borderWidth = 1
		layer.frame = rect
		boxLayer.append(layer)
		previewView.videoPreviewLayer.insertSublayer(layer, at: 1)
	}
	
	// Remove all drawn boxes. Must be called on main queue.
	func removeBoxes() {
		for layer in boxLayer {
			layer.removeFromSuperlayer()
		}
		boxLayer.removeAll()
	}
	
	typealias ColoredBoxGroup = (color: CGColor, boxes: [CGRect])
	
	// Draws groups of colored boxes.
	func show(boxGroups: [ColoredBoxGroup]) {
		DispatchQueue.main.async {
			let layer = self.previewView.videoPreviewLayer
			self.removeBoxes()
			for boxGroup in boxGroups {
				let color = boxGroup.color
				for box in boxGroup.boxes {
					let rect = layer.layerRectConverted(fromMetadataOutputRect: box.applying(self.visionToAVFTransform))
					self.draw(rect: rect, color: color)
				}
			}
		}
	}
}
