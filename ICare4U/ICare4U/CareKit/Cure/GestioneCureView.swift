//
//  GestioneCureView.swift
//  ICare4U
//
//  Created by Teodoro Adinolfi on 14/06/22.
//

import SwiftUI
import CoreData

class CureContainer : ObservableObject{
    
    private var context: NSManagedObjectContext?
    @Published var cure : [Cura] = []
    var cureTerminate: [Cura] = []
    @Published var done : Bool = false
    
    public func uploadCure(){
        if (context == nil) {return}
        CoreDataController(context: context!).fromCuraToTerminata()
        cureTerminate = CoreDataController(context: context!).allCureTerminate()
        cure = CoreDataController(context: context!).allCureOf()
    }
    
    public func setContext(context:NSManagedObjectContext){
        self.context = context
    }
    
    
    
}

struct GestioneCureView: View {
    
    @Environment(\.managedObjectContext)  var context
    @FetchRequest(entity: Utente.entity(), sortDescriptors:[]) var user : FetchedResults<Utente>
    @State var trig = false
    @StateObject var cure = CureContainer()
    
    var body: some View {
        
        
        
        VStack{
                    NavigationView{
                        splashImageBackground.overlay(
                        List{
                            Section(header: Text("Cure Prescritte")){
                                ForEach(cure.cure){ cura in
                                    
                                    NavigationLink(destination: infoCuraView(cura:cura, context:context,inizio:cura.dataInizio)){
                                        Text("\(cura.nome)")
                                    }.listRowBackground(Color("navigationLinkBackground"))
                                    
                                    
                                }.onDelete{
                                    indexSet in
                                    removeItemsAt(offsets:indexSet, context: context, cure:cure)
                                }
                            }
                            
                            
                            Section(header: Text("Cure Terminate")){
                                ForEach(cure.cureTerminate){ cura in
                                    
                                    NavigationLink(destination: infoCuraView(cura:cura, context:context,inizio:cura.dataInizio)){
                                        Text("\(cura.nome)")
                                    } .listRowBackground(Color("navigationLinkBackground"))
                                
                                }
                            }
                            
                            
                                NavigationLink(destination: addCuraView(trig: $trig,cura: nil), isActive: $trig){
                                    Text("Aggiungi una cura...")
                                }.listRowBackground(Color("navigationLinkBackground"))
                            
                        }
                            .navigationTitle("Cure in corso")
                        )
                            
                    }
        }.onAppear(){
            cure.setContext(context: context)
            cure.done.toggle()
            UITableView.appearance().backgroundColor = .clear
        }.onChange(of: cure.done){
            _ in
            cure.uploadCure()
            
        }
        .environmentObject(cure)
        
    }
    var splashImageBackground: some View {
           GeometryReader { geometry in
               Image("medicalb")
                   .resizable()
                   .aspectRatio(contentMode: .fill)
                   .edgesIgnoringSafeArea(.all)
                   .frame(width: geometry.size.width)
                   .opacity(0.15)
           }
       }

    
    func removeItemsAt(offsets: IndexSet , context: NSManagedObjectContext, cure: CureContainer){
        
        for index in offsets {
           
            let farmaci = CoreDataController(context: context).allFarmaciOf(cura: cure.cure[index])
            var notificationId: [String] = []
            
            for f in farmaci!{
                let assunzioni = CoreDataController(context: context).allAssunzioneOf(farmaco: f)
                for a in assunzioni!{
                    notificationId.append(a.id!.description)
                    deleteTask(id: a.id!.description)
                }
            }
            
            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: notificationId)
            
            
            CoreDataController(context: context).removePrescrizione(utente: user.first!, remove: cure.cure[index])
            cure.uploadCure()
            
        }
        
    }
    
    
}

