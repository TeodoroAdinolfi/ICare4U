//
//  Informazione+CoreDataProperties.swift
//  ICare4U
//
//  Created by Teodoro Adinolfi on 22/06/22.
//
//

import Foundation
import CoreData


extension Informazione {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Informazione> {
        return NSFetchRequest<Informazione>(entityName: "Informazione")
    }

    @NSManaged public var dataInizio: Date
    @NSManaged public var durata: Int16
    @NSManaged public var frequenza: String
    @NSManaged public var id: UUID?
    @NSManaged public var assunzioniProgrammate: NSSet?
    @NSManaged public var caratterizzazione: Farmaco?

}

// MARK: Generated accessors for assunzioniProgrammate
extension Informazione {

    @objc(addAssunzioniProgrammateObject:)
    @NSManaged public func addToAssunzioniProgrammate(_ value: Assunzione)

    @objc(removeAssunzioniProgrammateObject:)
    @NSManaged public func removeFromAssunzioniProgrammate(_ value: Assunzione)

    @objc(addAssunzioniProgrammate:)
    @NSManaged public func addToAssunzioniProgrammate(_ values: NSSet)

    @objc(removeAssunzioniProgrammate:)
    @NSManaged public func removeFromAssunzioniProgrammate(_ values: NSSet)

}

extension Informazione : Identifiable {
    func addAssunzione(assunzione: Assunzione){
        let items = self.mutableSetValue(forKey: "assunzioniProgrammate")
        items.add(assunzione)
    }
    
    func removeAssunzione(assunzione : Assunzione){
        let items = self.mutableSetValue(forKey: "assunzioniProgrammateDroghiere ")
        items.remove(assunzione)
    }
}
