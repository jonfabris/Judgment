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
    var modelContext: ModelContext?
    let database = CKContainer.default().publicCloudDatabase // Use the public database
    static let instance = CloudKitHelper()  // Singleton instance
    
    private init() {}
    
    func setModelContext(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    
    /*
     let record = CKRecord(recordType: "SampleRecord")
     record["customRecordName"] = record.recordID.recordName
     */
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
    
    func saveNewItem(item: ChoiceItem) {
        
        
        // Create a new record
//        let record = CKRecord(recordType: "ChoiceItem")
//        record["question"] = "Question1" //item.question as NSString
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
    
    func saveRecord(_ item: ChoiceItem) async throws {
        let record: CKRecord? = item.toCKRecord()
        guard let record else { return }
        try await database.save(record)
    }
    

    //CloudKit limits the number of records per query (default is 100, max is 200), we need to loop until all records are fetched.
    @MainActor
    func fetchItems() async throws -> [ChoiceItem] {
        let publicDatabase = CKContainer.default().publicCloudDatabase
        let predicate = NSPredicate(value: true)
        let query = CKQuery(recordType: "ChoiceItem", predicate: predicate)
        
        var allItems: [ChoiceItem] = []
        var cursor: CKQueryOperation.Cursor? = nil
        
        repeat {
            do {
                let (records, nextCursor) = try await fetchRecords(from: publicDatabase, query: query, cursor: cursor)
                let items = records.compactMap { try? CloudKitRecordDecoder().decode(ChoiceItem.self, from: $0) }
                
                allItems.append(contentsOf: items)
                cursor = nextCursor
            } catch {
                print("Failed to fetch items: \(error)")
                throw CloudKitError(message: "Failed to fetch items: \(error)")
            }
        } while cursor != nil  // Keep fetching until there's no more data

        return allItems
    }
    
//    private func fetchRecords(from database: CKDatabase, query: CKQuery, cursor: CKQueryOperation.Cursor?) async throws -> ([CKRecord], CKQueryOperation.Cursor?) {
//        return try await withCheckedThrowingContinuation { continuation in
//            let fetchOperation: (Result<(matchResults: [(CKRecord.ID, Result<CKRecord, any Error>)], queryCursor: CKQueryOperation.Cursor?), any Error>) -> Void =
//            { result in
//                switch result {
//                case .success(let (matchResults, nextCursor)):
//                    let records: [CKRecord] = matchResults.compactMap { try? $0.1.get() }
//                    continuation.resume(returning: (records, nextCursor))
//                case .failure(let error):
//                    continuation.resume(throwing: error)
//                }
//            }
//
//            if let cursor = cursor {
//                database.fetch(with: cursor, desiredKeys: nil, resultsLimit: 200, completionHandler: fetchOperation)
//            } else {
//                database.fetch(withQuery: query, inZoneWith: nil, desiredKeys: nil, resultsLimit: 200, completionHandler: fetchOperation)
//            }
//        } as ([CKRecord], CKQueryOperation.Cursor?)
//    }

    
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
//
//    private func handleFetchResult(_ result: Result<(matchResults: [(CKRecord.ID, Result<CKRecord, Error>)], queryCursor: CKQueryOperation.Cursor?), Error>,
//                                   continuation: CheckedContinuation<([CKRecord], CKQueryOperation.Cursor?), Error>) {
//        switch result {
//        case .success(let (matchResults, nextCursor)):
//            let records = matchResults.compactMap { try? $0.1.get() }
//            continuation.resume(returning: (records, nextCursor))
//        case .failure(let error):
//            continuation.resume(throwing: error)
//        }
//    }

    
    
 /*
    @MainActor func fetchItems() async throws -> [ChoiceItem] {
        let publicDatabase = CKContainer.default().publicCloudDatabase
//        let predicate = NSPredicate(format: "question == %@", "")
        // to use this predicate you must go into cloudkit console, and add an index "QUERYABLE" to the "recordName" field!!!!
        let predicate = NSPredicate(value: true)
        let query = CKQuery(recordType: "ChoiceItem", predicate: predicate)

        publicDatabase.fetch(withQuery: query, inZoneWith: nil, desiredKeys: nil, resultsLimit: 100) { (result: Result<(matchResults: [(CKRecord.ID, Result<CKRecord, Error>)], queryCursor: CKQueryOperation.Cursor?), Error>) in
            
            switch result {
            case .success(let (matchResults, cursor)):  // Fetch records and cursor for pagination
                let items = matchResults.compactMap { try? $0.1.get() }  // Extract valid records
                
//                DispatchQueue.main.async {
//                    print("Fetched \(items.count) records")
//                    items.forEach { print($0) }
//
//                    if let cursor = cursor {
//                        print("More results available, fetch again using cursor: \(cursor)")
//                    }
//                }
                return items
            case .failure(let error):
                print("Error fetching records: \(error.localizedDescription)")
                throw CloudKitError(message: "Failed to fetch items: \(error)")
            }
        }
    }
*/
    
    
//    func fetchPublicRecords() {
//        let publicDatabase = CKContainer.default().publicCloudDatabase
//        let query = CKQuery(recordType: "SampleRecord", predicate: NSPredicate(value: true))
//
//        publicDatabase.fetch(withQuery: query, inZoneWith: nil, desiredKeys: nil, resultsLimit: 100) { result in
//            switch result {
//            case .success(let (matchResults, _)):
//                DispatchQueue.main.async {
//                    self.records = matchResults.compactMap { try? $0.1.get() }
//                }
//            case .failure(let error):
//                print("Error fetching records: \(error.localizedDescription)")
//            }
//        }
//    }



    func toDictionary<T: Codable>(_ object: T) -> [String: Any]? {
        guard let data = try? JSONEncoder().encode(object),
              let dictionary = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            return nil
        }
        return dictionary
    }
}




