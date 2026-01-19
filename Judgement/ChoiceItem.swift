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
    
    static func == (lhs: ChoiceItem, rhs: ChoiceItem) -> Bool {
        lhs.id == rhs.id
    }
                                                                                  
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
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
