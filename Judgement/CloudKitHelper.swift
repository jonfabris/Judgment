//
//  CloudKitHelper.swift
//  Judgement
//
//  Created by Jon Fabris on 3/12/25.
//

import CloudKit
import SwiftData
import CloudKitCodable

struct CloudKitError: Error {
    let message: String
}


@MainActor
class CloudKitHelper {
    let database = CKContainer.default().publicCloudDatabase // Use the public database
    static let instance = CloudKitHelper()  // Singleton instance
    
    private init() {}
    
    func checkCloudKitStatus() async -> String {
        do {
            let accountStatus = try await CKContainer.default().accountStatus()
            switch accountStatus {
            case .available:
                return ""
            case .noAccount:
                return "No iCloud account"
            case .restricted:
                return "iCloud restricted"
            case .couldNotDetermine:
                return "Unable to determine iCloud status"
            case .temporarilyUnavailable:
                return "iCloud temporarily unavailable"
            @unknown default:
                return "Unknown iCloud status"
            }
        } catch {
            return "Error: \(error.localizedDescription)"
        }
    }

    func fetchCurrentUserRecord() async -> String {
        do {
            let userId = try await CKContainer.default().userRecordID()
            let userRecord = try await database.record(for: userId)
            if let firstName = userRecord["firstName"] as? String,
               let lastName = userRecord["lastName"] as? String {
                return firstName + " " + lastName
            }
            return "User name details not available in CloudKit record."
        } catch {
            return "Failed to fetch user record: \(error.localizedDescription)"
        }

    }
    
    func saveNewItem(item: ChoiceItem) {
        guard let record = item.toCKRecord() else { return }
        
        // Save the record to the public CloudKit database
        database.save(record) { savedRecord, error in
            if let error = error {
                print("Error saving record: \(error.localizedDescription)")
            } else {
                print("Record saved to public CloudKit database!")
            }
        }
    }
    
    func fetchRecord(withID id: CKRecord.ID) async throws -> CKRecord {
        let record = try await database.record(for: id)
        return record
    }
    
    // save previously created record
    func saveRecord(_ item: ChoiceItem) async throws {
        let record: CKRecord? = item.toCKRecord()
        guard let record else { return }
        try await database.save(record)
    }
    

    //CloudKit limits the number of records per query (default is 100, max is 200), we need to loop until all records are fetched.
    @MainActor
    func fetchItems() async throws -> [ChoiceItem] {
        let predicate = NSPredicate(value: true)
        let query = CKQuery(recordType: "ChoiceItem", predicate: predicate)
        
        var allItems: [ChoiceItem] = []
        var cursor: CKQueryOperation.Cursor? = nil
        
        repeat {
            do {
                let (records, nextCursor) = try await fetchRecords(from: database, query: query, cursor: cursor)
                let items = records.compactMap { try? CloudKitRecordDecoder().decode(ChoiceItem.self, from: $0) }
                
                allItems.append(contentsOf: items)
                cursor = nextCursor
            } catch {
                throw CloudKitError(message: "Failed to fetch items: \(error)")
            }
        } while cursor != nil  // Keep fetching until there's no more data

        return allItems
    }
    
    private func fetchRecords(from database: CKDatabase, query: CKQuery, cursor: CKQueryOperation.Cursor?) async throws -> ([CKRecord], CKQueryOperation.Cursor?) {
        return try await withCheckedThrowingContinuation { continuation in
            if let cursor = cursor {
                database.fetch(withCursor: cursor, desiredKeys: nil, resultsLimit: 100) { result in
                    switch result {
                        case .success(let (matchResults, nextCursor)):
                            let records = matchResults.compactMap { try? $0.1.get() }
                            continuation.resume(returning: (records, nextCursor))
                        case .failure(let error):
                            continuation.resume(throwing: error)
                        }
                }
            } else {
                database.fetch(withQuery: query, inZoneWith: nil, desiredKeys: nil, resultsLimit: 100) { result in
                    switch result {
                        case .success(let (matchResults, nextCursor)):
                            let records = matchResults.compactMap { try? $0.1.get() }
                            continuation.resume(returning: (records, nextCursor))
                        case .failure(let error):
                            continuation.resume(throwing: error)
                        }
                }
            }
        }
    }

    func deleteItem(item: ChoiceItem) async throws -> Error? {
        guard let record = item.toCKRecord() else { throw CloudKitError(message: "Unable to find record of item") }
        
        do {
            let id = try await database.deleteRecord(withID: record.recordID)
            print("Item \(id) deleted")
        } catch {
            return error
        }
      
        return nil
    }
    
    func toDictionary<T: Codable>(_ object: T) -> [String: Any]? {
        guard let data = try? JSONEncoder().encode(object),
              let dictionary = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            return nil
        }
        return dictionary
    }
    
    /*
     only for SwiftData/Private database
    @MainActor func fetchItems() async throws -> [ChoiceItem] {
        guard let modelContext else { throw CloudKitError(message: "") }
        var items: [ChoiceItem] = []
        
        let descriptor = FetchDescriptor<ChoiceItem>()
        do {
            items = try modelContext.fetch(descriptor)
            return items
        } catch {
            print("Failed to fetch items: \(error)")
            throw CloudKitError(message: "Failed to fetch items: \(error)")
        }
    }
     */
}




