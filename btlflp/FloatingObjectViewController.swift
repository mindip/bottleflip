//
//  FloatingObjectViewController.swift
//  btlflp
//
//  Created by mindipdip on 7/14/25.
//


import UIKit
import SceneKit

class FloatingObjectViewController: UIViewController {
    
    var sceneView: SCNView!
    var scene: SCNScene!
    var cameraNode: SCNNode!
    var floatingObject: SCNNode!
    var shadowPlane: SCNNode!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupSceneView()
        setupScene()
        setupCamera()
        setupLighting()
        createFloatingObject()
    }
    
    func setupSceneView() {
        sceneView = SCNView(frame: view.bounds)
        sceneView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        sceneView.backgroundColor = UIColor.black
        sceneView.allowsCameraControl = false // Disable user camera control
        sceneView.showsStatistics = false // Hide debug info
        view.addSubview(sceneView)
    }
    
    func setupScene() {
        scene = SCNScene()
        sceneView.scene = scene
        
        // Set up environment for better lighting
        scene.background.contents = UIColor(red: 0.05, green: 0.05, blue: 0.1, alpha: 1.0)
        
        // Add subtle fog for depth perception
        scene.fogStartDistance = 5
        scene.fogEndDistance = 15
        scene.fogColor = UIColor(red: 0.1, green: 0.1, blue: 0.2, alpha: 1.0)
    }
    
    func setupCamera() {
        cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        
        // Position camera for 2-foot viewing distance
        // Portrait phone screen viewed from 24 inches
        cameraNode.position = SCNVector3(0, 0, 8)
        cameraNode.camera!.fieldOfView = 75
        
        // Slight downward angle to simulate looking down at phone
        cameraNode.eulerAngles = SCNVector3(-0.1, 0, 0)
        
        scene.rootNode.addChildNode(cameraNode)
    }
    
    func setupLighting() {
        // Main directional light (simulating room lighting)
        let lightNode = SCNNode()
        lightNode.light = SCNLight()
        lightNode.light!.type = .directional
        lightNode.light!.color = UIColor.white
        lightNode.light!.intensity = 1000
        lightNode.position = SCNVector3(2, 4, 6)
        lightNode.eulerAngles = SCNVector3(-0.4, -0.5, 0)
        
        // Enable shadows for realistic effect
        lightNode.light!.castsShadow = true
        lightNode.light!.shadowRadius = 3
        lightNode.light!.shadowColor = UIColor(white: 0, alpha: 0.5)
        
        scene.rootNode.addChildNode(lightNode)
        
        // Add fill light for better illumination
        let fillLightNode = SCNNode()
        fillLightNode.light = SCNLight()
        fillLightNode.light!.type = .directional
        fillLightNode.light!.color = UIColor(red: 0.8, green: 0.9, blue: 1.0, alpha: 1.0)
        fillLightNode.light!.intensity = 300
        fillLightNode.position = SCNVector3(-2, 2, 4)
        fillLightNode.eulerAngles = SCNVector3(-0.8, 0.5, 0)
        
        scene.rootNode.addChildNode(fillLightNode)
        
        // Ambient light for overall scene illumination
        let ambientLightNode = SCNNode()
        ambientLightNode.light = SCNLight()
        ambientLightNode.light!.type = .ambient
        ambientLightNode.light!.color = UIColor(red: 0.2, green: 0.3, blue: 0.4, alpha: 1.0)
        ambientLightNode.light!.intensity = 100
        
        scene.rootNode.addChildNode(ambientLightNode)
    }
    
    func createFloatingObject() {
        // Load the Fiji water bottle USDZ model
        guard let modelScene = SCNScene(named: "art.scnassets/Fiji_Water_Bottle.usdz") else {
            print("Could not load Fiji water bottle model")
            // Fallback to cylinder if model fails to load
            createFallbackObject()
            return
        }
        
        print("✅ Successfully loaded Fiji water bottle model")
        
        // Get the root node or first child node
        floatingObject = modelScene.rootNode.childNodes.first ?? modelScene.rootNode
        
        // Debug: Print model info
        print("Model children count: \(modelScene.rootNode.childNodes.count)")
        print("FloatingObject node: \(floatingObject)")
        
        // Get the bounding box to understand the model's size
        let (min, max) = floatingObject.boundingBox
        print("Model bounding box: min=\(min), max=\(max)")
        
        // Position object close to camera - positive Z moves toward viewer
        floatingObject.position = SCNVector3(0, -3, 3)
        
        // Try different scales based on bounding box
        let modelHeight = max.y - min.y
        let modelWidth = max.x - min.x
        print("Model dimensions: height=\(modelHeight), width=\(modelWidth)")
        
        let targetHeight: Float = 2.0
        let scaleFactorForHeight = targetHeight / modelHeight
        print("Calculated scale factor: \(scaleFactorForHeight)")
        
        floatingObject.scale = SCNVector3(scaleFactorForHeight, scaleFactorForHeight, scaleFactorForHeight)
        
        scene.rootNode.addChildNode(floatingObject)
    }

    func createFallbackObject() {
        // Fallback crystal object if model loading fails
        let geometry = SCNCylinder(radius: 0.8, height: 2.0)
        geometry.radialSegmentCount = 8

        floatingObject = SCNNode(geometry: geometry)

        let material = SCNMaterial()
        material.diffuse.contents = UIColor(red: 0.3, green: 0.7, blue: 0.9, alpha: 1.0)
        material.specular.contents = UIColor.white
        material.shininess = 100
        material.metalness.contents = 0.3
        material.roughness.contents = 0.1
        material.emission.contents = UIColor(red: 0.1, green: 0.2, blue: 0.3, alpha: 1.0)
        
        geometry.materials = [material]
        floatingObject.position = SCNVector3(0, 1.5, 0)
        
        scene.rootNode.addChildNode(floatingObject)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Lock orientation to portrait for optimal viewing
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            appDelegate.orientationLock = .portrait
        }
    }
    
    override var prefersStatusBarHidden: Bool {
        return true // Hide status bar for full immersion
    }
}

// MARK: - App Delegate Extension for Orientation Lock
extension AppDelegate {
    var restrictRotation: UIInterfaceOrientationMask {
        get {
            return self.orientationLock
        }
        set {
            self.orientationLock = newValue
        }
    }
    
}

private struct AssociatedKeys {
    static var orientationLock = "orientationLock"
}
