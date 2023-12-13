//
//  Utente+CoreDataProperties.swift
//  ICare4U
//
//  Created by Teodoro Adinolfi on 26/04/22.
//
//

import Foundation
import CoreData


extension Utente {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Utente> {
        return NSFetchRequest<Utente>(entityName: "Utente")
    }

    @NSManaged public var cognome: String?
    @NSManaged public var dataNascita: Date?
    @NSManaged public var id: UUID?
    @NSManaged public var nome: String?
    @NSManaged public var prescrizione: NSSet?

}

// MARK: Generated accessors for prescrizione
extension Utente {

    @objc(addPrescrizioneObject:)
    @NSManaged public func addToPrescrizione(_ value: Cura)

    @objc(removePrescrizioneObject:)
    @NSManaged public func removeFromPrescrizione(_ value: Cura)

    @objc(addPrescrizione:)
    @NSManaged public func addToPrescrizione(_ values: NSSet)

    @objc(removePrescrizione:)
    @NSManaged public func removeFromPrescrizione(_ values: NSSet)
    
    
    // La coppia di funzioni permettono l'aggiunta e la rimozione di una cura a carico dell'utente
    func addPrescrizione(cura: Cura){
        let items = self.mutableSetValue(forKey: "prescrizione")
        items.add(cura)
    }
    
    func removePrescrizione(cura:Cura){
        let items = self.mutableSetValue(forKey: "prescrizione")
        items.remove(cura)
    }

}

extension Utente : Identifiable {

}
