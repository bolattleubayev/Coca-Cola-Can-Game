//
//  ViewController.swift
//  Coca Cola Can Game
//
//  Created by macbook on 3/10/20.
//  Copyright © 2020 bolattleubayev. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate, SCNPhysicsContactDelegate, ARSessionDelegate {
    
    // MARK: - Variables
    
    private var cansAdded: Bool = false
    private var score: Int = 0
    private var planeGuidingNodes = [SCNNode]()
    private var container: SCNNode!
    private var level: Int = 0
    
    var directionalLightNode: SCNNode?
    var ambientLightNode: SCNNode?
    
    // MARK: - Outlets and Actions
    
    @IBOutlet var sceneView: ARSCNView!
    
    @IBOutlet weak var instructionLabel: UILabel!
    
    @IBAction func restartButtonPressed(_ sender: UIButton) {
        
        // Remove all previously added nodes
        for childNode in sceneView.scene.rootNode.childNodes {
            childNode.removeFromParentNode()
        }
        
        // Add bins
        cansAdded = false
        
        score = 0
        
        //instructionLabel.text = "Счёт: \(self.score)"
        
    }
    
    @IBAction func levelChanged(_ sender: UISegmentedControl) {
        
        // Remove all previously added nodes
        for childNode in sceneView.scene.rootNode.childNodes {
            childNode.removeFromParentNode()
        }
        
        // Add bins
        cansAdded = false
        
        DispatchQueue.main.async {
          self.level = sender.selectedSegmentIndex
        }
        
    }
    
    
    @IBAction func screenTapped(_ sender: UITapGestureRecognizer) {
        
        // Adding contact delegate
        self.sceneView.scene.physicsWorld.contactDelegate = self
        
        if !cansAdded {
            putCans(sender: sender, level: level)
        } else {
            createBall()
        }
        
    }
    
    // MARK: - Functions
    
    func session(_ session: ARSession, didUpdate frame: ARFrame) {
      guard let lightEstimate = frame.lightEstimate else { return }
      guard cansAdded else { return } //1
      ambientLightNode?.light?.intensity = lightEstimate.ambientIntensity * 0.5
      directionalLightNode?.light?.intensity = lightEstimate.ambientIntensity
    }
    
    // Get camera position and direction
    private func getCameraPoitionAndDirection() -> (SCNVector3, SCNVector3) {
        
        if let currentFrame = self.sceneView.session.currentFrame {
            
            let matrixOfCurrentFrame = SCNMatrix4(currentFrame.camera.transform)
            
            let orientationOfCamera = SCNVector3(-1*matrixOfCurrentFrame.m31, -1*matrixOfCurrentFrame.m32, -1*matrixOfCurrentFrame.m33)
            
            let positionOfCamera = SCNVector3(matrixOfCurrentFrame.m41, matrixOfCurrentFrame.m42, matrixOfCurrentFrame.m43)
            
            return (orientationOfCamera, positionOfCamera)
        }
        
        return (SCNVector3(-1, 0, 0), SCNVector3(0, -0.6, 0))
    }
    
    func putCans(sender: UITapGestureRecognizer, level: Int) {
        
        var scene = SCNScene()
        
        // Select the level
        if level == 0 {
            scene = SCNScene(named: "art.scnassets/canPyramid.scn")!
        } else if level == 1{
            scene = SCNScene(named: "art.scnassets/canPyramid2.scn")!
        } else {
            scene = SCNScene(named: "art.scnassets/boxPyramid.scn")!
        }
        
        // Set the scene to the view
        sceneView.scene = scene
        
        // Manage touches
        let touchLocation = sender.location(in: sceneView)
        let hitTestResult = sceneView.hitTest(touchLocation, types: [.existingPlaneUsingExtent])
        
        if let result = hitTestResult.first {
            
            // Putting the pyramid
            container = sceneView.scene.rootNode.childNode(withName: "container", recursively: false)!
            container.position = SCNVector3(x: result.worldTransform.columns.3.x, y: result.worldTransform.columns.3.y, z: result.worldTransform.columns.3.z)
            
            container.isHidden = false
            ambientLightNode = container.childNode(withName: "ambientLight", recursively: false)
            directionalLightNode = container.childNode(withName: "directionalLight", recursively: false)
            cansAdded = true
        }
    }
    
    // Create balls
    func createBall() {
        // Get position and orientation of the camera
        let (direction, position) = getCameraPoitionAndDirection()
        
        // Setting size and texture of the thrown sphere
        let sphere = SCNSphere(radius: 0.07)
        sphere.firstMaterial?.diffuse.contents = UIColor.red
        sphere.firstMaterial?.emission.contents = UIColor.white
        
        // Setting sphere's position
        let sphereNode = SCNNode(geometry: sphere)
        sphereNode.position = position
        
        // Applying physical body values
        sphereNode.physicsBody = SCNPhysicsBody(type: .dynamic, shape: nil)
        
        sphereNode.physicsBody?.categoryBitMask = 3
        sphereNode.physicsBody?.contactTestBitMask = 1
        
        // The sphere will disappear after 9 seconds from the scene
        sphereNode.runAction(SCNAction.sequence([SCNAction.wait(duration: 9.0), SCNAction.removeFromParentNode()]))
        
        // Applying force
        let force = SCNVector3(9*direction.x, 9*direction.y, 9*direction.z)
        sphereNode.physicsBody?.applyForce(force, asImpulse: true)
        
        sceneView.scene.rootNode.addChildNode(sphereNode)
    }
    
    // Create horizontal areas
    func createHorizontalArea(planeAnchor: ARPlaneAnchor) -> SCNNode {
        let node = SCNNode()
        
        let geometry = SCNPlane(width: CGFloat(planeAnchor.extent.x), height: CGFloat(planeAnchor.extent.z))
        geometry.firstMaterial?.diffuse.contents = UIColor.red
        node.geometry = geometry
        
        // Rotating the plane to be parallel to the horizon
        node.eulerAngles.x = -.pi / 2
        // Setting opacity to 0.5 to make it transparent
        node.opacity = 0.5
        
        return node
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Enable lighting
        sceneView.autoenablesDefaultLighting = true
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        sceneView.session.delegate = self
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        
        // Enable plane detection
        configuration.planeDetection = .horizontal
        
        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }

    // MARK: - ARSCNViewDelegate
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        guard let planeAnchor = anchor as? ARPlaneAnchor else {
            return
        }
        
        if planeAnchor.alignment == .vertical {
            //let verticalPlane = createVerticalArea(planeAnchor: planeAnchor)
            //node.addChildNode(verticalPlane)
        } else {
            if !cansAdded {
                let horizontalPlane = createHorizontalArea(planeAnchor: planeAnchor)
                node.addChildNode(horizontalPlane)
                planeGuidingNodes.append(horizontalPlane)
            }
        }
    }
    
    // Merging planes that are close to each other
   func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
       guard let planeAnchor = anchor as? ARPlaneAnchor else {
           return
       }
       
       for node in node.childNodes {
           node.position = SCNVector3(planeAnchor.center.x, 0, planeAnchor.center.z)
           if let plane = node.geometry as? SCNPlane {
               plane.width = CGFloat(planeAnchor.extent.x)
               plane.height = CGFloat(planeAnchor.extent.z)
           }
       }
   }
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        
    }
    
    // MARK: - Collision handling
    
    func physicsWorld(_ world: SCNPhysicsWorld, didBegin contact: SCNPhysicsContact) {
        
        if contact.nodeA.physicsBody?.categoryBitMask == 1
            || contact.nodeB.physicsBody?.categoryBitMask == 1 {
            
            // Dispatching to main queue asynchronously
            DispatchQueue.main.async {
                contact.nodeA.removeFromParentNode()
                contact.nodeB.removeFromParentNode()
                
                // Score counting logic
                if ((contact.nodeA.name! == "canBasket" && contact.nodeB.name! == "can") || (contact.nodeA.name! == "can" && contact.nodeB.name! == "canBasket")) {
                    self.score += 10
                    //self.scoreLabel.text = "Счёт: \(self.score)"
                } else if ((contact.nodeA.name! == "bottleBasket" && contact.nodeB.name! == "bottle") || (contact.nodeA.name! == "bottle" && contact.nodeB.name! == "bottleBasket")) {
                    self.score += 10
                    //self.scoreLabel.text = "Счёт: \(self.score)"
                } else {
                    //self.scoreLabel.text = "Счёт: \(self.score)"
                }
                
            }
            
            // Crash animation
            let  crash = SCNParticleSystem(named: "collisionExplosion", inDirectory: nil)
            contact.nodeB.addParticleSystem(crash!)
        }
    }
    
}
