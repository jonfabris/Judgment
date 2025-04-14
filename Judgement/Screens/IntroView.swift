//
//  IntroView.swift
//  Decisionator
//
//  Created by Jon Fabris on 3/3/25.
//

import SwiftUI
import SwiftData

struct IntroView: View {
    @EnvironmentObject var appCoordinator: AppCoordinator
    @ObservedObject var viewModel: IntroViewModel
    
    init(viewModel: IntroViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        ZStack {
            Image("Background")
                .resizable()
                .frame(width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height)
                .ignoresSafeArea()
            VStack {
                Spacer().frame(height: 180)
                Text("Judgment")
                    .foregroundColor(Color.white)
                    .font(.system(size: 54, weight: .bold, design: .serif))
                Spacer()
            }
            VStack(spacing: 20) {
                Text(viewModel.statusDisplay)
                Button("Play") {
                    appCoordinator.push(.introPlay)
                }
                .foregroundColor(Color.white)
                Spacer().frame(height: 20)
                Button("Edit") {
                    appCoordinator.push(.editor)
                }
                .foregroundColor(Color.white)
            }
        }
        .alert("Error", isPresented: $viewModel.showAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(viewModel.alertMessage)
        }
        .frame(width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height)
        .onAppear {
            viewModel.setup()
        }
    }
}

#Preview {
    IntroView(viewModel: IntroViewModel())
}
