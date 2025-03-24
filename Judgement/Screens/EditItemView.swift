//
//  EditItemView.swift
//  Decisionator
//
//  Created by Jon Fabris on 3/6/25.
//

import SwiftUI

struct EditItemView: View {
    @EnvironmentObject var appCoordinator: AppCoordinator
    @State var item: ChoiceItem
    @Binding var needsRefresh: Bool
    var viewModel: EditItemViewModel = EditItemViewModel()
    
//    init(item: ChoiceItem) {
//        self.item = item
////        self.needsRefresh = needsRefresh
//    }
        
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
                needsRefresh = true
                viewModel.save(item: item)
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
