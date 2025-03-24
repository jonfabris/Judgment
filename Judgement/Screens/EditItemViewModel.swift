//
//  EditItemViewModel.swift
//  Judgement
//
//  Created by Jon Fabris on 3/19/25.
//

class EditItemViewModel {
    

    func save(item: ChoiceItem) {
        Task { @MainActor in
            try await CloudKitHelper.instance.saveRecord(item)
        }
    }
}
