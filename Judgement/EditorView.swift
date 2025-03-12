//
//  ContentView.swift
//  Decisionator
//
//  Created by Jon Fabris on 3/3/25.
//

import SwiftUI
import SwiftData

struct EditorView: View {
    @EnvironmentObject var appCoordinator: AppCoordinator
    @Environment(\.modelContext) private var modelContext
    @Query private var items: [ChoiceItem]
    
    var body: some View {
        VStack {
            if(items.isEmpty) {
                Text("No items")
            }
            List {
                ForEach(items) { item in
                    Button(action: {
                        appCoordinator.push(.detail(item: item))
                    }) {
                        Text("\(item.question)")
                    }
                }
                .onDelete(perform: deleteItems)
            }
            
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                EditButton()
            }
            ToolbarItem {
                Button(action: addItem) {
                    Label("Add Item", systemImage: "plus")
                }
            }
        }
    }

    private func addItem() {
        withAnimation {
            let newItem = ChoiceItem(question: "question", choiceA: "choice A", choiceB: "choice B", explanation: "explanation", category: "category")
            modelContext.insert(newItem)
            do {
                try modelContext.save() // Ensure the save operation is performed
            } catch {
                print("Failed to save item: \(error)")
            }
        }
    }

    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                modelContext.delete(items[index])
            }
        }
    }

}

#Preview {
    EditorView()
        .modelContainer(for: ChoiceItem.self, inMemory: true)
}
