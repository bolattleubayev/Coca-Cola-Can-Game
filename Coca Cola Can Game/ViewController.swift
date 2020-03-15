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
    
    var directionalLightNode: SCNNode?
    var ambientLightNode: SCNNode?
    
    // MARK: - Outlets and Actions
    
    @IBOutlet var sceneView: ARSCNView!
    
    
    @IBAction func screenTapped(_ sender: UITapGestureRecognizer) {
        
        if !cansAdded {
            
            let scene = SCNScene(named: "art.scnassets/canPyramid.scn")!
            
            // Set the scene to the view
            sceneView.scene = scene
            
            let touchLocation = sender.location(in: sceneView)
            let hitTestResult = sceneView.hitTest(touchLocation, types: [.existingPlaneUsingExtent])
            
            if let result = hitTestResult.first {
                //addHoop(result: result)
                //let baseNode = canPyramidBase(result: result)
                
                container = sceneView.scene.rootNode.childNode(withName: "container", recursively: false)!
                container.position = SCNVector3(x: result.worldTransform.columns.3.x, y: result.worldTransform.columns.3.y, z: result.worldTransform.columns.3.z)
                
                container.isHidden = false //3
                ambientLightNode = container.childNode(withName: "ambientLight", recursively: false)
                directionalLightNode = container.childNode(withName: "directionalLight", recursively: false)
                cansAdded = true
            }
        } else {
            
            guard let frame = sceneView.session.currentFrame else { return } //1
            let camMatrix = SCNMatrix4(frame.camera.transform)
            let direction = SCNVector3Make(-camMatrix.m31 * 5.0, -camMatrix.m32 * 10.0, -camMatrix.m33 * 5.0) //2
            let position = SCNVector3Make(camMatrix.m41, camMatrix.m42, camMatrix.m43) //3
            
            let ball = SCNSphere(radius: 0.05) //1
            ball.firstMaterial?.diffuse.contents = UIColor.green
            ball.firstMaterial?.emission.contents = UIColor.green //2
            let ballNode = SCNNode(geometry: ball)
            ballNode.position = position //3
            ballNode.physicsBody = SCNPhysicsBody(type: .dynamic, shape: nil)
            ballNode.physicsBody?.categoryBitMask = 3
            ballNode.physicsBody?.contactTestBitMask = 1 //4
            sceneView.scene.rootNode.addChildNode(ballNode)
            ballNode.runAction(SCNAction.sequence([SCNAction.wait(duration: 10.0), SCNAction.removeFromParentNode()])) //5
            ballNode.physicsBody?.applyForce(direction, asImpulse: true) //6
            
            
        }
        
    }
    
    // MARK: - Functions
    
    func session(_ session: ARSession, didUpdate frame: ARFrame) {
      guard let lightEstimate = frame.lightEstimate else { return }
      guard cansAdded else { return } //1
      ambientLightNode?.light?.intensity = lightEstimate.ambientIntensity * 0.4 //2
      directionalLightNode?.light?.intensity = lightEstimate.ambientIntensity
    }
    
    // Adding tin can holder
    func canPyramidBase(result: ARHitTestResult) -> SCNNode {
        
        // Create base plane to stack cans
        
        let basePlaneNode = SCNNode()
        
        // Get the tap on horizontal plane position
        let horizontalPlanePosition = result.worldTransform.columns.3
        
        let baseGeometry = SCNPlane(width: 1.0, height: 1.0)
        baseGeometry.firstMaterial?.diffuse.contents = UIColor.gray
        basePlaneNode.geometry = baseGeometry
        
        basePlaneNode.eulerAngles.x = -.pi / 2
        
        
        basePlaneNode.position = SCNVector3(horizontalPlanePosition.x, horizontalPlanePosition.y, horizontalPlanePosition.z)
        
        // Adding physics with special options to acknowledge the custom shape
        basePlaneNode.physicsBody = SCNPhysicsBody(type: .static, shape: nil)
        basePlaneNode.physicsBody?.isAffectedByGravity = false
        
        // Collision properties
        basePlaneNode.physicsBody?.categoryBitMask = CollidingObjectType.catchingObject.rawValue
        basePlaneNode.physicsBody?.contactTestBitMask = CollidingObjectType.thrownObject.rawValue
        
        basePlaneNode.name = "basePlane"
        
        for guidingPlane in planeGuidingNodes {
            guidingPlane.removeFromParentNode()
        }
        
        
        
        // Add the node to the scene
        sceneView.scene.rootNode.addChildNode(basePlaneNode)
        
        return basePlaneNode
    }
    
    // Create horizontal areas
    func createHorizontalArea(planeAnchor: ARPlaneAnchor) -> SCNNode {
        let node = SCNNode()
        
        let geometry = SCNPlane(width: CGFloat(planeAnchor.extent.x), height: CGFloat(planeAnchor.extent.z))
        geometry.firstMaterial?.diffuse.contents = UIColor.green
        node.geometry = geometry
        
        node.eulerAngles.x = -.pi / 2
        
        node.opacity = 0.5
        
        return node
    }
    
    private func crateCanForPyramid(pyramidBaseNode: SCNNode, canNumber: Int) {
        
        // Adding can Pyramid
        
        let canScene = SCNScene(named: "art.scnassets/canForPyramid.scn")
        
        guard let canForPyramidNode = canScene?.rootNode.childNode(withName: "Can", recursively: false) else {
            return
        }
        
        // Put cans
        
        
        let basePosition = pyramidBaseNode.position
        
        if canNumber == 0 {
            canForPyramidNode.position = SCNVector3(basePosition.x, basePosition.y + canForPyramidNode.boundingBox.max.y * Float(1), basePosition.z - 0.15 - canForPyramidNode.boundingBox.max.z)
        } else if canNumber == 1 {
            canForPyramidNode.position = SCNVector3(basePosition.x, basePosition.y + canForPyramidNode.boundingBox.max.y * Float(1), basePosition.z)
        } else if canNumber == 2 {
            canForPyramidNode.position = SCNVector3(basePosition.x, basePosition.y + canForPyramidNode.boundingBox.max.y * Float(1), basePosition.z + 0.15 + canForPyramidNode.boundingBox.max.z)
        } else if canNumber == 3 {
            canForPyramidNode.position = SCNVector3(basePosition.x, basePosition.y + canForPyramidNode.boundingBox.max.y * Float(2), basePosition.z - 0.15 - canForPyramidNode.boundingBox.max.z / 2)
        } else if canNumber == 4 {
            canForPyramidNode.position = SCNVector3(basePosition.x, basePosition.y + canForPyramidNode.boundingBox.max.y * Float(2), basePosition.z + 0.15 + canForPyramidNode.boundingBox.max.z / 2)
        }
        
        // Adding physics, collision margin setes the interaction distance
        canForPyramidNode.physicsBody = SCNPhysicsBody(type: .dynamic, shape: nil)
        canForPyramidNode.physicsBody?.isAffectedByGravity = true
        
        // Collision properties
        canForPyramidNode.physicsBody?.categoryBitMask = CollidingObjectType.thrownObject.rawValue
        canForPyramidNode.physicsBody?.collisionBitMask = CollidingObjectType.catchingObject.rawValue
        
        canForPyramidNode.name = "canForPyramid"
        
        
        
        
        
        sceneView.scene.rootNode.addChildNode(canForPyramidNode)
        
    }
    
    func createTinCan() {
        let canScene = SCNScene(named: "art.scnassets/tinCan.scn")
        
        guard let canNode = canScene?.rootNode.childNode(withName: "Can", recursively: false) else {
            return
        }
        
        guard let currentFrame = sceneView.session.currentFrame else {
            return
        }
        
        // Take position of the camera and use it for ball location
        let cameraTransform = SCNMatrix4(currentFrame.camera.transform)
        canNode.transform = cameraTransform
        
        // Adding physics, collision margin setes the interaction distance
        let physicsBody = SCNPhysicsBody(type: .dynamic, shape: SCNPhysicsShape(node: canNode, options: [SCNPhysicsShape.Option.collisionMargin: 0.01]))
        canNode.physicsBody = physicsBody
        
        let power = Float(10.0)
        let force = SCNVector3(-cameraTransform.m32 * power, -cameraTransform.m32 * power, -cameraTransform.m33 * power)
        
        canNode.physicsBody?.applyForce(force, asImpulse: true)
        sceneView.scene.rootNode.addChildNode(canNode)
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Adding contact delegate
        self.sceneView.scene.physicsWorld.contactDelegate = self
        
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
    
/*
    // Override to create and configure nodes for anchors added to the view's session.
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        let node = SCNNode()
     
        return node
    }
*/
    
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
        
        if contact.nodeA.physicsBody?.categoryBitMask == CollidingObjectType.catchingObject.rawValue
            || contact.nodeB.physicsBody?.categoryBitMask == CollidingObjectType.catchingObject.rawValue {
            
            // Dispatching to main queue asynchronously
            DispatchQueue.main.async {
                //contact.nodeA.removeFromParentNode()
                //contact.nodeB.removeFromParentNode()
                
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
            
//            // Crash animation
//            let  crash = SCNParticleSystem(named: "Crash", inDirectory: nil)
//            contact.nodeB.addParticleSystem(crash!)
        }
    }
    
}

struct CollidingObjectType: OptionSet {
    
    let rawValue: Int
    
    static let thrownObject  = CollidingObjectType(rawValue: 1 << 0)
    static let catchingObject = CollidingObjectType(rawValue: 1 << 1)
    
}
