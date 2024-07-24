//
//  ViewController.swift
//  RockPaperScissorsS
//
//  Created by 김혁 on 7/20/24.
//

import SwiftUI
import SceneKit
import ARKit
import Vision

struct ARViewContainer: UIViewControllerRepresentable {
    
    @Binding var debugText: String
    @Binding var symbol: String
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func makeUIViewController(context: Context) -> UIViewController {
        let viewController = ARViewController()
        viewController.coordinator = context.coordinator
        return viewController
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        // Update the view controller if needed
    }
    
    class Coordinator: NSObject {
        var parent: ARViewContainer
        
        init(_ parent: ARViewContainer) {
            self.parent = parent
        }
        
        func updateDebugText(_ text: String) {
            DispatchQueue.main.async {
                self.parent.debugText = text
            }
        }
        
        func updateSymbol(_ symbol: String) {
            DispatchQueue.main.async {
                self.parent.symbol = symbol
            }
        }
    }
}

class ARViewController: UIViewController, ARSCNViewDelegate {

    var sceneView: ARSCNView!
    var visionRequests = [VNRequest]()
    let dispatchQueueML = DispatchQueue(label: "com.hw.dispatchqueueml") // A Serial Queue
    
    var coordinator: ARViewContainer.Coordinator?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        sceneView = ARSCNView(frame: self.view.frame)
        self.view.addSubview(sceneView)
        
        // --- ARKIT ---
        sceneView.delegate = self
        sceneView.showsStatistics = true
        let scene = SCNScene()
        sceneView.scene = scene
        
        // --- ML & VISION ---
        guard let selectedModel = try? VNCoreMLModel(for: rps_model().model) else {
            fatalError("Could not load model. Ensure model has been drag and dropped (copied) to XCode Project.")
        }
        
        let classificationRequest = VNCoreMLRequest(model: selectedModel, completionHandler: classificationCompleteHandler)
        classificationRequest.imageCropAndScaleOption = VNImageCropAndScaleOption.centerCrop
        visionRequests = [classificationRequest]
        
        loopCoreMLUpdate()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let configuration = ARWorldTrackingConfiguration()
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        sceneView.session.pause()
    }
    
    func loopCoreMLUpdate() {
        dispatchQueueML.async {
            self.updateCoreML()
            self.loopCoreMLUpdate()
        }
    }
    
    func updateCoreML() {
        let pixbuff : CVPixelBuffer? = (sceneView.session.currentFrame?.capturedImage)
        if pixbuff == nil { return }
        let ciImage = CIImage(cvPixelBuffer: pixbuff!)
        let imageRequestHandler = VNImageRequestHandler(ciImage: ciImage, options: [:])
        
        do {
            try imageRequestHandler.perform(self.visionRequests)
        } catch {
            print(error)
        }
    }
    
    func classificationCompleteHandler(request: VNRequest, error: Error?) {
        if error != nil {
            print("Error: " + (error?.localizedDescription)!)
            return
        }
        guard let observations = request.results else {
            print("No results")
            return
        }
        
        let classifications = observations[0...3]
            .compactMap({ $0 as? VNClassificationObservation })
            .map({ "\($0.identifier) \(String(format:" : %.2f", $0.confidence))" })
            .joined(separator: "\n")
        
        DispatchQueue.main.async {
            self.coordinator?.updateDebugText("TOP 4 PROBABILITIES: \n" + classifications)
            
            var symbol = "❎"
            let topPrediction = classifications.components(separatedBy: "\n")[0]
            let topPredictionName = topPrediction.components(separatedBy: ":")[0].trimmingCharacters(in: .whitespaces)
            let topPredictionScore:Float? = Float(topPrediction.components(separatedBy: ":")[1].trimmingCharacters(in: .whitespaces))
            if (topPredictionScore != nil && topPredictionScore! > 0.01) {
                if (topPredictionName == "Rock") { symbol = "👊" }
                if (topPredictionName == "Scissor") { symbol = "✌️" }
                if (topPredictionName == "Paper") { symbol = "🖐" }
            }
            
            self.coordinator?.updateSymbol(symbol)
        }
    }
}
