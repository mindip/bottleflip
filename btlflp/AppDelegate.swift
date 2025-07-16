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
