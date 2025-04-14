//
//  EditItemViewModel.swift
//  Judgement
//
//  Created by Jon Fabris on 3/19/25.
//

import Combine

class EditItemViewModel: ObservableObject {
    
    func save(item: ChoiceItem) {
        Task { @MainActor in
            try await CloudKitHelper.instance.saveRecord(item)
        }
    }
}
