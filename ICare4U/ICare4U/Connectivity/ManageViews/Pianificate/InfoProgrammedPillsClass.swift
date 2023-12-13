//
//  InfoProgrammedPillsClass.swift
//  ICare4U
//
//  Created by Antonio Bove on 24/06/22.
//

import SwiftUI
import CoreData

class InfoProgrammedPillsClass: ObservableObject {
    
    @Published var programmedPills: [(cura: String, farmaco: String, orario: String, dispenser: String)] = []
    @Published var done: Bool = false
        
    private var context: NSManagedObjectContext?
    
    /*
        Mutator method per settare il valore della variabile context.
    */
    public func setContext(context: NSManagedObjectContext){
        self.context = context
    }
    
    /*
        La seguente funzione recupera dal Core Data le informazioni associate alle assunzini inviate allo SmartDispenser
        per visualizzarle come una lista di cards in ProgrammedPillsView. Vengono inoltre ordinate in basa alla data e ora 
        di assunzione.
    */
    public func getProgrammedPills() {
        
        programmedPills.removeAll()
        
        let dispenserArray = CoreDataController(context: context!).allDispenser()
        
        if(dispenserArray == nil){
            print("Nessun dispenser trovato")
            return
        }
        
        let orario = DateFormatter()
        orario.dateFormat = "dd/MM/yyyy HH:mm"
        for elem in dispenserArray! {
            
            if(elem.contenuti != nil) {
                
                for item in CoreDataController(context: context!).allAssunzioneOf(farmaco: elem.contenuti!)! {
                    
                    if(item.associabileAlDispenser == true && !item.assunzionePassata) {
                        self.programmedPills.append((cura: elem.contenuti!.composizione!.nome, farmaco: elem.contenuti!.nome, orario: orario.string(from: item.orarioProgrammato!), dispenser: elem.nome == "Dispenser 1" ? "1" : "2"))
                    }
                    
                }
                
            }
            
        }
        
        if(!programmedPills.isEmpty) {
            programmedPills = programmedPills.sorted {
                orario.date(from: $0.2)! < orario.date(from: $1.2)!
            }
        }
        
        self.done = true
        
    }
    
    /*
        La seguente funzione elimina la programmazione di una specifica assunzione, ripristinando anche i valori dei corrispondenti
        attributi nel Core Data.
    */
    public func removeProgrammedPill(index: Int, orario: String) {
        
        let assunzioni = CoreDataController(context: context!).allAssunzioneOf(farmaco: CoreDataController(context: context!).searchFarmaco(nome: programmedPills[index].farmaco)!)
        
        if(assunzioni == nil) {
            print("Nessuna assunzione presente")
            return
        }
        
        for elem in assunzioni! {
            
            let orarioFormatter = DateFormatter()
            orarioFormatter.dateFormat = "dd/MM/yyyy;HH:mm"
            
            if(elem.orarioProgrammato == orarioFormatter.date(from: orario)) {
                elem.associabileAlDispenser = false
                CoreDataController(context: context!).salva()
                programmedPills.remove(at: index)
                return 
            }
        }
    }

}


