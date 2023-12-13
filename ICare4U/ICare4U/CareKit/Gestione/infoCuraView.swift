//
//  addCuraView.swift
//  ICare4U
//
//  Created by Teodoro Adinolfi on 16/06/22.
//

import SwiftUI
import CoreData

/// La classe farmaco container permette di gestire dinamicamente una lista di farmaci ottenuta a partire dalle informazioni presenti all'interno del core data
class FarmacoContainer : ObservableObject {
    
    @Published var farmaci : [Farmaco] = []
     var context : NSManagedObjectContext?
     var cura : Cura?
    
    ///permette di aggionrare la proprietà farmaci conservata all'interno dell'oggetto
    public func aggiornaFarmaci(){
        farmaci = CoreDataController(context: context!).allFarmaciOf(cura: cura!) ?? []
    }
    
    ///Permette di settare la proprietà interna contesto
    public func setContext(context : NSManagedObjectContext){
        self.context = context
    }
    
    ///Permette di settare la proprietà interna cura
    public func setCura(cura: Cura){
        self.cura = cura
    }
    
    public func rimuoviFarmaco(toRemove: Farmaco){
        if (context == nil || cura==nil) {
            print("Tutte le proprietà di farmacoContanier devono essere state settate")
            return
        }
        for elem in farmaci{
            if(elem == toRemove){
                CoreDataController(context: context!).removeFarmaco(cura: cura!, farmaco: toRemove)
                aggiornaFarmaci()
                context!.delete(elem)
                return
            }
        }
        print("Il farmaco selezionato non appartiene alla cura attuale")
        return
    }
    
}

struct infoCuraView: View {
    
    let context: NSManagedObjectContext
    @ObservedObject var cura: Cura
    let inizio: Date

    
    init(cura: Cura, context: NSManagedObjectContext, inizio: Date){
        self.cura = cura
        self.context = context
        self.inizio = inizio
    }
    
    var body: some View {
       
        VStack{
            intestazione(cura: cura, inizio: inizio)
                .padding(10)
            Spacer()
            corpo(cura: cura, context: context)
            .padding(10)
            .padding(.bottom,20)
        }.navigationBarTitleDisplayMode(.inline).background(Image("medicalg").resizable().scaledToFill().ignoresSafeArea().opacity(0.15)).onAppear(){
            UITableView.appearance().backgroundColor = .clear
        }
    }
    
    
}

struct intestazione: View{
    
    var cura: Cura
    var dateFormatter: DateFormatter
    let inizio: Date
    
    @State var trig = false
    @State var trigInfo = false
    
    init(cura: Cura,inizio: Date){
        self.cura = cura
        self.inizio = inizio
        self.dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy"
    }
    
    var body: some View{
        VStack{
            HStack{
                Text("\(cura.nome)")
                    .fontWeight(.semibold)
                    .font(.system(size: 30))
                Spacer()
                if(cura.dataFine == nil){
                    Button{
                        trig.toggle()
                    } label: {
                        Image(systemName: "square.and.pencil")
                            .foregroundColor(.blue)
                    }.sheet(isPresented: $trig){
                        addCuraView(trig: $trig,cura: cura)
                    }
                }
            }
            ZStack(alignment: .leading){
                    RoundedRectangle(cornerRadius: 25, style: .continuous)
                    .fill(Color("cardBackground"))
                    .shadow(radius: 10)
               
                .padding(15)
                HStack(alignment: .center){
                    Image("doctorNew")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 60, height: 60, alignment: .center)
                    VStack(alignment: .leading){
                        Text("Dott: \(cura.medico)")
                            .bold()
                        Text("Iniziata in data: \(dateFormatter.string(from: inizio))")
                            .italic()
                            .fontWeight(Font.Weight.thin)
                    }.padding(20)
                    
                    Spacer()
                    
                    Button{
                        trigInfo.toggle()
                    } label: {
                        Image(systemName: "info.circle")
                            .foregroundColor(.blue)
                    }.alert(isPresented: $trigInfo){
                        
                        Alert(title: Text("Informazioni"), message: Text("\(cura.descrizione!)"), dismissButton: Alert.Button.default(Text("Capito")))
                    }
                    
                }.padding(25)
            }
            .frame(width: 400, height: 100)
        }.padding(20)
    }
    
}



struct corpo: View{
    
    private var cura:Cura
    private var context : NSManagedObjectContext
    @State var trig : Bool
    @State var isShowing : Bool
    @StateObject var farmaci : FarmacoContainer = FarmacoContainer()
    
    init(cura: Cura, context: NSManagedObjectContext){
        
        self.cura = cura
        self.context = context
        trig = false
        isShowing = false
        
    }
    
    var body: some View{
        
        ZStack{
            
            RoundedRectangle(cornerRadius: 25, style: .continuous)
            .fill(Color("cardBackground"))
            .shadow(radius: 10)
            
            VStack(alignment: .center){
                if(farmaci.farmaci.isEmpty ){
                    Image("noData")
                        .resizable()
                        .frame(width: 300, height: 300, alignment: .center)
                    Text("Nessun farmaco qui...")
                        .bold()

                    Button{
                        trig.toggle()
                    } label: {
                        Image(systemName: "plus.circle")
                            .resizable()
                            .frame(width: 50, height: 50, alignment: .center)
                            .shadow(color: .black, radius: 0.5)
                    }
                    .foregroundColor(.blue)
                    .sheet(isPresented: $trig){
                        addFarmacoView(context: context, cura:cura, farmacoContainer: farmaci)
                    }
                
                } else {
                    List{
                        Section(header: Text("Farmaci prescritti"))
                            {
                            ForEach(farmaci.farmaci){ farmaco in
                                farmacoElem(farmaco: farmaco,farmacoContainer: farmaci, context: context)
                            }
                        }
                        .headerProminence(.increased)
                        if(cura.dataFine == nil){
                            Section(header: Text("Aggiungi").bold()){
                                Button("Aggiungi un farmaco"){
                                    trig.toggle()
                                }.sheet(isPresented: $trig){
                                    addFarmacoView(context: context, cura:cura,farmacoContainer: farmaci)
                                }
                            }
                        }
                    }.refreshable {
                        farmaci.aggiornaFarmaci()
                    }
                }
                
            }.padding(10)
                .onAppear{
                    farmaci.setCura(cura: cura)
                    farmaci.setContext(context: context)
                    farmaci.aggiornaFarmaci()
                }
        }
        
    }
    
    
}

struct farmacoElem: View {
    
    let farmaco: Farmaco
    let farmacoContainer : FarmacoContainer
    let dateFormatter : DateFormatter
    let context: NSManagedObjectContext
    
    
    init(farmaco: Farmaco , farmacoContainer: FarmacoContainer, context: NSManagedObjectContext){
        self.farmaco = farmaco
        self.farmacoContainer = farmacoContainer
        dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy"
        self.context = context
    }
    
    var body: some View{
            HStack(spacing: 10){
                Image("medicine")
                     .resizable()
                     .scaledToFit()
                     .frame(width: 40, height: 40)
          
                Text("\(farmaco.nome)")
                    .bold()
                    .contextMenu{
                        if (farmacoContainer.cura!.dataFine == nil){
                            Button(role: .destructive){
                                
                                let assunzioni = CoreDataController(context: context).allAssunzioneOf(farmaco: farmaco)
                                var notificationId: [String] = []
                                
                                for a in assunzioni!{
                                    notificationId.append(a.id!.description)
                                    deleteTask(id: a.id!.description)
                                }
                                
                                UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: notificationId)
                                farmacoContainer.rimuoviFarmaco(toRemove: farmaco)
                            } label: {
                                Label("Elimina", systemImage: "trash")
                                    .foregroundColor(Color.red)
                            }
                        }
                        Text("Inizio assunzione: \(dateFormatter.string(from: farmaco.caratterizzazione!.dataInizio))")
                        Text("Modalità di assunzione: \(farmaco.caratterizzazione!.frequenza)")
                        
                    }
                
            }.padding(10)
    }
}

