//
//  PlayViewModel.swift
//  Judgement
//
//  Created by Jon Fabris on 3/14/25.
//

import SwiftUI
import Combine
import SwiftData


// modes - beforefirstquestion, question, questionanswered

enum PlayMode {
    case start
    case question
    case answered
    case finish
}

class PlayViewModel: ObservableObject
{
    @Published var mode: PlayMode = .start
    @Published var speed: Float
    var totalQuestions: Int = 0
    var items: [ChoiceItem] = []
    @Published var showAnswer: Bool = false
    private var pressedCancellable: AnyCancellable?
    let publisher = PassthroughSubject<Int, Never>()
    @Published var question: ChoiceItem = ChoiceItem()
    @Published var leftOneCorrect: Bool = false
    @Published var correct: Bool = false
    @Published var questionNumText: String = ""
    
    @Published var playUIView: PlayUIView?

    @Published var showAlert: Bool = false
    @Published var alertMessage: String = ""
    
    
    init(speed: Float) {
        self.speed = speed

        pressedCancellable = publisher
//            .delay(for: .seconds(2), scheduler: DispatchQueue.main)
            .sink { [weak self] cubePressed in
                self?.pressAnswer(cubePressed: cubePressed)
            }
    }
    
    @MainActor func setupQuestions() {
        Task { @MainActor in
            do {
                items = try await CloudKitHelper.instance.fetchItems()
            } catch {
                showAlert = true
                alertMessage = error.localizedDescription
            }
            totalQuestions = items.count
            setupNextQuestion()
        }
    }
    
    func setupNextQuestion() {
        createPlayUIView()
        guard items.count > 0 else { return }
        var randomInt = Int.random(in: 0...(items.count - 1))
        question = items[randomInt]
        items.remove(at: randomInt)
        
        randomInt = Int.random(in: 0...1)
        leftOneCorrect = (randomInt == 0)
        questionNumText = "Question \(totalQuestions - items.count) of \(totalQuestions)"
        
        withAnimation(.easeInOut(duration: 0.5)) {
            mode = .question
        }
    }
    
    func pressAnswer(cubePressed: Int) {
        guard mode == .question else {
            if mode == .answered {
                pressContinue()
            }
            return
        }
        correct = false
        if(leftOneCorrect && cubePressed == 1) { correct = true; }
        if(!leftOneCorrect && cubePressed == 2) { correct = true; }
        
        mode = .answered
        withAnimation(.easeInOut(duration: 0.8)) {
            showAnswer = true
        }
        
    }
    
    func pressContinue() {
        guard mode == .answered else { return }
        guard (items.count > 0) else {
            mode = .finish
            return
        }
        
        setupNextQuestion()
    
        mode = .question
        showAnswer = false
    }
    
    func createPlayUIView() {
        playUIView = PlayUIView(question: question, leftOneCorrect: leftOneCorrect, speed: speed, publisher: publisher)
    }
}
