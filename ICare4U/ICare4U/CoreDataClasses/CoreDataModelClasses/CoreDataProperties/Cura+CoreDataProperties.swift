//
//  Cura+CoreDataProperties.swift
//  ICare4U
//
//  Created by Teodoro Adinolfi on 26/04/22.
//
//

import Foundation
import CoreData


extension Cura {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Cura> {
        return NSFetchRequest<Cura>(entityName: "Cura")
    }

    @NSManaged public var dataInizio: Date
    @NSManaged public var descrizione: String?
    @NSManaged public var id: UUID?
    @NSManaged public var medico: String
    @NSManaged public var prescrizione: Utente
    @NSManaged public var composizione: NSSet?
    @NSManaged public var nome: String
    @NSManaged public var dataFine : Date?
    
    
    // Aggiungere un farmaco alla relazione composizione
    /*
     NSSet è un set immutabile di oggetti , mediante la funzione add farmaco andiamo a richiedere prima di tutto una versione mutabile del set, cercandolo per chiave specificando il nome della relazione.
     A questo punto invochiamo il metodo add / remove per aggiungere o rimuovere l' elemento dal set
     */
    func addFarmaco(farmaco: Farmaco){
        let items = self.mutableSetValue(forKey: "composizione")
        items.add(farmaco)
    }
    
    func removeFarmaco(farmaco: Farmaco){
        let items = self.mutableSetValue(forKey: "composizione")
        items.remove(farmaco)
    }

}

extension Cura : Identifiable {

}
