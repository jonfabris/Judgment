//
//  GameViewModel.swift
//  Decisionator
//
//  Created by Jon Fabris on 3/10/25.
//

import SwiftUI
import Combine
import SwiftData

class StartPlayViewModel: ObservableObject
{
    @Published var introText: String = ""
    
    init() {
    }

    @MainActor func clickPlay() {
    }
}
