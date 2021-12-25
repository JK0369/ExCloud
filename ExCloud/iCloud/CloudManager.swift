//
//  CloudManager.swift
//  ExCloud
//
//  Created by 김종권 on 2021/12/20.
//

import CloudKit

enum FetchError {
    case addingError, fetchingError, deletingError, noRecords, none
}

struct CloudManager {
  
  /// CloudKit 콘솔 > Schema > Record Types
  private let recordType = "Todo"
  private let containerName = "iCloud.com.jake.ExCloud"
  
  func fetchTasks(completion: @escaping ([CKRecord]?, FetchError) -> Void) {
      
    /// identifier: CloudKit 콘솔 > 컨테이너 이름
    let publicDatabase = CKContainer(identifier: containerName).publicCloudDatabase
    let query = CKQuery(recordType: recordType, predicate: NSPredicate(value: true))
    query.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: false)]
    
    publicDatabase.perform(
      query,
      inZoneWith: CKRecordZone.default().zoneID,
      completionHandler: { (records, error) -> Void in
        self.processQueryResponseWith(
          records: records,
          error: error as NSError?,
          completion: { fetchedRecords, fetchError in
            completion(fetchedRecords, fetchError)
          })
      })
  }
  
  private func processQueryResponseWith(
    records: [CKRecord]?,
    error: NSError?,
    completion: @escaping ([CKRecord]?, FetchError)
    -> Void
  ) {
    guard error == nil else {
      completion(nil, .fetchingError)
      return
    }
    
    guard let records = records, records.count > 0 else {
      completion(nil, .noRecords)
      return
    }
    
    completion(records, .none)
  }
  
  func addTask(_ task: String, completionHandler: @escaping (CKRecord?, FetchError) -> Void) {
    let publicDatabase = CKContainer(identifier: containerName).publicCloudDatabase
    let record = CKRecord(recordType: recordType)
    
    record.setObject(task as __CKRecordObjCValue, forKey: "title")
    record.setObject(Date() as __CKRecordObjCValue, forKey: "createdAt")
    
    publicDatabase.save(record, completionHandler: { (record, error) in
      guard let _ = error else {
        completionHandler(record, .none)
        return
      }
      completionHandler(nil, .addingError)
    })
  }
  
  func deleteRecord(record: CKRecord, completionHandler: @escaping (FetchError) -> Void) {
    let publicDatabase = CKContainer(identifier: containerName).publicCloudDatabase
    publicDatabase.delete(withRecordID: record.recordID) { (recordID, error) -> Void in
      guard let _ = error else {
        completionHandler(.none)
        return
      }
      
      completionHandler(.deletingError)
    }
  }
  
  func updateTask(_ task: CKRecord, completionHandler: @escaping (CKRecord?, FetchError) -> Void) {
    let publicDatabase = CKContainer(identifier: containerName).publicCloudDatabase
    
    publicDatabase.save(task, completionHandler: { (record, error) in
      guard let _ = error else {
        completionHandler(record, .none)
        return
      }
      
      completionHandler(nil, .addingError)
    })
  }
}
