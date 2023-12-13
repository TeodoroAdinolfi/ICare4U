//
//  ICare4UApp.swift
//  ICare4U
//
//  Created by Teodoro Adinolfi on 19/04/22.
//

import SwiftUI

@main
struct ICare4UApp: App {
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, PersistenceController.shared.container.viewContext)
        }
    }
}
