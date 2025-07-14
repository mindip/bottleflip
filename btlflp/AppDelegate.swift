//
//  AppDelegate.swift
//  btlflp
//
//  Created by mindipdip on 7/14/25.
//
import UIKit
import SceneKit


// MARK: - App Delegate
@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    var orientationLock = UIInterfaceOrientationMask.portrait
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        window = UIWindow(frame: UIScreen.main.bounds)
        let floatingVC = FloatingObjectViewController()
        window?.rootViewController = floatingVC
        window?.makeKeyAndVisible()
        return true
    }
    
    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        return orientationLock
    }
}

// MARK: - Enhanced Floating Object with Touch Interaction
class EnhancedFloatingObjectViewController: FloatingObjectViewController {
    
    override func setupSceneView() {
        super.setupSceneView()
        
        // Add tap gesture for interaction
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        sceneView.addGestureRecognizer(tapGesture)
        
        // Add pan gesture for subtle interaction
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        sceneView.addGestureRecognizer(panGesture)
    }
    
    @objc func handleTap(_ gestureRecognizer: UITapGestureRecognizer) {
        let location = gestureRecognizer.location(in: sceneView)
        let hitResults = sceneView.hitTest(location, options: [:])
        
        if let hitResult = hitResults.first, hitResult.node == floatingObject {
            // Object was tapped - create ripple effect
            createRippleEffect(at: hitResult.worldCoordinates)
            
            // Temporary scale animation
            let scaleUp = SCNAction.scale(to: 1.2, duration: 0.1)
            let scaleDown = SCNAction.scale(to: 1.0, duration: 0.1)
            let sequence = SCNAction.sequence([scaleUp, scaleDown])
            floatingObject.runAction(sequence)
        }
    }
    
    @objc func handlePan(_ gestureRecognizer: UIPanGestureRecognizer) {
        let translation = gestureRecognizer.translation(in: sceneView)
        
        // Subtle object movement based on pan
        let sensitivity: Float = 0.001
        let deltaX = Float(translation.x) * sensitivity
        let deltaY = Float(-translation.y) * sensitivity
        
        // Apply subtle movement (don't break the illusion)
        floatingObject.position.x += deltaX
        floatingObject.position.y += deltaY
        
        // Reset translation
        gestureRecognizer.setTranslation(CGPoint.zero, in: sceneView)
        
        // Gradually return to center
        if gestureRecognizer.state == .ended {
            let returnAction = SCNAction.move(to: SCNVector3(0, 1.5, 0), duration: 1.0)
            returnAction.timingMode = .easeOut
            floatingObject.runAction(returnAction)
        }
    }
    
    func createRippleEffect(at position: SCNVector3) {
        // Create a ripple effect when object is touched
        let rippleGeometry = SCNTorus(ringRadius: 0.5, pipeRadius: 0.05)
        let rippleNode = SCNNode(geometry: rippleGeometry)
        
        let material = SCNMaterial()
        material.diffuse.contents = UIColor(red: 0.4, green: 0.8, blue: 1.0, alpha: 0.8)
        material.emission.contents = UIColor(red: 0.2, green: 0.4, blue: 0.6, alpha: 1.0)
        rippleGeometry.materials = [material]
        
        rippleNode.position = position
        scene.rootNode.addChildNode(rippleNode)
        
        // Animate ripple expansion and fade
        let expandAction = SCNAction.scale(to: 3.0, duration: 0.8)
        let fadeAction = SCNAction.fadeOut(duration: 0.8)
        let groupAction = SCNAction.group([expandAction, fadeAction])
        let removeAction = SCNAction.removeFromParentNode()
        let sequence = SCNAction.sequence([groupAction, removeAction])
        
        rippleNode.runAction(sequence)
    }
}

// MARK: - Performance Optimization Tips
extension FloatingObjectViewController {
    
    func optimizeForMobile() {
        // Reduce particle count for better performance
        sceneView.preferredFramesPerSecond = 60
        
        // Enable automatic lighting for better performance
        sceneView.autoenablesDefaultLighting = false // We're using custom lighting
        
        // Optimize render settings
        sceneView.rendersContinuously = true
        sceneView.isTemporalAntialiasingEnabled = true
        
        // Disable unnecessary features
        sceneView.showsStatistics = false
        sceneView.debugOptions = []
    }
    
    func addPerformanceMonitoring() {
        // Monitor frame rate
        let displayLink = CADisplayLink(target: self, selector: #selector(frameUpdate))
        displayLink.add(to: .main, forMode: .common)
    }
    
    @objc func frameUpdate() {
        // You can monitor performance here
        // Log frame drops or adjust quality dynamically
    }
}

// MARK: - Project Setup Instructions
/*
1. Create new iOS project in Xcode
2. Set minimum iOS version to 13.0+ for best SceneKit support
3. Add SceneKit framework to your project
4. Replace default view controller with FloatingObjectViewController
5. Configure Info.plist as shown above
6. Test on physical device (iPhone 12 or newer recommended)
7. For App Store: Add app icons, privacy descriptions, etc.

Key Project Settings:
- Target: iOS 13.0+
- Orientation: Portrait only
- Frameworks: SceneKit, UIKit
- Capabilities: None required (unless adding AR later)
*/
