//
//  EditorViewModel.swift
//  Judgement
//
//  Created by Jon Fabris on 3/19/25.
//

import SwiftUI
import Combine

class EditorViewModel: ObservableObject
{
    @Published var items: [ChoiceItem] = []
    @Published var loading: Bool = false
    @Published var showAlert: Bool = false
    @Published var alertMessage: String = ""
    
    init() {

    }
    
    @MainActor func loadQuestions() {
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
            } catch {
                print(error.localizedDescription)
            }
        }
    }
}

