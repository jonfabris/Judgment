//
//  DecisionatorApp.swift
//  Decisionator
//
//  Created by Jon Fabris on 3/3/25.
//

import SwiftUI
import SwiftData

@main
struct JudgementApp: App {
    init() {
        
    }
    
    // SwiftData can only access private database
//    var sharedModelContainer: ModelContainer = {
//        let schema = Schema([
//            ChoiceItem.self,
//        ])
//        let modelConfiguration = ModelConfiguration(schema: schema)
//
//        do {
//            return try ModelContainer(for: schema, configurations: [modelConfiguration])
//        } catch {
//            fatalError("Could not create ModelContainer: \(error)")
//        }
//    }()

//    var body: some Scene {
//        WindowGroup {
//            CoordinatorView()
//        }
////        .modelContainer(sharedModelContainer)
//    }
    
    
        var body: some Scene {
            WindowGroup {
                CoordinatorView()
            }
        }
}

