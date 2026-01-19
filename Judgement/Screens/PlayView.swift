//
//  TestView.swift
//  Judgement
//
//  Created by Jon Fabris on 3/10/25.
//

import UIKit
import SceneKit
import SwiftUI
import Combine

struct PlayView: View {
    @EnvironmentObject var appCoordinator: AppCoordinator
    @State private var resetID = UUID()
    @State var topSafeAreaHeight: CGFloat = 0
    
    let color1 = Color(Color.init(white: 0, opacity: 0))
    let color2 = Color(Color.init(white: 0, opacity: 1))
    
    @ObservedObject var viewModel: PlayViewModel
    
    var body: some View {
        ZStack {
            if(viewModel.mode == .start || viewModel.mode == .finish) {
                Rectangle()
                    .frame(width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height)
                    .background(Color.black)
            } else {
                PlayUIView(question: viewModel.question, leftOneCorrect: viewModel.leftOneCorrect, speed: viewModel.speed, publisher: viewModel.publisher)
                    .id(resetID)
                    .edgesIgnoringSafeArea(.all)
                questionView
            }
            if(viewModel.showAnswer) {
                correctView
            }
            backgroundView
        }
        .onAppear() {
            viewModel.setupQuestions()
            if let window = UIApplication.shared.connectedScenes
                .compactMap({ ($0 as? UIWindowScene)?.windows.first })
                .first {
                topSafeAreaHeight = window.safeAreaInsets.top
            }
        }
        .onChange(of: viewModel.mode) { oldmode, mode in
            if(oldmode == .answered && mode == .question) {
                resetID = UUID()
            }
            if(mode == PlayMode.finish) {
                appCoordinator.pop()
            }
         }
        .alert("Alert Title", isPresented: $viewModel.showAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(viewModel.alertMessage)
        }

    }
    
    var questionView: some View {
        VStack {
            Spacer().frame(height: topSafeAreaHeight)
            Text(viewModel.questionNumText)
                .foregroundColor(Color.white)
                .bold()
            Spacer().frame(height: 23)
            Text(viewModel.question.question)
                .foregroundColor(Color.black)
                .bold()
                .frame(width: UIScreen.main.bounds.size.width - 30)
            Spacer()
        }
        .ignoresSafeArea(.all)
    }
    
    var correctView: some View {
        VStack(spacing: 0) {
            Spacer()
            if(viewModel.correct) {
                Text("Right")
                    .font(.system(size: 40))
                    .foregroundColor(Color.blue)
                    .bold()
//                    .shadow(
//                            color: Color.white.opacity(1), /// shadow color
//                            radius: 3, /// shadow radius
//                            x: 0,
//                            y: 2
//                        )
            } else {
                Text("Wrong")
                    .font(.system(size: 40))
                    .foregroundColor(Color.red)
                    .bold()
            }
            Spacer().frame(height: 200)
        }
    }

    
    var backgroundView: some View {
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

struct PlayUIView: UIViewRepresentable {
    let question: ChoiceItem
    let leftOneCorrect: Bool
    let speed: Float
    let publisher: PassthroughSubject<Int, Never>

    func makeCoordinator() -> Coordinator {
        return Coordinator(publisher: publisher, choiceItem: question)
    }

    func makeUIView(context: Context) -> SCNView {

        let sceneView = SCNView(frame: .zero)
        
        // Create the scene and set it to the SCNView
        let scene = SCNScene()
        sceneView.scene = scene
        
        sceneView.backgroundColor = .black

        let cube1 = createCube(text: leftOneCorrect ? question.correct : question.incorrect, backText: question.explanation)
        cube1.position = SCNVector3(-0.7, 1.1, -1) // Start position of the cube
        scene.rootNode.addChildNode(cube1)
        
        let cube2 = createCube(text: !leftOneCorrect ? question.correct : question.incorrect, backText: question.explanation)
        cube2.position = SCNVector3(0.7, 1.1, -1) // Start position of the cube
        scene.rootNode.addChildNode(cube2)

        let questionCube = createQuestionCube()
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
        
        // speed = 0 - 100,
        let duration = Double(10 * ((100 - speed)/100))
        // Create the animation to move the cube down
        let moveDown = SCNAction.moveBy(x: 0, y: -5, z: 0, duration: duration) // Move down by 5 units in 3 seconds
        cube1.runAction(moveDown)
        cube2.runAction(moveDown)

        // Add a tap gesture recognizer to detect taps
        let tapGesture = UITapGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handleTap(_:)))
        sceneView.addGestureRecognizer(tapGesture)
        // Pass the sceneView to the coordinator
        context.coordinator.sceneView = sceneView
        context.coordinator.cube1 = cube1
        context.coordinator.cube2 = cube2

        context.coordinator.timer = Timer.scheduledTimer(withTimeInterval: duration, repeats: false) { timer in
            context.coordinator.pressCube(node: nil)
        }
        
        
        return sceneView
    }
    
    func cubeTextView(text: String, fontSize: CGFloat) -> some View {
        ZStack(alignment: .center) {
            Image("IceTexture")
                .resizable()
                .frame(width: 356, height: 356)
            Text(text)
                .foregroundColor(Color.black)
                .font(.system(size: fontSize))
                .bold()
                .lineLimit(20)
                .padding(28)
                .fixedSize(horizontal: false, vertical: true)

        }
        .frame(width: 356, height: 356)
    }
    
    func createCube(text: String, backText: String) -> SCNNode {
        var materials: [SCNMaterial] = []
        
        // Create a 3D cube
        let cube = SCNBox(width: 1.3, height: 1.3, length: 1.3, chamferRadius: 0.1)
        //        cube.firstMaterial?.diffuse.contents = UIColor.red
        
        let textureImage = ImageRenderer(content: cubeTextView(text: text, fontSize: 37)).uiImage!
        let frontMaterial = SCNMaterial()
        frontMaterial.diffuse.contents = textureImage
        materials.append(frontMaterial)

        let baseMaterial = SCNMaterial()
        baseMaterial.diffuse.contents = UIImage(named: "IceTexture2")
        for _ in 0..<5 {
            materials.append(baseMaterial)
        }
        
        cube.materials = materials
        
        let backImage = ImageRenderer(content: cubeTextView(text: backText, fontSize: 16)).uiImage!
        let backMaterial = SCNMaterial()
        backMaterial.diffuse.contents = backImage
        backMaterial.diffuse.contentsTransform = SCNMatrix4MakeScale(-1, -1, 1) // Mirror & Flip
        backMaterial.diffuse.wrapS = .repeat // Prevents tiling issues
        backMaterial.diffuse.wrapT = .repeat
        
        cube.replaceMaterial(at: 2, with: backMaterial)
        
        // Create a node for the cube and add it to the scene
        let cubeNode = SCNNode(geometry: cube)
        cubeNode.position = SCNVector3(-0.7, 1.5, -1) // Start position of the cube
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
        return cubeNode
    }
    
    func updateUIView(_ uiView: SCNView, context: Context) {
        // No need to update the view in this example
    }
    
    class Coordinator: NSObject {
        let choiceItem: ChoiceItem
        let publisher: PassthroughSubject<Int, Never>
        var sceneView: SCNView?
        var cube1: SCNNode?
        var cube2: SCNNode?
        let flyAway = SCNAction.move(to: SCNVector3(0, -4.5, 0.01), duration: 0.4) //moveBy(x: 5, y: 15, z: -100, duration: 0.4)
        let zoomIn = SCNAction.move(to: SCNVector3(0, 0.2, 1.7), duration: 0.4)
        let rotateToAction = SCNAction.rotateTo(x: .pi, y: 0, z: 0, duration: 0.4)
        var timer: Timer?
        
        init(publisher: PassthroughSubject<Int, Never>, choiceItem: ChoiceItem) {
            self.publisher = publisher
            self.choiceItem = choiceItem
        }
        
        @MainActor @objc func handleTap(_ sender: UITapGestureRecognizer) {
            // Get the tap location in the SCNView
            let location = sender.location(in: sceneView)
            
            // Perform a hit test to see if the tap intersects with the cube
            let hitResults = sceneView?.hitTest(location, options: nil)
            
            // Check if the hit test returned any results
            if let hit = hitResults?.first {
                pressCube(node: hit.node)
            }
        }
        
        func pressCube(node: SCNNode?) {
            if node == nil {
                print("Timed out!")
                cube1?.removeAllActions()
                cube1?.runAction(zoomIn)
                cube1?.runAction(rotateToAction)
                publisher.send(0)
            } else if node == cube1 {
                print("Cube1 tapped!")
                timer?.invalidate()
                cube1?.removeAllActions()
                cube1?.runAction(zoomIn)
                cube1?.runAction(rotateToAction)
                cube2?.runAction(flyAway)
                publisher.send(1)
            } else if node == cube2 {
                print("Cube2 tapped!")
                timer?.invalidate()
                cube2?.removeAllActions()
                cube2?.runAction(zoomIn)
                cube2?.runAction(rotateToAction)
                cube1?.runAction(flyAway)
                publisher.send(2)
            }
        }
    }
}
