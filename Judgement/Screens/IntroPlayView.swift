//
//  GameView.swift
//  Decisionator
//
//  Created by Jon Fabris on 3/10/25.
//

import SwiftUI
import SwiftData

struct IntroPlayView: View {
    @ObservedObject var viewModel: IntroPlayViewModel
    @EnvironmentObject var appCoordinator: AppCoordinator
    @State var speedValue: Float = 50

    var body: some View {
        ZStack {
            Image("Background")
                .resizable()
                .frame(width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height)
                .ignoresSafeArea()
                
            VStack {
                Text(viewModel.introText)
                    .foregroundColor(Color.white)
                Spacer().frame(height: 100)
                Text("Drop Speed")
                    .foregroundColor(Color.white)
                Slider(value: $speedValue, in: 0...80, step: 1)
                    .padding(.horizontal, 50)
                
                Spacer().frame(height: 50)
                Button("Play") {
                    viewModel.clickPlay()
                    appCoordinator.push(.play(speed: speedValue))
                }
                .foregroundColor(Color.white)
            }
        }
        .onAppear() {
        }
    }
    
    func QuestionView(_ text: String) -> some View {
        VStack {
            Text(text)
        }
        .overlay(RoundedRectangle(cornerRadius: 8)
            .stroke(Color.gray, lineWidth: 1))
    }
}

#Preview {
    IntroPlayView(viewModel: IntroPlayViewModel())
}
