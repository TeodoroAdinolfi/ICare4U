//
//  Assunzione+CoreDataProperties.swift
//  ICare4U
//
//  Created by Teodoro Adinolfi on 22/06/22.
//
//

import Foundation
import CoreData


extension Assunzione {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Assunzione> {
        return NSFetchRequest<Assunzione>(entityName: "Assunzione")
    }

    @NSManaged public var id: UUID?
    @NSManaged public var assunzionePassata: Bool
    @NSManaged public var orarioProgrammato: Date?
    @NSManaged public var sintomi: String?
    @NSManaged public var assunzioniProgrammate: Informazione?
    @NSManaged public var effetto: Int16
    @NSManaged public var sintomiPresenti: Bool
    @NSManaged public var erogato: Bool
    @NSManaged public var associabileAlDispenser: Bool

}

extension Assunzione : Identifiable {

}
