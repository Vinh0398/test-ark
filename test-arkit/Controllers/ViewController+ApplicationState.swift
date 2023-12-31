/*
See LICENSE folder for this sample’s licensing information.

Abstract:
Management of the UI steps for scanning an object in the main view controller.
*/

import Foundation
import ARKit
import SceneKit

extension ViewController {
    
    enum State {
        case startARSession
        case notReady
        case scanning
        case testing
    }
    
    /// - Tag: ARObjectScanningConfiguration
    // The current state the application is in
    var state: State {
        get {
            return self.internalState
        }
        set {
            // 1. Check that preconditions for the state change are met.
            var newState = newValue
            switch newValue {
            case .startARSession:
                break
            case .notReady:
                // Immediately switch to .ready if tracking state is normal.
//                if let camera = self.sceneView.session.currentFrame?.camera {
//                    switch camera.trackingState {
//                    case .normal:
//                        newState = .scanning
//                    default:
//                        break
//                    }
//                } else {
                    newState = .startARSession
//                }
            case .testing:
                guard scan?.boundingBoxExists == true || referenceObjectToTest != nil else {
                    print("Error: Scan is not ready to be tested.")
                    return
                }
            default:
                break
            }
            
            // 2. Apply changes as needed per state.
            internalState = newState
            
            switch newState {
            case .startARSession:
                print("State: Starting ARSession")
                scan = nil
                testRun = nil
                self.setNavigationBarTitle("")
                instructionsVisible = false
                showBackButton(false)
                nextButton.isEnabled = false
                flashlightButton.isHidden = true
                
                // Make sure the SCNScene is cleared of any SCNNodes from previous scans.
                sceneView.scene = SCNScene()
                
                let configuration = ARObjectScanningConfiguration()
                configuration.planeDetection = .horizontal
                sceneView.session.run(configuration, options: .resetTracking)
                cancelMaxScanTimeTimer()
                cancelMessageExpirationTimer()
            case .notReady:
                print("State: Not ready to scan")
               // scan = nil
                testRun = nil
                self.setNavigationBarTitle("")
                flashlightButton.isHidden = true
                showBackButton(false)
                nextButton.isEnabled = false
                nextButton.setTitle("Next", for: [])
                displayInstruction(Message("Please wait for stable tracking"))
                cancelMaxScanTimeTimer()
            case .testing:
                print("State: Testing")
                self.setNavigationBarTitle("Size of object")
                flashlightButton.isHidden = false
                nextButton.isEnabled = true
                nextButton.setTitle("Done", for: [])
                testRun = TestRun(sceneView: sceneView)
                cancelMaxScanTimeTimer()
            default:
                break
            }
            
            NotificationCenter.default.post(name: ViewController.appStateChangedNotification,
                                            object: self,
                                            userInfo: [ViewController.appStateUserInfoKey: self.state])
        }
    }
    
    @objc
    func scanningStateChanged(_ notification: Notification) {
        guard let scan = notification.object as? Scan, scan === self.scan else { return }
        guard let scanState = notification.userInfo?[Scan.stateUserInfoKey] as? Scan.State else { return }
        
        DispatchQueue.main.async {
            switch scanState {
            case .ready:
                print("State: Ready to scan")
                self.setNavigationBarTitle("Ready to scan")
                self.showBackButton(false)
                self.nextButton.setTitle("Next", for: [])
                self.flashlightButton.isHidden = true
                if scan.ghostBoundingBoxExists {
                    self.displayInstruction(Message("Tap 'Next' to create an approximate bounding box around the object you want to scan."))
                    self.nextButton.isEnabled = true
                } else {
                    self.displayInstruction(Message("Point at a nearby object to scan."))
                    self.nextButton.isEnabled = false
                }
            case .defineBoundingBox:
                print("State: Define bounding box")
                self.displayInstruction(Message("Position and resize bounding box using gestures.\n" +
                                                "Long press sides to push/pull them in or out. "))
                self.setNavigationBarTitle("Define bounding box")
                self.showBackButton(true)
                self.nextButton.isEnabled = scan.boundingBoxExists
                self.flashlightButton.isHidden = true
                self.nextButton.setTitle("Get Size", for: [])
//            case .scanning:
//                //                self.displayInstruction(Message("Scan the object from all sides that you are " +
//                //                                                "interested in. Do not move the object while scanning!"))
//                //                if let boundingBox = scan.scannedObject.boundingBox {
//                //                    self.setNavigationBarTitle("Scan (\(boundingBox.progressPercentage)%)")
//                //                } else {
//                //                    self.setNavigationBarTitle("Scan 0%")
//                //                }
//                //                self.showBackButton(true)
//                //                self.nextButton.isEnabled = true
//                //                self.flashlightButton.isHidden = true
//                self.nextButton.setTitle("Finish", for: [])
//                //                // Disable plane detection (even if no plane has been found yet at this time) for performance reasons.
//                self.sceneView.stopPlaneDetection()
            case .adjustingOrigin:
                self.setNavigationBarTitle("Size")
                self.showBackButton(true)
                self.nextButton.isEnabled = true
                self.flashlightButton.isHidden = true
                self.nextButton.setTitle("Done", for: [])
                self.sceneView.stopPlaneDetection()
            default:
                break
            }
        }
    }
        
        func switchToPreviousState() {
            switch state {
            case .startARSession:
                break
            case .notReady:
                state = .startARSession
                if let scan = scan {
                    switch scan.state {
                    case .ready:
                        restartButtonTapped(self)
                    case .defineBoundingBox:
                        scan.state = .ready
//                    case .scanning:
//                        scan.state = .defineBoundingBox
                    case .adjustingOrigin:
                        scan.state = .defineBoundingBox
                    default:
                        break
                    }
                }
            case .testing:
                state = .notReady
                scan?.state = .adjustingOrigin
            default:
                break
            }
        }
        
        func switchToNextState() {
            switch state {
            case .startARSession:
                state = .notReady
            case .notReady:
                state = .testing
            //case .scanning:
                if let scan = scan {
                    switch scan.state {
                    case .ready:
                        scan.state = .defineBoundingBox
                    case .defineBoundingBox:
                        scan.state = .adjustingOrigin
//                    case .scanning:
//                        scan.state = .adjustingOrigin
                    case .adjustingOrigin:
                        state = .testing
                    default:
                        break
                    }
                }
            case .testing:
                state = .testing
            default:
                break
            }
        }
        
        @objc
        func ghostBoundingBoxWasCreated(_ notification: Notification) {
            if let scan = scan, scan.state == .ready {
                DispatchQueue.main.async {
                    self.nextButton.isEnabled = true
                    self.displayInstruction(Message("Tap 'Next' to create an approximate bounding box around the object you want to scan."))
                }
            }
        }
        
        @objc
        func ghostBoundingBoxWasRemoved(_ notification: Notification) {
            if let scan = scan, scan.state == .ready {
                DispatchQueue.main.async {
                    self.nextButton.isEnabled = false
                    self.displayInstruction(Message("Point at a nearby object to scan."))
                }
            }
        }
        
        @objc
        func boundingBoxWasCreated(_ notification: Notification) {
            if let scan = scan, scan.state == .defineBoundingBox {
                DispatchQueue.main.async {
                    self.nextButton.isEnabled = true
                }
            }
        }
    }
