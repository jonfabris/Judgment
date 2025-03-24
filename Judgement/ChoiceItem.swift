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


//@Model
class ChoiceItem: CustomCloudKitCodable, Hashable, Identifiable {
    var cloudKitSystemFields: Data?
    var question: String = ""
    var correct: String = ""
    var incorrect: String = ""
    var explanation: String = ""
    var category: String = ""
    var cloudKitIdentifier: String?
    
    init() {
        
    }
    
    init(question: String, choiceA: String, choiceB: String, explanation: String, category: String) {
        self.question = question
        self.correct = choiceA
        self.incorrect = choiceB
        self.explanation = explanation
        self.category = category
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
           // something went wrong
        }
        return nil
    }
    

}
