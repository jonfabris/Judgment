//
//  GameView.swift
//  Decisionator
//
//  Created by Jon Fabris on 3/10/25.
//

import SwiftUI
import SwiftData

struct GameView: View {
    @ObservedObject var viewModel: GameViewModel
    @EnvironmentObject var appCoordinator: AppCoordinator
    @Environment(\.modelContext) private var modelContext

    var body: some View {
        VStack {
            Text(viewModel.questionText)
                .overlay(RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.gray, lineWidth: 1))
            HStack {
                QuestionView(viewModel.answer1Text)
                QuestionView(viewModel.answer2Text)
            }
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
    GameView(viewModel: GameViewModel(modelContext: nil))
}
