//
//  ChoiceItem.swift
//  Decisionator
//
//  Created by Jon Fabris on 3/3/25.
//

import Foundation
import SwiftData
import CloudKit
import CloudKitCodable


//@Model - only needed for SwiftData
class ChoiceItem: CustomCloudKitCodable, Hashable, Identifiable, ObservableObject {
    var id: UUID = UUID()
    var cloudKitSystemFields: Data?
    var question: String = ""
    var correct: String = ""
    var incorrect: String = ""
    var explanation: String = ""
    var category: String = ""
    var cloudKitIdentifier: String?
    var difficulty: Int = 5 // int from 1 to 10
    
    enum CodingKeys: String, CodingKey {
        case cloudKitSystemFields
        case question
        case correct
        case incorrect
        case explanation
        case category
        case cloudKitIdentifier
        case difficulty
    }

    // MARK: - Init
    init() {}
    
    init(question: String, choiceA: String, choiceB: String, explanation: String, category: String, difficulty: Int = 5) {
        self.question = question
        self.correct = choiceA
        self.incorrect = choiceB
        self.explanation = explanation
        self.category = category
        self.difficulty = difficulty
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.cloudKitSystemFields = try container.decodeIfPresent(Data.self, forKey: .cloudKitSystemFields)
        self.question = try container.decode(String.self, forKey: .question)
        self.correct = try container.decode(String.self, forKey: .correct)
        self.incorrect = try container.decode(String.self, forKey: .incorrect)
        self.explanation = try container.decode(String.self, forKey: .explanation)
        self.category = try container.decode(String.self, forKey: .category)
        self.cloudKitIdentifier = try container.decodeIfPresent(String.self, forKey: .cloudKitIdentifier)
        self.difficulty = try container.decode(Int.self, forKey: .difficulty)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(cloudKitSystemFields, forKey: .cloudKitSystemFields)
        try container.encode(question, forKey: .question)
        try container.encode(correct, forKey: .correct)
        try container.encode(incorrect, forKey: .incorrect)
        try container.encode(explanation, forKey: .explanation)
        try container.encode(category, forKey: .category)
        try container.encodeIfPresent(cloudKitIdentifier, forKey: .cloudKitIdentifier)
        try container.encode(difficulty, forKey: .difficulty)
    }
    // Conform to Hashable: Implement '==' to check equality between instances
    static func == (lhs: ChoiceItem, rhs: ChoiceItem) -> Bool {
        return lhs.question == rhs.question
    }
    
    // Conform to Hashable: Implement 'hash(into:)' to create hash value
    func hash(into hasher: inout Hasher) {
        hasher.combine(question)
        hasher.combine(correct)
        hasher.combine(incorrect)
        hasher.combine(explanation)
        hasher.combine(category)
    }
}

extension ChoiceItem {
    func toCKRecord() -> CKRecord? {
        do {
           let record = try CloudKitRecordEncoder().encode(self)
           // record is now a CKRecord you can upload to CloudKit
            return record
        } catch {
           print("Something went wrong in toCKRecord")
        }
        return nil
    }
}


/*Category: Geography
 
 
 
 Which is bigger in area?

 Brazil,

 the United States without Alaska



 Brazil is bigger than the continental United States. But if you add Alaska, the United States is bigger. The continental United States (the 48 contiguous states) has a total area of approximately 8.08 million km² (3.12 million mi²).Brazil has a total area of approximately 8.51 million km² (3.29 million mi²).  However, if you include Alaska, the total area of the entire United States (including all states and territories) becomes about 9.83 million km² (3.80 million mi²), making it larger than Brazil.



 Which is larger?

 Russia,

 Canada,

 Russia is larger than Canada. Russia is the largest country in the world (6.6 million mi²). Canada is the second largest country (3.85 million mi²).



 Which are further apart?

 New York and Los Angeles,

 New York and London.

 New York and London are further apart than New York and Los Angeles. New York and Los Angeles are approximately 2,450 miles apart.New York and London are about 3,470 miles apart.



 Which are further apart?

 South America and Africa?

 New York and Los Angeles?

 New York and Los Angeles are further apart. New York and Los Angeles are approximately 2,450 miles apart.  Northeastern Brazil. and the westernmost part of Africa, specifically near Senegal are roughly 1,600 miles apart





 Category: Calories



 Which has more calories?

 An apple.

 An avocado.

 An avocado typically has more calories than an apple. A medium-sized apple typically has around 95 calories, while a medium-sized avocado has approximately 240 calories.





 Which has more calories?

 A fig.

 A large date.

 A large date has more calories than a fig. A large date typically has about 66 calories, whereas a single fig has around 37 calories*/
