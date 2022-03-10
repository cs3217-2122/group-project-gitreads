//
//  GitReadsApp.swift
//  GitReads
//
//  Created by Zhou Jiahao on 10/3/22.
//

import SwiftUI

@main
struct GitReadsApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
