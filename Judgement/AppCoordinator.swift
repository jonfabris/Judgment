//
//  NavigationCoordinator.swift
//  Decisionator
//
//  Created by Jon Fabris on 3/4/25.
//

import Foundation
import Combine
import SwiftUI


enum Screen: Hashable {
    case intro
    case editor
    case detail(item: Binding<ChoiceItem>)
    case introPlay
    case play(speed: Float)
    
    static func == (lhs: Screen, rhs: Screen) -> Bool {
        switch (lhs, rhs) {
        case (.intro, .intro),
             (.editor, .editor),
             (.introPlay, .introPlay):
            return true
        case (.detail(let a), .detail(let b)):
            return a.id == b.id
        case (.play(let a), .play(let b)):
            return a == b
        default:
            return false
        }
    }
    
    func hash(into hasher: inout Hasher) {
        switch self {
        case .intro:
            hasher.combine(0)
        case .editor:
            hasher.combine(1)
        case .introPlay:
            hasher.combine(2)
        case .detail(let item):
            hasher.combine(3)
            hasher.combine(item.id)
        case .play(let speed):
            hasher.combine(4)
            hasher.combine(speed)
        }
    }  
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
    
    var screenStack: [Screen] = []

    func push(_ screen: Screen) {
        path.append(screen)
        screenStack.append(screen)
    }
    
    func pop() {
        path.removeLast()
        screenStack.removeLast()
    }
    
    func popToRoot() {
        path.removeLast(path.count)
        screenStack.removeLast(path.count)
    }
    
    @ViewBuilder
    func build(_ screen: Screen) -> some View {
        switch screen {
        case .intro:
            IntroView(viewModel: IntroViewModel())
        case .editor:
            EditorView(viewModel: EditorViewModel())
        case .detail(let item):
            EditItemView(item: item)
        case .introPlay:
            IntroPlayView(viewModel: IntroPlayViewModel())
        case .play(let speed):
            PlayView(viewModel: PlayViewModel(speed: speed))
        }
    }
}
