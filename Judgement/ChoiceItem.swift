//
//  ChoiceItem.swift
//  Decisionator
//
//  Created by Jon Fabris on 3/3/25.
//

import Foundation
import SwiftData

@Model
final class ChoiceItem {
    var question: String = ""
    var correct: String = ""
    var incorrect: String = ""
    var explanation: String = ""
    var category: String = ""
    
    init(question: String, choiceA: String, choiceB: String, explanation: String, category: String) {
        self.question = question
        self.correct = choiceA
        self.incorrect = choiceB
        self.explanation = explanation
        self.category = category
    }
}
