//
//  InfoHistoricalPillsClass.swift
//  ICare4U
//
//  Created by Antonio Bove on 25/06/22.
//

import SwiftUI
import CoreData

class InfoHistoricalPillsClass: ObservableObject {
    
    @Published var historicalPills: [(cura: String, farmaco: String, orario: String, stato: Bool)] = []
    @Published var done: Bool = false
    
    private var context: NSManagedObjectContext?
    
    /*
        Mutator method per settare il valore della variabile context.
    */
    public func setContext(context: NSManagedObjectContext){
        self.context = context
    }
    
    /*
        La seguente funzione recupera dal Core Data le assunzioni associate allo SmartDispenser che sono già passate,
        per il popolamento dello Storico.
    */
    public func getHistoricalPills() {
        
        historicalPills.removeAll()
        
        let assunzioniArray = CoreDataController(context: context!).assunzioniAssociateAlDispenser()
        
        if(assunzioniArray.isEmpty){
            print("Nessuna assunzione")
            return
        }
        
        let orario = DateFormatter()
        orario.dateFormat = "dd/MM/yyyy HH:mm"
        for elem in assunzioniArray {
            if(elem.assunzionePassata) {
                self.historicalPills.append((cura: elem.assunzioniProgrammate!.caratterizzazione!.composizione!.nome, farmaco: elem.assunzioniProgrammate!.caratterizzazione!.nome, orario: orario.string(from: elem.orarioProgrammato!), stato: elem.erogato)) 
            }
        }
        
        self.done = true
        
    }
    
    /*
        La seguente funzione rimuove dallo Storico una determinata assunzione, ripristinando anche i valori dei corrispondenti
        attributi nel Core Data. Si assume come pre-condizione che non vi possono essere due assunzioni per lo stesso farmaco 
        che presentano medesima data e ora.
    */
    public func removeHistoricalPill(index: Int, orario: String) {
        
        let assunzioni = CoreDataController(context: context!).allAssunzioneOf(farmaco: CoreDataController(context: context!).searchFarmaco(nome: historicalPills[index].farmaco)!)
        
        if(assunzioni == nil) {
            print("Nessuna assunzione presente")
            return
        }
        
        for elem in assunzioni! {
            
            let orarioFormatter = DateFormatter()
            orarioFormatter.dateFormat = "dd/MM/yyyy;HH:mm"
            
            if(elem.orarioProgrammato == orarioFormatter.date(from: orario)) {
                elem.associabileAlDispenser = false
                elem.assunzionePassata = false
                CoreDataController(context: context!).salva()
                historicalPills.remove(at: index)
                return
                
            }
            
        }
    }
    
    /*
        La seguente funzione rimuove tutte le assunzioni dallo Storico, ripristinando anche i valori dei corrispondenti
        attributi nel Core Data.
    */
    public func removeAllHistoricalPill() {
        
        var farmaci: [String] = []
        
        for i in 0..<(historicalPills.count - 1) {
            if(historicalPills[i].farmaco != historicalPills[i + 1].farmaco) {
                farmaci.append(historicalPills[i].farmaco)
            }
        }
        farmaci.append(historicalPills[historicalPills.count - 1].farmaco)
        
        let orarioFormatter = DateFormatter()
        orarioFormatter.dateFormat = "dd/MM/yyyy;HH:mm"
        
        for elem in farmaci {
            
            let assunzioni = CoreDataController(context: context!).allAssunzioneOf(farmaco: CoreDataController(context: context!).searchFarmaco(nome: elem)!)
            
            if(assunzioni != nil) {
                for item in assunzioni! {
                    item.associabileAlDispenser = false
                    item.assunzionePassata = false
                    CoreDataController(context: context!).salva()
                }
            }
        }
        
        historicalPills.removeAll()
    }
    
}
