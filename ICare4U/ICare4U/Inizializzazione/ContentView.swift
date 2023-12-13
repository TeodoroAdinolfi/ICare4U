//
//  ContentView.swift
//  ICare4U
//
//  Created by Teodoro Adinolfi on 19/04/22.
//
// Antonio Bove
// Emilio Amato

import SwiftUI
import CoreData
import UserNotifications

struct ContentView: View {
    
    @Environment(\.managedObjectContext) private var viewContext
    
    @AppStorage("welcomeScreenShown")
    var welcomeScreenShown: Bool = false
    
    init(){
        let standardAppearance = UITabBarAppearance()
        standardAppearance.configureWithTransparentBackground()
        standardAppearance.backgroundEffect = UIBlurEffect(style: .systemThinMaterial)
        
        UITabBar.appearance().standardAppearance = standardAppearance
        UITabBar.appearance().scrollEdgeAppearance = standardAppearance
        UITabBar.appearance().alpha = 0.90
        
    }
    
    var body: some View {
        
        if !welcomeScreenShown {
            
            WelcomeView()
                .environment(\.managedObjectContext, viewContext)
            
        } else {
            
            TabView{
                CareKitView().tabItem{
                    Label("Cure", systemImage: "pills")
                }
                InsightsView().tabItem{
                    Label("Insights", systemImage: "chart.xyaxis.line")
                }
                GestioneCureView().tabItem{
                    Label("Gestione", systemImage: "folder.fill")
                }
                ControlView().tabItem{
                    Label("SmartDispenser", systemImage: "tray.2.fill")
                }.environment(\.managedObjectContext, viewContext)
                    
            }.onAppear {
                
                /* Richiesta di autorizzazione alla ricezione delle notifiche */
                UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { success, error in
                    if success {
                        print("All set!")
                    } else if let error = error {
                        print(error.localizedDescription)
                    }
                }
                
                UIApplication.shared.applicationIconBadgeNumber = 0 /* Azzeramento del numero di notifiche  */
    
            }
    
        }
    }
    
}





/*
struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Item.timestamp, ascending: true)],
        animation: .default)
    private var items: FetchedResults<Item>

    var body: some View {
        NavigationView {
            List {
                ForEach(items) { item in
                    NavigationLink {
                        Text("Item at \(item.timestamp!, formatter: itemFormatter)")
                    } label: {
                        Text(item.timestamp!, formatter: itemFormatter)
                    }
                }
                .onDelete(perform: deleteItems)
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
                }
                ToolbarItem {
                    Button(action: addItem) {
                        Label("Add Item", systemImage: "plus")
                    }
                }
            }
            Text("Select an item")
        }
    }

    private func addItem() {
        withAnimation {
            let newItem = Item(context: viewContext)
            newItem.timestamp = Date()

            do {
                try viewContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }

    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            offsets.map { items[$0] }.forEach(viewContext.delete)

            do {
                try viewContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
}

private let itemFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    formatter.timeStyle = .medium
    return formatter
}()

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
 */
