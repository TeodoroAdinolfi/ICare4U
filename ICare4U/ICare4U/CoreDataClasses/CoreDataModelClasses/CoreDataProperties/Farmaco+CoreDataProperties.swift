//
//  Farmaco+CoreDataProperties.swift
//  ICare4U
//
//  Created by Teodoro Adinolfi on 26/04/22.
//
//

import Foundation
import CoreData


extension Farmaco {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Farmaco> {
        return NSFetchRequest<Farmaco>(entityName: "Farmaco")
    }

    @NSManaged public var aic: String?
    @NSManaged public var nCompresse: Int16
    @NSManaged public var nome: String
    @NSManaged public var quantita: Int16
    @NSManaged public var scadenza: Date?
    @NSManaged public var caratterizzazione: Informazione?
    @NSManaged public var composizione: Cura?
    @NSManaged public var associato: Dispenser?
    @NSManaged public var id: UUID

}

// MARK: Generated accessors for utilizzo
extension Farmaco {

    @objc(addUtilizzoObject:)
    @NSManaged public func addToUtilizzo(_ value: Assunzione)

    @objc(removeUtilizzoObject:)
    @NSManaged public func removeFromUtilizzo(_ value: Assunzione)

    @objc(addUtilizzo:)
    @NSManaged public func addToUtilizzo(_ values: NSSet)

    @objc(removeUtilizzo:)
    @NSManaged public func removeFromUtilizzo(_ values: NSSet)
    
    /*
    func addInformazione(informazione: Informazione){
        let items = self.mutableSetValue(forKey: "caratterizzazione")
        items.add(informazione)
    }
    
    func removeInformazione(informazione : Informazione){
        let items = self.mutableSetValue(forKey: "caratterizzazione")
        items.remove(informazione)
    }*/

}

extension Farmaco : Identifiable {

}
