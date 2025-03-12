//
//  GameViewModel.swift
//  Decisionator
//
//  Created by Jon Fabris on 3/10/25.
//

import SwiftUI
import Combine
import SwiftData

class GameViewModel: ObservableObject
{
    var items: [ChoiceItem] = []
    var question: ChoiceItem?
    @Published var questionText: String = ""
    @Published var answer1Text: String = ""
    @Published var answer2Text: String = ""
    
    private let modelContext: ModelContext?

    init(modelContext: ModelContext?) {
        self.modelContext = modelContext

        Task { @MainActor in
            await fetchItems()
            setupQuestion()
        }
    }

    @MainActor func fetchItems() async {
        guard let modelContext else { return }
        
        let descriptor = FetchDescriptor<ChoiceItem>()
        do {
            items = try modelContext.fetch(descriptor)
        } catch {
            print("Failed to fetch items: \(error)")
        }
    }

    func setupQuestion() {
        guard items.count > 0 else { return }
        var randomInt = Int.random(in: 0...(items.count - 1))
        question = items[randomInt]
        guard let question else { return }
        
        questionText = question.question
        randomInt = Int.random(in: 0...1)
        if(randomInt == 0) {
            answer1Text = question.correct
            answer2Text = question.incorrect
        } else
        {
            answer1Text = question.incorrect
            answer2Text = question.correct
        }
    }
}
