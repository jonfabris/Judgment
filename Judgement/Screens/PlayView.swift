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

