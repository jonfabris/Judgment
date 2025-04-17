//
//  EditItemView.swift
//  Decisionator
//
//  Created by Jon Fabris on 3/6/25.
//

import SwiftUI

struct EditItemView: View {
    @EnvironmentObject var appCoordinator: AppCoordinator
    @ObservedObject var item: ChoiceItem
    @ObservedObject var appData = AppData.shared
    
    @State private var tempItem: ChoiceItem = ChoiceItem()
    @State private var hasInitialized = false
        
    
    @State private var showingConfirm = false
    
    
    var body: some View {
        VStack {
            Text("Question")
            TextEditor(text: $tempItem.question)
                .withDefaultTextEditStyle()
            Text("Correct")
            TextEditor(text: $tempItem.correct)
                .withDefaultTextEditStyle()
            Text("Incorrect")
            TextEditor(text: $tempItem.incorrect)
                .withDefaultTextEditStyle()
            Text("Explanation")
            TextEditor(text: $tempItem.explanation)
                .withDefaultTextEditStyle()
            Text("Category")
            TextEditor(text: $tempItem.category)
                .withDefaultTextEditStyle()
                .frame(height: 38)
            Button(action: {
                item.copy(tempItem)
                appData.save(item: item)
                appCoordinator.pop()
            }) {
                Text("Save")
            }
        }
        .onAppear {
            if !hasInitialized {
                tempItem = item.copy()
                hasInitialized = true
            }
        }
        .padding(10)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    if( item != tempItem) {
                        showingConfirm = true
                    } else {
                        appCoordinator.pop()
                    }
                }) {
                    HStack {
                        Image(systemName: "chevron.left")
                        Text("Cancel")
                    }
                }
            }
        }
        .confirmationDialog("Are you sure you want to discard changes?", isPresented: $showingConfirm, titleVisibility: .visible) {
            Button("Discard Changes", role: .destructive) {
                appCoordinator.pop()
            }
            Button("Keep Editing", role: .cancel) { }
        }
    }

}

//#Preview {
//    EditItemView(item: ChoiceItem(question: "", choiceA: "",choiceB: "",explanation: "", category:""))
//}
