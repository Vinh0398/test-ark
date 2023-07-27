/*
See LICENSE folder for this sample’s licensing information.

Abstract:
Manages the process of testing detection after scanning an object.
*/

import Foundation
import ARKit

// This class represents a test run of a scanned object.
class TestRun {
    
    // The ARReferenceObject to be tested in this run.
    //var referenceObject: ARReferenceObject?
    
    //private(set) var detectedObject: DetectedObject?
    
    //var detections = 0
    //var lastDetectionDelayInSeconds: Double = 0
    var averageDetectionDelayInSeconds: Double = 0
    
    var resultDisplayDuration: Double {
        // The recommended display duration for detection results
        // is the average time it takes to detect it, plus 200 ms buffer.
        return averageDetectionDelayInSeconds + 0.2
    }
    
    private var sceneView: ARSCNView
    
    init(sceneView: ARSCNView) {
        self.sceneView = sceneView
    }
    
    deinit {
        if self.sceneView.session.configuration as? ARWorldTrackingConfiguration != nil {
            // Make sure we switch back to an object scanning configuration & no longer
            // try to detect the object.
            let configuration = ARObjectScanningConfiguration()
            configuration.planeDetection = .horizontal
            self.sceneView.session.run(configuration, options: .resetTracking)
        }
    }

    //var noDetectionTimer: Timer?
    
    func getSizeObject(boudingbox: BoundingBox?) -> String{
        let width = String(format: "%.2f", boudingbox?.extent.x ?? 0 * 100)
        let height = String(format: "%.2f", boudingbox?.extent.y ?? 0 * 100)
        let length = String(format: "%.2f", boudingbox?.extent.z ?? 0 * 100)
        return "width \(width)cm, " + "height \(height)cm, " + "length \(length)cm."
    }
}
