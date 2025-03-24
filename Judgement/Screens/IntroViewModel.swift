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
    
    init() {
//        Task {
//            await checkiCloudAccountStatus()
//            await fetchCurrentUserRecord()
//        }
    }
 /*
    @MainActor
    func checkiCloudAccountStatus() async {
        do {
            let status = try await CKContainer.default().accountStatus()
            switch status {
            case .available:
                statusDisplay = "iCloud account is available."
            case .noAccount:
                statusDisplay = "No iCloud account is logged in."
            case .restricted:
                statusDisplay = "iCloud access is restricted."
            case .couldNotDetermine:
                statusDisplay = "Could not determine iCloud account status."
            case .temporarilyUnavailable:
                statusDisplay = "iCloud is temporarily available."
            @unknown default:
                statusDisplay = "Unknown iCloud account status."
            }
        } catch {
            statusDisplay = "Failed to get iCloud account status: \(error.localizedDescription)"
        }
    }
    
    @MainActor
    func fetchCurrentUserRecord() async {
        do {
            userId = try await CKContainer.default().userRecordID()
            if let userId {
                let userRecord = try await CKContainer.default().publicCloudDatabase.record(for: userId)
                if let firstName = userRecord["firstName"] as? String,
                   let lastName = userRecord["lastName"] as? String {
                    print("User's name: \(firstName) \(lastName)")
                } else {
                    print("User name details not available in CloudKit record.")
                }
            }
        } catch {
            statusDisplay = "Failed to fetch user record: \(error.localizedDescription)"
        }
    }
*/

}
