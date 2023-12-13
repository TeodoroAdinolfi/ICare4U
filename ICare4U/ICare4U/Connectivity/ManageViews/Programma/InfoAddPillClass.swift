//
//  InfoAddPillClass.swift
//  ICare4U
//
//  Created by Antonio Bove on 24/06/22.
//

import SwiftUI
import CoreData

class InfoAddPillClass: ObservableObject {
    
    @Published var dispenser: [String] = ["Nessuna selezione"]
    @Published var cure: [String] = ["Nessuna selezione"]
    @Published var farmaci: [String] = ["Nessuna selezione"]
    @Published var orari: [String] = []
    
    private var dispenserTmp: [Dispenser] = []
    private var cureTmp: [Cura] = []
    private var farmaciTmp: [Farmaco] = []
    
    private var context: NSManagedObjectContext?
    
    /*
        Mutator method per settare il valore della variabile context.
    */
    public func setContext(context: NSManagedObjectContext){
        self.context = context
    }
    
    /*
        La seguente funzione recupera dal Core Data i dispenser presenti per il popolamento del form in NewPillView.
    */
    public func getDispenser() {
        
        self.dispenser = ["Nessuna selezione"]
        
        if(context == nil) {
            print("Contesto nil")
            return
        }
        
        let dispTmp = CoreDataController(context: context!).allDispenser()
        
        if(dispTmp == nil) {
            print("Non ci sono dispenser")
            return
        }
        
        dispenserTmp = dispTmp!
        for elem in dispTmp! {
            dispenser.append(elem.nome)
        }
        
       return
        
    }
    
    /*
        La seguente funzione recupera dal Core Data le cure presenti per il popolamento del form in NewPillView.
    */
    public func getCure() {
        
        self.cure = ["Nessuna selezione"]
        
        if(context == nil) {
            print("Contesto nil")
            return
        }
        
        do {
            let req = Cura.fetchRequest()
            let res = try context!.fetch(req)
            
            cureTmp = res
            for elem in res {
                cure.append(elem.nome) 
            }
            
        } catch {
            print("Error fetching")
        }
        
        return
            
    }
    
    /*
        La seguente funzione recupera dal Core Data i farmaci associati alla cura per il popolamento del form in NewPillView.
    */
    public func getFarmaci(cura: String) {
        
        self.farmaci = ["Nessuna selezione"]
        
        if(context == nil) {
            print("Contesto nil")
            return
        }
        
        let selectedCura = CoreDataController(context: context!).searchCura(nome: cura)
        
        let farmaci = CoreDataController(context: context!).allFarmaciOf(cura: selectedCura!)
        
        if(farmaci == nil) {
            print("Nessun farmaco presente")
            return
        }
        
        farmaciTmp = farmaci!
        for elem in farmaci! {
            self.farmaci.append(elem.nome)
        }
    }
    
    /*
        La seguente funzione recupera dal Core Data le assunzioni presenti al fine di inviarle allo SmartDispenser.
    */
    public func getAssunzioni(farmaco: String) {
        
        self.orari = []
        
        if(context == nil) {
            print("Contesto nil")
            return
        }
        
        let selectedFarmaco = CoreDataController(context: context!).searchFarmaco(nome: farmaco)
        
        let assunzioni = CoreDataController(context: context!).allAssunzioneOf(farmaco: selectedFarmaco!)
        
        if(assunzioni == nil) {
            print("Nessuna assunzione presente")
            return
        }
        
        let orario = DateFormatter()
        orario.dateFormat = "dd/MM/yyyy;HH:mm"
        for elem in assunzioni! {
            if(!elem.assunzionePassata) {
                elem.associabileAlDispenser = true
                CoreDataController(context: context!).salva()
                self.orari.append(orario.string(from: elem.orarioProgrammato!))
            }
        }
        
    }
    
    /*
        La seguente funzione associa un farmaco ad uno specifico dispenser
    */
    public func linkDispenserToFarmaco(dispenser: String, farmaco: String) -> Bool {
        
        let selectedDisp = CoreDataController(context: context!).searchDispenser(nome: dispenser)
        let selectedFarmaco = CoreDataController(context: context!).searchFarmaco(nome: farmaco)
        
        if (selectedDisp == nil || selectedFarmaco == nil) {
            return false
        }
        
        if(selectedDisp!.contenuti == nil && selectedFarmaco!.associato == nil) {

            CoreDataController(context: context!).linkDispenserToFarmaco(dispenser: selectedDisp!, farmaco: selectedFarmaco!)
            return true
            
        } else {

            return false
        }
        
    }
    
}


