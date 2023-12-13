//
//  SintomiView.swift
//  ICare4U
//
//  Created by Emilio Amato on 19/06/22.
//

import SwiftUI
import CoreData


struct registraSintomiView: View {
    
    @Environment(\.dismiss) var dismiss
    @Environment(\.presentationMode) var presentationMode
    @State private var farmaco = "Nessuna selezione"
    @State private var selectedCura = "Nessuna selezione"
    @State private var selectedAssunzione = "Nessuna selezione"
    @State private var selectedFarmaco = "Nessuna selezione"
    @State private var effetto: Double = 0
    @State private var message: Message? = nil
    @State private var symp: String = "Nessun sintomo"
    private var cureDisplay: [String] = ["Nessuna selezione"]
    var farmaciDisplay: [String] = ["Nessuna selezione"]
    @State var trigInfo = false
    
   
    let context : NSManagedObjectContext
    let cura: [Cura]

    
    init(cura: [Cura], context: NSManagedObjectContext){
        self.cura = cura
        self.context = context
       
        /* Popolamento di tutte le cure dell'utente al fine della loro visualizzazione */
        
        for c in cura {
            cureDisplay.append(c.nome)
        }
        
    }
   
    
    var body: some View {
    
        
        NavigationView{
            
            /* Background definito sulla view */
            splashImageBackground.overlay(
                
                    Form {
                        
                        Section(header: Text("Cura") ){
                        
                            
                            Picker("Seleziona la cura", selection: $selectedCura) {
                                ForEach(cureDisplay, id: \.self) {
                                                   Text($0)
                                               }
                            }.pickerStyle(.menu)
                        }
                        
                        
                        /* Sezione da mostrare solo se una cura è selezionata */
                        
                        if(selectedCura != "Nessuna selezione"){
                            
                            Section(header: Text("Farmaco")){
                                
                                Picker("Seleziona farmaco", selection: $selectedFarmaco) {
                                    
                                    ForEach(ottieniNomi(cu: selectedCura), id: \.self) {
                                                       Text($0)
                                                   }
                                }.pickerStyle(.menu)
                            
                            }
                            
                            /* Sezione da mostrare solo se un farmaco è selezionato */
                            
                            if(selectedFarmaco !=  "Nessuna selezione"){
                                
                                /* Se il risultato della ottieni assunzioni non è vuoto ed ha lunghezza > 1 (perchè il primo elemento è la
                                 stringa "Nessuna selezione", al fine della visualizzazione come scelta nel picker), allora mostra la restante parte del form da compilare, altrimenti appararirà il testo indicante l'assenza di assunzioni da registrare */
                                
                                if(!ottieniAssunzioni(cu: selectedCura, farmaco: selectedFarmaco).isEmpty && ottieniAssunzioni(cu: selectedCura, farmaco: selectedFarmaco).count > 1 ){
                                    
                                    Section(header: Text("Seleziona assunzione")){
                                        Picker("Seleziona la specifica assunzione",selection: $selectedAssunzione){
                                            
                                            ForEach(ottieniAssunzioni(cu: selectedCura, farmaco: selectedFarmaco), id: \.self) {
                                                               Text($0)
                                                           }
                                        }.pickerStyle(.menu).foregroundColor(.green)
                                    }
                            
                                    /* Sezione da mostrare solo se c'è un assunzione selezionata */
                                    
                                            if(selectedAssunzione != "Nessuna selezione"){
                                                
                                                /* Sezione relativa alla misurazione degli effetti */
                                                
                                                    Section(header: HStack(spacing: 40){
                                                        Text("Effetti")
                                                        
                                                        Spacer()
                                                        
                                                        Button{
                                                            message = Message(text: "Valuta quanto l'assunzione del farmaco prescelto ha avuto effetto rispetto alla malattia trattata")
                                                        }label: {
                                                            Image(systemName: "info.circle").foregroundColor(.blue)
                                                        }.buttonStyle(PlainButtonStyle())
                                                        .alert(item: $message){ message in
                                                            
                                                            Alert(
                                                                title: Text(message.text),
                                                                dismissButton: .default(Text("Capito"))
                                                            )
                                                            
                                                        }
                                                        
                                                    }
                                                    ){
                                                        
                                                        Text("Effetto farmaco: \(Int(effetto))")
                                                        Slider(value: $effetto, in: 0...10)
                                                    }
                                        
                                        
                                                /* Sezione relativa alla registrazione eventuale di sintomi, di default impostata a "Nessun sintomo" */
                                                
                                                    Section(header: HStack(spacing: 40){
                                                        
                                                        Text("Sintomi riscontrati")
                                                    
                                                        Spacer()
                                                        
                                                        Button{
                                                            message = Message(text: "Al fine di poter valutare l'efficacia del farmaco, registra i tuoi riscontri")
                                                        }label: {
                                                            Image(systemName: "info.circle").foregroundColor(.blue)
                                                        }.buttonStyle(PlainButtonStyle())
                                                        .alert(item: $message){ message in
                                                            
                                                            Alert(
                                                                title: Text(message.text),
                                                                dismissButton: .default(Text("Capito"))
                                                            )
                                                            
                                                        }
                                                        
                                                    }){
                                                        TextField("Cosa hai riscontrato ?", text: $symp)
                                                    }
                                        }
                                
                                }else{
                                    Text("Non ci sono assunzioni da registrare per il farmaco scelto").font(.caption2).foregroundColor(.red)
                                }
                            
                            }
                            
                        }
                            
                    }
                    )
                    .navigationTitle("Sintomi registrati")
                    .toolbar{
                        
                        ToolbarItem(placement: .navigationBarLeading){
                            Button("Indietro"){
                                dismiss()
                            }.foregroundColor(.red)
                        }
                        
                        ToolbarItem(placement: .navigationBarTrailing){
                        Button("Registra"){
                            
                            
                            var cur: Cura?
                            var farma: Farmaco?
                            let data = DateFormatter()
                            data.dateFormat = "dd/MM/yyyy HH:mm"
                        
                            /* Se tutti i campi del form sono stati compilati correttamente, allora si procede alla registrazione. In caso contrario, si
                             mostra un alert il quale invita l'utente a compilare tutti i campi del form. */
                            
                            if(selectedCura != "Nessuna selezione" && selectedFarmaco != "Nessuna selezione" && selectedAssunzione != "Nessuna selezione" ){
                                
                                        /* Recupero cura selezionata dall'utente scorrendo l'array di cure e selezionando quella con nome pari a quello selezionato dall'utente */
                                
                                        for c in cura{
                                            if(c.nome == selectedCura){
                                                cur = c
                                            }
                                            
                                        }
                                    
                                        /* Dalla cura selezionata, recupero tutti i farmaci ad essa assocati*/
                                
                                        let farmaci = CoreDataController(context: context).allFarmaciOf(cura: cur!)!
                                            
                                        /* Recupero farmaco selezionato dall'utente scorrendo l'array di farmaci e selezionando quellao con nome pari a quello selezionato dall'utente */
                                
                                        for f in farmaci {
                                            if(f.nome == selectedFarmaco){
                                                farma = f
                                            }
                                        }
                                            
                                        /* Dal farmaco selezionato, recupero tutte le assunzioni associate */
                                
                                        let ass :[Assunzione] = CoreDataController(context: context).allAssunzioneOf(farmaco: farma!)!
                                        var assunzione: Assunzione?  /* Dichiarazione dell'assunzione che andrà ad essere gestita per il salvataggio della registrazione */
                                        
                                        /* Recupero assunzione selezionata dall'utente scorrendo l'array di assunzioni e selezionando quella
                                         con orario programmato pari a quello selezionato dall'utente */
                                
                                        for a in ass{
                                            if(data.string(from: a.orarioProgrammato!) == selectedAssunzione){
                                                assunzione = a
                                            }
                                        }
                                        
                                        /* Aggiornamento della specifica assunzione associata al farmaco di una specifica cura, registrando i sintomi */
                                        CoreDataController(context: context).updateAssunzione(assunzione: assunzione!, effetto: Int16(effetto), sintomi: symp)
                                        presentationMode.wrappedValue.dismiss() /* Dismiss della sheet */
                            }
                            else{
                                trigInfo.toggle() /* Toggle per l'attivazione dell'alert */
                            }
                        
                        }.foregroundColor(.blue).alert(isPresented: $trigInfo){
                            /* Contenuto dell'alert */
                            Alert(title: Text("Attenzione"), message: Text("Compila tutti i campi del form"), dismissButton: Alert.Button.default(Text("Capito")))
                        }
                        }
                    }
        }
            
           
            
    }
    
    /* Background da applicare alla view */
    var splashImageBackground: some View {
           GeometryReader { geometry in
               Image("medicalv")
                   .resizable()
                   .aspectRatio(contentMode: .fill)
                   .edgesIgnoringSafeArea(.all)
                   .frame(width: geometry.size.width)
                   .opacity(0.15)
           }
       }
    

    
    /* Funzione di utilità per il popolamento del picker di selezione dei farmaci, la quale riceve in ingresso il nome della cura, recupera con quest'ultimo
     l'entità cura associata e , con la allFarmaciOf,vengono recuperati tutti i farmaci della cura, restituendo un array di stringhe contenente tutti i nomi di quest'ultimi, insieme
     alla selezione "Nessuna selezione" messa come elemento dell'array al fine di gestire la visualizzazione nel form */
    
    func ottieniNomi(cu: String) -> [String]{
        
        var cur: Cura?
        
        for c in cura{
            if(c.nome == cu){
                cur = c
            }
        }
        
        if(cur == nil){
            return []
        }
        
        let farmaci = CoreDataController(context: context).allFarmaciOf(cura: cur!)!
        var nomi :[String] = []
        
        nomi.append("Nessuna selezione")
        
        for f in farmaci{
            nomi.append(f.nome)
        }
        
        return nomi /* array di stringhe con i nomi dei farmaci della cura selezionata */
    }
    

    
    
    
    
    /* Funzione di utilità per il popolamento del picker di selezione delle assunzioni, la quale riceve in ingresso il nome della cura e del farmaco selezionato, recupera con quest'ultimo
     l'entità cura associata e , con la allFarmaciOf,vengono recuperati tutti i farmaci della cura, per poi procedere con il farmaco selezionato al recupero di tutte le assunzioni ad esso
     associate restituendo un array di stringhe contenente tutti i nomi di quest'ultime, insieme alla selezione "Nessuna selezione" messa come elemento dell'array al fine di gestire la
     visualizzazione nel form */
    
    func ottieniAssunzioni(cu: String, farmaco: String) -> [String]{
    
        var cur: Cura?
        var farma: Farmaco?
        let data = DateFormatter()
        data.dateFormat = "dd/MM/yyyy HH:mm"
    
        for c in cura{
            if(c.nome == cu){
                cur = c
            }
            
        }
    
        if(cur == nil){
            return []
        }
        let farmaci = CoreDataController(context: context).allFarmaciOf(cura: cur!)!
            
        for f in farmaci {
            if(f.nome == farmaco){
                farma = f
            }
        }
            
        let ass :[Assunzione] = CoreDataController(context: context).allAssunzioneOf(farmaco: farma!)!
        var orari: [String] = []
            
        orari.append("Nessuna selezione")
        
        for a in ass{
            if(a.orarioProgrammato! <= Date.now && a.sintomiPresenti == false){
                orari.append(data.string(from: a.orarioProgrammato!))
            }
        }
        
        return orari /* array di stringhe con gli orari delle assunzioni  del farmaco della cura selezionata */
    
    
    }

}


/* Struttura creata per la gestione dell'alert */

struct Message: Identifiable{
    
    let id = UUID()
    let text: String
    
}



