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
    @ObservedObject var viewModel: EditorViewModel
    
    @ObservedObject var appData = AppData.shared
    
    @State var newItem: ChoiceItem = ChoiceItem()
    
    var body: some View {
        VStack {
            if(appData.loading){
                ProgressView().opacity(1)
            }
            else if(appData.items.isEmpty) {
                Text("No items")
            }
            else {
                List {
                    ForEach(appData.items) { item in
                        Button(action: {
                            appCoordinator.push(.detail(item: item))
                        }) {
                            Text("\(item.question)")
                            .onChange(of: item.question) { oldValue, newValue in
                                print("Item changed to: \(newValue)")
                            }
                        }
                    }
                    .onDelete(perform: deleteItems)
                }
            }
        }
        .toolbar {
            ToolbarItem {
                Button(action: addItem) {
                    Label("Add Item", systemImage: "plus")
                }
            }
        }
        .onAppear {
        }
//        .onChange(of: scenePhase) { newPhase in
//            if newPhase == .active {
//                loadItems()
//            }
//        }
        .alert("Alert Title", isPresented: $appData.showAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(appData.alertMessage)
        }
    }

    private func addItem() {
        newItem = appData.addItem()
        appCoordinator.push(.detail(item: newItem))
    }

    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                appData.deleteItem(appData.items[index])
            }
        }
    }

}

//#Preview {
//    EditorView(viewModel: EditorViewModel())
//}

/*
 Category: Geography



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

 A large date has more calories than a fig. A large date typically has about 66 calories, whereas a single fig has around 37 calories.
 */
