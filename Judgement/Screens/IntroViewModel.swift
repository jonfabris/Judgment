//
//  IntroViewModel.swift
//  Decisionator
//
//  Created by Jon Fabris on 3/3/25.
//

import Foundation
import SwiftUI
import CloudKit


class IntroViewModel: ObservableObject {
    @Published var statusDisplay: String = ""
    var userId: CKRecord.ID?
    @Published var alertMessage = ""
    @Published var showAlert = false
    
    init() {
    }
    
    func setup() {
        Task {
            await checkCloudKitStatus()
        }
    }
    
    @MainActor
    func checkCloudKitStatus() async {
        let error = await CloudKitHelper.instance.checkCloudKitStatus()
        
        if !error.isEmpty {
            alertMessage = "You must be logged on to your iCloud account to use this app. Error: \(error)"
            showAlert = true
        }
    }


}
