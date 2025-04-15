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
        loading = true
        print("LoadQuestions\n\n")
        Task { @MainActor in
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
    
    @MainActor func addItem() -> ChoiceItem {
        let newItem = ChoiceItem(question: "question", choiceA: "choice A", choiceB: "choice B", explanation: "explanation", category: "category")
        CloudKitHelper.instance.saveNewItem(item: newItem)
        items.append(newItem)
        return newItem
    }
    
    // save item already in database
    func save(item: ChoiceItem) {
        Task { @MainActor in
            try await CloudKitHelper.instance.saveRecord(item)
        }
    }
}
