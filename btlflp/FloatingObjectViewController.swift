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
        createShadowPlane()
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
        // Create a crystal-like floating object
        let geometry = SCNCylinder(radius: 0.8, height: 2.0)
        geometry.radialSegmentCount = 8 // Octagonal for crystal look
        
        floatingObject = SCNNode(geometry: geometry)
        
        // Create material with crystal-like properties
        let material = SCNMaterial()
        material.diffuse.contents = UIColor(red: 0.3, green: 0.7, blue: 0.9, alpha: 1.0)
        material.specular.contents = UIColor.white
        material.shininess = 100
        material.metalness.contents = 0.3
        material.roughness.contents = 0.1
        
        // Add subtle emission for magical glow
        material.emission.contents = UIColor(red: 0.1, green: 0.2, blue: 0.3, alpha: 1.0)
        
        geometry.materials = [material]
        
        // Position object to appear floating above screen
        floatingObject.position = SCNVector3(0, 1.5, 0)
        
        scene.rootNode.addChildNode(floatingObject)
        
        // Add particle system for magical effect
        addParticleSystem()
    }
    
    func addParticleSystem() {
        let particleSystem = SCNParticleSystem()
        particleSystem.particleColor = UIColor(red: 0.4, green: 0.8, blue: 1.0, alpha: 0.8)
        particleSystem.particleSize = 0.05
        particleSystem.birthRate = 20
        particleSystem.particleLifeSpan = 2.0
        particleSystem.emissionDuration = 0
        particleSystem.spreadingAngle = 45
        particleSystem.particleVelocity = 0.5
        particleSystem.particleVelocityVariation = 0.2
        
        // Attach particles to the floating object
        floatingObject.addParticleSystem(particleSystem)
    }
    
    func createShadowPlane() {
        // Create a plane to represent the phone screen surface
        let planeGeometry = SCNPlane(width: 6, height: 10)
        shadowPlane = SCNNode(geometry: planeGeometry)
        
        // Create shadow material
        let shadowMaterial = SCNMaterial()
        shadowMaterial.diffuse.contents = UIColor(white: 0.1, alpha: 0.3)
        shadowMaterial.isDoubleSided = true
        shadowMaterial.transparency = 0.3
        
        planeGeometry.materials = [shadowMaterial]
        
        // Position plane below the floating object
        shadowPlane.position = SCNVector3(0, -2.5, 0)
        shadowPlane.eulerAngles = SCNVector3(-Float.pi/2, 0, 0) // Rotate to lie flat
        
        scene.rootNode.addChildNode(shadowPlane)
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
