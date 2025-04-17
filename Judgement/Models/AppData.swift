//
//  AppData.swift
//  Judgement
//
//  Created by Jon Fabris on 4/15/25.
//

import Combine



class AppData: ObservableObject {
    static let shared = AppData() // singleton
  
    @Published var items: [ChoiceItem] = []
    @Published var loading: Bool = false
    @Published var showAlert: Bool = false
    @Published var alertMessage: String = ""

    private init() {}
    
    func loadQuestions() {
        
        print("LoadQuestions\n\n")
        Task { @MainActor in
            loading = true
            do {
                items = try await CloudKitHelper.instance.fetchItems()
                loading = false
                print("num items \(items.count)")
            } catch {
                showAlert = true
                loading = false
                alertMessage = error.localizedDescription
            }
        }
    }
    
    func deleteItem(_ item: ChoiceItem) {
       
        Task { @MainActor in
            do {
                _ = try await CloudKitHelper.instance.deleteItem(item: item)
                items.removeAll { $0.id == item.id }
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    func addItem() -> ChoiceItem {
        let newItem = ChoiceItem(question: "question", correct: "correct", incorrect: "incorrect", explanation: "explanation", category: "category")
        return newItem
    }
    
    // save item, if item is not in database it creates a new record
    func save(item: ChoiceItem) {
        Task { @MainActor in
            try await CloudKitHelper.instance.saveOrUpdate(item)
            appendIfNew(item)
        }
    }
    
    func appendIfNew(_ item: ChoiceItem) {
        if !items.contains(where: { $0.getRecordId() == item.getRecordId() }) {
            items.append(item)
        }
    }

}
