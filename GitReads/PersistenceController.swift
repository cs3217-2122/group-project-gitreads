//
//  Persistence.swift
//  GitReads
//
//  Created by Zhou Jiahao on 10/3/22.
//

import CoreData

class PersistenceController: ObservableObject {
    let container = NSPersistentContainer(name: "Entities")

    init() {
        container.loadPersistentStores { _, err in
            self.container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
            if let err = err {
                print("Core data failed to load \(err.localizedDescription)")
            }
        }
    }
}
