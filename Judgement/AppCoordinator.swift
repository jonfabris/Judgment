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
    case detail(item: Binding<ChoiceItem>) // needsRefresh: Binding<Bool>)
    case introPlay
    case play(speed: Float)

    var id: Self { return self }
    
    // Explicitly conform to Equatable
    static func ==(lhs: Screen, rhs: Screen) -> Bool {
        switch (lhs, rhs) {
        case (.intro, .intro), (.editor, .editor), (.introPlay, .introPlay):
            return true
        case (.play(_), .play(_)):
            return true
        case (.detail(_), .detail(_)):
            return true
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
        case .play(let speed):
            hasher.combine(3)
            hasher.combine(speed)
        case .detail(let item): //, _):
            hasher.combine(4)
            //            hasher.combine(item)
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
//    @State var wiki: Wiki = Wiki()
    @State var choices: [ChoiceItem] = [ChoiceItem(question: "question", choiceA: "choice A", choiceB: "choice B", explanation: "explanation", category: "category")]
    
    @Published var path: NavigationPath = NavigationPath()
//    @Environment(\.modelContext) private var modelContext
    
    lazy var editorViewModel = EditorViewModel()
    lazy var introViewModel = IntroViewModel()
    lazy var startPlayViewModel = StartPlayViewModel()
    
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
            IntroView(viewModel: introViewModel)
        case .editor:
            EditorView(viewModel: editorViewModel, wiki: $choices)
        case .detail(let item):
            EditItemView(item: item)
        case .introPlay:
            StartPlayView(viewModel: StartPlayViewModel())
        case .play(let speed):
            PlayView(viewModel: PlayViewModel(speed: speed))
        }
    }
}
