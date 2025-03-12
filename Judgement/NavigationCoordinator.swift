//
//  NavigationCoordinator.swift
//  Decisionator
//
//  Created by Jon Fabris on 3/4/25.
//

import Foundation
import Combine
import SwiftUI

enum Screen: Identifiable, Hashable {
    case intro
    case editor
    case detail(item: ChoiceItem)
    case game
    case test
    
    var id: Self { return self }
}

struct CoordinatorView: View {
    @StateObject var appCoordinator: AppCoordinator = AppCoordinator()
    
    var body: some View {
        NavigationStack(path: $appCoordinator.path) {
            appCoordinator.build(.intro)
                .navigationDestination(for: Screen.self) { screen in
                    appCoordinator.build(screen)
                }
        }
        .environmentObject(appCoordinator)
    }
}

class AppCoordinator: ObservableObject {
    @Published var path: NavigationPath = NavigationPath()
    @Environment(\.modelContext) private var modelContext

    func push(_ screen: Screen) {
        path.append(screen)
    }
    
    func pop() {
        path.removeLast()
    }
    
    func popToRoot() {
        path.removeLast(path.count)
    }
    
    @ViewBuilder
    func build(_ screen: Screen) -> some View {
        switch screen {
        case .intro:
            IntroView(viewModel: IntroViewModel())
        case .editor:
            EditorView()
        case .detail(var item):
            EditItemView(item: item)
        case .game:
            GameView(viewModel: GameViewModel(modelContext: modelContext))
        case .test:
            TestView()
        }
    }
}
