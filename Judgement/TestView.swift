//
//  TestView.swift
//  Judgement
//
//  Created by Jon Fabris on 3/10/25.
//

import UIKit
import SceneKit
import SwiftUI

struct TestView: View {
    let color1 = Color(Color.init(white: 0, opacity: 0))
    let color2 = Color(Color.init(white: 0, opacity: 1))
    
    var body: some View {
        ZStack {
            SceneView()
                .edgesIgnoringSafeArea(.all)
            overlayView
            bottomView
        }

    }
    
    var overlayView: some View {
        VStack {
            VStack(alignment: .center) {
                Text("What is the largest country in the world")
                    .foregroundColor(Color.black)
                    .bold()
            }
            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: 50)

            Spacer()
        }
    }
    
    var bottomView: some View {
        VStack(spacing: 0) {
            Spacer()
            LinearGradient(gradient: Gradient(colors: [color1, color2]),
                           startPoint: .top,
                           endPoint: .bottom)
                .edgesIgnoringSafeArea(.all) // Applies gradient to the entire screen
                .frame(height: 70)
            Rectangle()
                .frame(width: UIScreen.main.bounds.size.width, height: 100)
                .background(Color.black)
        }
    }
}

struct SceneView: UIViewRepresentable {
    func makeCoordinator() -> Coordinator {
       return Coordinator()
   }
    
    func makeUIView(context: Context) -> SCNView {
        
        
        
        let sceneView = SCNView(frame: .zero)
        
        // Create the scene and set it to the SCNView
        let scene = SCNScene()
        sceneView.scene = scene
        
        sceneView.backgroundColor = .black
        
        var cube1 = createCube(text: "Russia is the largest country in the world.")
        cube1.position = SCNVector3(-0.7, 1.1, -1) // Start position of the cube
        scene.rootNode.addChildNode(cube1)
        
        var cube2 = createCube(text: "Canada is the largest country in the world.")
        cube2.position = SCNVector3(0.7, 1.1, -1) // Start position of the cube
        scene.rootNode.addChildNode(cube2)
        
        var questionCube = createQuestionCube()
        questionCube.position = SCNVector3(0.0, 2.4, -1) // Start position of the cube
        scene.rootNode.addChildNode(questionCube)
        
        // Set the camera position
        let cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        cameraNode.position = SCNVector3(0, 0, 5)
        scene.rootNode.addChildNode(cameraNode)
        
        // Add light to the scene to make the cube look 3D
        let lightNode = SCNNode()
        let light = SCNLight()
        light.type = .omni // Omnidirectional light to light up the cube from all directions
        light.intensity = 4000
        lightNode.light = light
        lightNode.position = SCNVector3(1, 3, 5) // Position the light above and in front of the cube
        scene.rootNode.addChildNode(lightNode)
        
//         Add an ambient light to soften the shadows
        let ambientLightNode = SCNNode()
        let ambientLight = SCNLight()
        ambientLight.type = .ambient
        ambientLight.color = UIColor.white.withAlphaComponent(0.3) // Slight ambient light to soften shadows
        ambientLightNode.light = ambientLight
        scene.rootNode.addChildNode(ambientLightNode)
        
        // Create the animation to move the cube down
        let moveDown = SCNAction.moveBy(x: 0, y: -5, z: 0, duration: 10) // Move down by 5 units in 3 seconds
        cube1.runAction(moveDown)
        cube2.runAction(moveDown)
        
        // Create a rotation action to rotate the cube slightly
        //        let rotateAction = SCNAction.rotateBy(x: 0, y: CGFloat.pi / 14, z: 0, duration: 3) // Rotate by 45 degrees (pi/4 radians) along the Y-axis
        //        cubeNode.runAction(rotateAction)
        
        // Add a tap gesture recognizer to detect taps
        let tapGesture = UITapGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handleTap(_:)))
        sceneView.addGestureRecognizer(tapGesture)
        // Pass the sceneView to the coordinator
        context.coordinator.sceneView = sceneView
        context.coordinator.cube1 = cube1
        context.coordinator.cube2 = cube2
        
        return sceneView
    }
    
    class Coordinator: NSObject {
        var sceneView: SCNView?
        var cube1: SCNNode?
        var cube2: SCNNode?
        let flyAway = SCNAction.move(to: SCNVector3(0, -4.5, 0.01), duration: 0.4) //moveBy(x: 5, y: 15, z: -100, duration: 0.4)
        let zoomIn = SCNAction.move(to: SCNVector3(0, -0.5, 1.7), duration: 0.4)
        
        @objc func handleTap(_ sender: UITapGestureRecognizer) {
            // Get the tap location in the SCNView
            let location = sender.location(in: sceneView)
            
            // Perform a hit test to see if the tap intersects with the cube
            let hitResults = sceneView?.hitTest(location, options: nil)
            
            // Check if the hit test returned any results
            if let hit = hitResults?.first {
                if hit.node == cube1 {
                    print("Cube1 tapped!")
                    // Perform any action when the cube is tapped
                    cube1?.removeAllActions()
                    cube1?.runAction(zoomIn)
                    cube2?.runAction(flyAway)
                    
                } else if hit.node == cube2 {
                    print("Cube2 tapped!")
                    // Perform any action when the cube is tapped
                    cube2?.removeAllActions()
                    cube2?.runAction(zoomIn)
                    cube1?.runAction(flyAway)
                }
            }
        }
    }
    
    func createCube(text: String) -> SCNNode {
        var materials: [SCNMaterial] = []
        
        // Create a 3D cube
        let cube = SCNBox(width: 1.3, height: 1.3, length: 1.3, chamferRadius: 0.1)
        //        cube.firstMaterial?.diffuse.contents = UIColor.red
        var textureImage = generateTextImage(text: text);
        let frontMaterial = SCNMaterial()
        frontMaterial.diffuse.contents = textureImage
        materials.append(frontMaterial)
        
        let baseMaterial = SCNMaterial()
        baseMaterial.diffuse.contents = UIImage(named: "IceTexture2")
        for i in 0..<5 {
            materials.append(baseMaterial)
        }
        
        cube.materials = materials
        
        // Create a node for the cube and add it to the scene
        let cubeNode = SCNNode(geometry: cube)
        cubeNode.position = SCNVector3(-0.7, 1.5, -1) // Start position of the cube
        //        cubeNode.eulerAngles = SCNVector3(CGFloat.pi / 10,0,0)
        return cubeNode
    }
    
    func createQuestionCube() -> SCNNode {
        var materials: [SCNMaterial] = []
        
        // Create a 3D cube
        let cube = SCNBox(width: 2.8, height: 0.5, length: 0.5, chamferRadius: 0.1)
        let baseMaterial = SCNMaterial()
        baseMaterial.diffuse.contents = UIImage(named: "IceTexture")
        for i in 0..<6 {
            materials.append(baseMaterial)
        }
        
        cube.materials = materials
        
        // Create a node for the cube and add it to the scene
        let cubeNode = SCNNode(geometry: cube)
        cubeNode.position = SCNVector3(-0.7, 1.5, -1) // Start position of the cube
        //        cubeNode.eulerAngles = SCNVector3(CGFloat.pi / 10,0,0)
        return cubeNode
    }
    
    func updateUIView(_ uiView: SCNView, context: Context) {
        // No need to update the view in this example
    }
    
    // Function to generate an image with text
    func generateTextImage(text: String) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: 256, height: 256))
        
        return renderer.image { context in
            // Set the background color to white
            UIColor.white.setFill()
//            context.fill(CGRect(origin: .zero, size: CGSize(width: 256, height: 256)))
            let backgroundImage = UIImage(named: "IceTexture")
            backgroundImage?.draw(in: CGRect(origin: .zero, size: CGSize(width: 256, height: 256)))
                       
            
            // Set text properties
            let attributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.boldSystemFont(ofSize: 22),
                .foregroundColor: UIColor.black
            ]
            
            // Draw the text in the center of the image
            let textRect = CGRect(x: 32, y: 32, width: 192, height: 192)
            text.draw(in: textRect, withAttributes: attributes)
        }
    }
}
