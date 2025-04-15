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
        
    var body: some View {
        VStack {
            Text("Question")
            TextEditor(text: $item.question)
                .withDefaultTextEditStyle()
            Text("Correct")
            TextEditor(text: $item.correct)
                .withDefaultTextEditStyle()
            Text("Incorrect")
            TextEditor(text: $item.incorrect)
                .withDefaultTextEditStyle()
            Text("Explanation")
            TextEditor(text: $item.explanation)
                .withDefaultTextEditStyle()
            Text("Category")
            TextEditor(text: $item.category)
                .withDefaultTextEditStyle()
                .frame(height: 38)
            Button(action: {
                appData.save(item: item)
                appCoordinator.pop()
            }) {
                Text("Save")
            }
        }
        .padding(10)
    }
}

//#Preview {
//    EditItemView(item: ChoiceItem(question: "", choiceA: "",choiceB: "",explanation: "", category:""))
//}
