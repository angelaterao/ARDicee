//
//  ViewController.swift
//  ARDicee
//
//  Created by Angela Terao on 19/01/2023.
//

import UIKit
import SceneKit // framework pour la creation de contenu 3D (objets, animation, lumiere)
import ARKit // framework pour la realite augmentee, permet de superposer des contenus 3D sur les images reelles. Il reconnait les mouvements, le suivi de la position, detecte les surfaces.

class ViewController: UIViewController, ARSCNViewDelegate {
    
    var diceArray = [SCNNode]() //Vient de SceneKit. SCNNode represente un point/noeud de l'espace 3D.
    //Chaque noeud peut etre utilise pour construire une hierarchie de contenu 3D (chaque noeud peut etre un parent ou enfant d'un autre noeud - les proprietes de positionm rotation ou echelle sont heritees par ses enfants -> Permet de controler un groupe d'objets). Les noeuds sont utilises pour afficher des geometries 3D, lumieres pour eclairer l'objet, animations pour animer les proprietes des noeuds.

    @IBOutlet var sceneView: ARSCNView! // Vient de SceneKit, sous-classe de SCNView. Il est concu pour les applications AR en utilisant les fonctionnalites de ARKit pour superposer des objets 3D sur les images reelles capturees par la camera de l'appareil. Il combine les fonctionnalites de SceneKit pour creer des scenes 3D interactives avec les fonctionnalites d4ARKit pour les applications d'AR.
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //self.sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints]
        
        // Set the view's delegate
        sceneView.delegate = self
        
        sceneView.autoenablesDefaultLighting = true
        
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        
        configuration.planeDetection = .horizontal

        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    
    // MARK: - Dice Rendering Methods
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            let touchLocation = touch.location(in: sceneView)
            
            if let query = sceneView.raycastQuery(from: touchLocation, allowing: .existingPlaneGeometry, alignment: .any) {
                let results = sceneView.session.raycast(query)

                if let hitResult = results.first {
                    
                    addDice(atLocation: hitResult)

                }
            }
        }
    }
    
    func addDice(atLocation location: ARRaycastResult) {
        
        //Create a new scene
        let diceScene = SCNScene(named: "art.scnassets/diceCollada.scn")!

        if let diceNode = diceScene.rootNode.childNode(withName: "Dice", recursively: true) {

            diceNode.position = SCNVector3(
                x: location.worldTransform.columns.3.x,
                y: location.worldTransform.columns.3.y + diceNode.boundingSphere.radius,
                z: location.worldTransform.columns.3.z)
            
            diceArray.append(diceNode)
            
            sceneView.scene.rootNode.addChildNode(diceNode)
            
            roll(dice: diceNode)
            
        }
    }
    
    func roll(dice: SCNNode) {
        
        let randomX = Float(arc4random_uniform(4) + 1) * (Float.pi/2)
        
        let randomZ = Float(arc4random_uniform(4) + 1) * (Float.pi/2)
        
        dice.runAction(SCNAction.rotateBy(x: CGFloat(randomX * 5), y: 0, z: CGFloat(randomZ * 5), duration: 0.5))
    }
    
    func rollAll() {
        
        if !diceArray.isEmpty {
            for dice in diceArray {
                roll(dice: dice)
            }
        }
    }
    
    @IBAction func rollAgain(_ sender: UIBarButtonItem) {
        rollAll()
    }
    
    
    @IBAction func removeAllDice(_ sender: UIBarButtonItem) {
        
        if !diceArray.isEmpty {
            for dice in diceArray {
                dice.removeFromParentNode()
            }
        }
    }
    
    override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        rollAll()
    }

    
    // MARK: - ARSCNViewDelegateMethod
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        
        guard let planeAnchor = anchor as? ARPlaneAnchor else {return}
        
        let planeNode = createPlane(withPlaneAnchor: planeAnchor)
        
        node.addChildNode(planeNode)


    }
    
    // MARK: - Plane Rendering Methods
    
    func createPlane(withPlaneAnchor planeAnchor: ARPlaneAnchor) -> SCNNode {
        
        //ARPlaneAnchor est une classe (de ARKit) qui represente une surface detectee dans la camera. Elle a les infos de position, taille, orientation, et forme. Peut etre utilisee pour placer des objets dans l'environnement reel.
        //extent = taille de la surface detectee exprimee en metres, center = la position de la surface exprimee en coordonnes 3D (x, y, z)
        
        //SCNPlane est une classe (de SceneKit) qui represente un plan geometrique 3D. Utilisee pour creer des surfaces planes dans une scene 3D. Width/ Height = definissent les dimensions en metres. SCNPlane peut etre utilisee pour creer des noeuds SCNNode qui peuvent etre ajoutees a la scene 3D. On peut changer les proprietes pour personnaliser l'apparence du plan en utilisant "materials".
        
        let plane = SCNPlane(width: CGFloat(planeAnchor.planeExtent.width), height: CGFloat(planeAnchor.planeExtent.height))
        
        let planeNode = SCNNode()
        
        planeNode.position = SCNVector3(x: planeAnchor.center.x, y: 0, z: planeAnchor.center.z)
        
        planeNode.transform = SCNMatrix4MakeRotation(-Float.pi/2, 1, 0, 0)
        
        let gridMaterial = SCNMaterial()
        
        gridMaterial.diffuse.contents = UIImage(named: "art.scnassets/grid.png")
        
        plane.materials = [gridMaterial]
        
        planeNode.geometry = plane
        
        return planeNode
    
        
    }

}


