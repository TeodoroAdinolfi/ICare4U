//
//  CoreDataController.swift
//  ICare4U
//
//  Created by Teodoro Adinolfi on 26/04/22.
//

import Foundation
import CoreData
import UIKit
import SwiftUI




class CoreDataController{
      
    
    private var context: NSManagedObjectContext
    
    /**La classe CoreDataController si propone di gestire tutte le principali funzionalità del FrameWork di persistenza CoreData costruita nel contesto dell'Applicazione ICare4U*/
    public init(context: NSManagedObjectContext ){
        self.context = context
    }
    
    
    /**Funzion  di utilità che permette di salvare il contesto a seguito di una qualsiasi operazione*/
    public func salva(){
        do{
            try self.context.save()
        }catch{
            print("Errore durante il salvataggio")
        }
    }
    
    /**La funzione permette di ottenere l'utente che corrisponde ai campi specificati *Nota: può essere modificata anche per creare l'utente se non esiste,magari con un ulteriore campo booleano che attiva questa funzione*/
    func getUtente(nome: String , cognome: String , dataNascita: Date ) -> Utente?{
        
        let req = Utente.fetchRequest()
        do{
            let res = try context.fetch(req)
            for elem in res{
                if (elem.nome == nome && elem.cognome == cognome && elem.dataNascita == dataNascita){
                    return elem
                }
            }
        } catch {
            print("Errore, fetch request fallita")
        }
        print("Non esiste alcun utente con i dati specificati")
        //Nota in questo caso potremmo creare l'utente ed usare questa funzione comunque, in tal caso togliamo l'optional dal return
        return nil
    }
    
    /*MARK: Aggiunta modifica e rimozione entità*/
    
    /**Dato un utente permette di aggiungere una cura alla sua cartella clinica*/
    func addPrescrizione(utente: Utente,descrizione: String ,medico: String, dataInizio: Date){
        let cura = Cura(context: context)
        cura.dataInizio = dataInizio
        cura.descrizione = descrizione
        cura.medico = medico
        cura.id = UUID()
        cura.dataFine = nil
        utente.addPrescrizione(cura: cura)
        salva()
        print ("Cura aggiunta e salvata")
    }
    
    /** Permette l'inserimento di una cura con nome, l'altra funzione add prescrzione è stata mantenuta per retrocompatibilità*/
    func addPrescrizione(utente: Utente,nome: String,descrizione: String ,medico: String, dataInizio: Date){
        let cura = Cura(context: context)
        cura.nome = nome
        cura.dataInizio = dataInizio
        cura.descrizione = descrizione
        cura.medico = medico
        cura.id = UUID()
        cura.dataFine = nil
        utente.addPrescrizione(cura: cura)
        salva()
        print ("Cura aggiunta e salvata")
    }
    
    /**Specificata una cura la funzione permette di registrare un farmaco al suo interno*/
    func addFarmaco(cura:Cura ,nome : String ,aic : String , nCompresse: Int16 ,quantita: Int16,scadenza: Date)-> Farmaco{
        let farmaco = Farmaco(context:context)
        farmaco.nome = nome
        farmaco.aic = aic
        farmaco.nCompresse = nCompresse
        farmaco.quantita = quantita
        farmaco.scadenza = scadenza
        farmaco.id = UUID()
        cura.addFarmaco(farmaco: farmaco)
        salva()
        print("Farmaco aggiunto alla relativa cura con id \(farmaco.id)")
        return farmaco
    }
    

    
    /**Dato un farmaco permette di memorizzare informazioni ad esso relative, assunzioni  è un array contenente tutte le informazioni circa le date e gli orari  relativi all assunzione del farmaco selezionato*/
    func addInformazione(farmaco:Farmaco,durata: Int16,frequenza: String , dataInizio: Date) -> Informazione{
        //print("Sono la prima istruzione")
        let informazione = Informazione(context: context)
        //print("Sono la seconda istruzione")
        informazione.dataInizio = dataInizio
        informazione.durata = durata
        informazione.frequenza = frequenza
        informazione.id = UUID()
        informazione.caratterizzazione = farmaco
        farmaco.caratterizzazione = informazione
        salva()
        print("Informazione aggiunta e salvata")
        return informazione
    }
    
    /**Funzione che permette di rimuovere una Cura dalla cartella clinica dell'utente*/
    func removePrescrizione(utente: Utente, remove: Cura){
        utente.removePrescrizione(cura: remove)
        context.delete(remove)
        salva()
        print("Cura rimossa dalla cartella utente")
    }
    
    /**Funzione che permette di rimuovere un farmaco che era stato assegnato ad una specifica cura*/
    func removeFarmaco(cura: Cura , farmaco: Farmaco){
        cura.removeFarmaco(farmaco: farmaco)
        //context.delete(farmaco)
        salva()
        print("Farmaco rimosso dalla cura specificata")
    }
    

    /**Funzione che permette di rimuovere l'informazione associata ad un farmaco*/
    func removeInformazione(farmaco: Farmaco , informazione: Informazione){
        farmaco.composizione = nil
        context.delete(informazione)
        salva()
        print("Informazioni sul farmaco rimossa")
    }
    
    /**Data una assunzione permette di aggiornarne sintomi ed effetto*/
    func updateAssunzione(assunzione: Assunzione,effetto: Int16, sintomi: String){
        assunzione.effetto = effetto
        assunzione.sintomi = sintomi
        assunzione.sintomiPresenti = true
        salva()
        print("Aggionramento assunzione con id: \(String(describing: assunzione.id))")
    }
    
    func updateCura(cura:Cura,nome: String,descrizione: String ,medico: String, dataInizio: Date){
        cura.nome = nome
        cura.descrizione = descrizione
        cura.medico = medico
        cura.dataInizio = dataInizio
        salva()
        print("Cura aggiornata")
    }
    
    /*MARK: Funazioni di utilità*/
    
    /**Dato un utente restituisce tutte le cure ad esso associato*/
    func allCureOf(utente: Utente) -> [Cura]?{
        return utente.prescrizione?.allObjects as? [Cura]
    }
    

    
    /**Restituisce  tutte le assunzioni relative al framaco specificato*/
    func allAssunzioneOf(farmaco:Farmaco)->[Assunzione]?{
        return farmaco.caratterizzazione?.assunzioniProgrammate?.allObjects as? [Assunzione]
    }
    /**Data una cura restituisce un Array di Farmaci, che sono quelli ad essa associati**/
    func allFarmaciOf(cura: Cura)->[Farmaco]?{
        return cura.composizione?.allObjects as? [Farmaco]
    }
    
    /**Dato un utente ed il nome di un medico permette di ottenere tutte le cure se esistono da lui prescritte**/
    func searchCuraByMedico(utente:Utente , medico: String) -> [Cura]?{
        let temp : NSFetchRequest<Cura> = Cura.fetchRequest()
        temp.predicate = NSPredicate(format: "medico LIKE %@ AND prescrizione == %@",medico,utente)
        return try? context.fetch(temp)
    }
    
    /**Dato il nome di un dispenser  lo ricerca e la restituisce */
    func searchDispenser(nome: String)->Dispenser?{
        let tmp : NSFetchRequest<Dispenser> = Dispenser.fetchRequest()
        tmp.predicate = NSPredicate(format: "nome == %@",nome)
        return try? context.fetch(tmp).first
    }
    
    /**Dato il nome di un farmaco  lo ricerca e la restituisce */
    func searchFarmaco(nome: String)->Farmaco?{
        let tmp : NSFetchRequest<Farmaco> = Farmaco.fetchRequest()
        tmp.predicate = NSPredicate(format: "nome == %@",nome)
        return try? context.fetch(tmp).first
    } // devi aggiustarla con la cura
    
    /**Dato il nome di una cura la ricerca e la restituisce */
    func searchCura(nome: String)->Cura?{
        let tmp : NSFetchRequest<Cura> = Cura.fetchRequest()
        tmp.predicate = NSPredicate(format: "nome == %@",nome)
        return try? context.fetch(tmp).first
    }
    
    /**Restituisce un array con tutte le cure in terminate */
    func allCureTerminate()->[Cura]{
        let tmp : NSFetchRequest<Cura> = Cura.fetchRequest()
        tmp.predicate = NSPredicate(format: "dataFine != nil")
        let result = try? context.fetch(tmp)
        if (result == nil){
            return []
        }else{
            return result!
        }
    }
    
    /**Restituisce un array con tutte le cure in corso */
    func allCureOf()->[Cura]{
        let req: NSFetchRequest<Cura> = Cura.fetchRequest()
        req.predicate = NSPredicate(format: "dataFine == nil")
        let res = try? context.fetch(req)
        if (res == nil){
                return []
            } else {
                return res!
                
            }
    }
    
    /**Restituisce un array con tutte le cure indipendentemente dal fatto che queste siano o meno terminate*/
    func allCureOfAllTime()->[Cura]{
        let req: NSFetchRequest<Cura> = Cura.fetchRequest()
        let res = try? context.fetch(req)
        if (res == nil){
                return []
            } else {
                return res!
            }
    }
 
    
    /**Restituisce tutte le assunzioni per cui la variabile "AssociabileAlDispenser" assume valore true, permette di mostrare lo storico*/
    func assunzioniAssociateAlDispenser() -> [Assunzione]{
        let req = Assunzione.fetchRequest()
        req.predicate = NSPredicate(format: "associabileAlDispenser == true")
        let result = try? context.fetch(req)
        
        if (result == nil) {
          return []
        }
        
        return result!
    }
    
    /** Dato un farmaco ne ritorna soltanto le assunzioni con sintomi*/
    func allAssunzioniWithSintomi(farmaco: Farmaco)->[Assunzione]{
        var daRitornare: [Assunzione] = []
        let tmp = allAssunzioneOf(farmaco: farmaco)
        if (tmp == nil){return []}
        for elem in tmp! {
            if elem.sintomiPresenti{
                daRitornare.append(elem)
            }
        }
        return daRitornare
    }
    
    /*MARK: Funzioni per la gestione di funzionalità*/
    
    /**La funzione a partire dalle informazioni di un farmaco si propone di programmare tutte le assunzioni da associare a quel farmaco**/
    func generateAssunzioniFromInformazioni(informazioni: Informazione, orariProgrammati: [Date], giorni:[Bool]?){
        let startDate = informazioni.dataInizio
        
        //Date formatter necessari per la costruzione della data
        let dateFormatterSoloGiorno = DateFormatter()
        dateFormatterSoloGiorno.dateFormat="dd/MM/yyyy"
        let dateFormatterSoloOre = DateFormatter()
        dateFormatterSoloOre.dateFormat="HH:mm"
        let dateFormatterTotale = DateFormatter()
        dateFormatterTotale.dateFormat="dd/MM/yyyy HH:mm"
        
        // Gestione delle erogazioni personalizzate
        var index: [Int] = []
        if(informazioni.frequenza == "Personalizzato"){
            if(giorni == nil){
                //controllo di robustezza la situazione dovrebbe essere impossibile
                print("ERRORE Giorni is NIL")
                return
            }
            index = fromBooleanToArray(base: giorni!)
        }
        
        
        for i in 0...informazioni.durata*7{
            switch informazioni.frequenza{
                
            case "Ogni giorno":
                let tmp = startDate.addingTimeInterval(Double(i)*24*60*60)
                for elem in orariProgrammati{
                    let assunzione = Assunzione(context: context)
                    let string = "\(dateFormatterSoloGiorno.string(from: tmp))  \(dateFormatterSoloOre.string(from: elem))"
                    //print("Sono la print di debug in generateAssunzioniFromInformazioni, prova ad inserire una assunzione programmata per il farmaco il gionro \(string)")
                    assunzione.orarioProgrammato = dateFormatterTotale.date(from: string)!
                    assunzione.assunzioniProgrammate = informazioni
                    assunzione.id = UUID()
                    assunzione.erogato = false
                    assunzione.associabileAlDispenser = false
                    assunzione.assunzionePassata = false
                    informazioni.addAssunzione(assunzione: assunzione)
                    salva()
                }
            case "Giorni alterni":
                if( (i % 2) == 0){
                    let tmp = startDate.addingTimeInterval(Double(i)*24*60*60)
                    for elem in orariProgrammati{
                        let assunzione = Assunzione(context: context)
                        let string = "\(dateFormatterSoloGiorno.string(from: tmp))  \(dateFormatterSoloOre.string(from: elem))"
                        //print("Sono la print di debug in generateAssunzioniFromInformazioni, prova ad inserire una assunzione programmata per il farmaco il gionro \(string)")
                        assunzione.orarioProgrammato = dateFormatterTotale.date(from: string)!
                        assunzione.assunzioniProgrammate = informazioni
                        assunzione.id = UUID()
                        assunzione.erogato = false
                        assunzione.associabileAlDispenser = false
                        assunzione.assunzionePassata = false
                        informazioni.addAssunzione(assunzione: assunzione)
                        salva()
                    }
                }
            case "Personalizzato":
                let tmp = startDate.addingTimeInterval(Double(i)*24*60*60)
                //print("Debug calendar: \(Calendar.current.component(.weekday, from: tmp))")
                if ( index.contains(Calendar.current.component(.weekday, from: tmp)) ){
                    for elem in orariProgrammati{
                        let assunzione = Assunzione(context: context)
                        let string = "\(dateFormatterSoloGiorno.string(from: tmp))  \(dateFormatterSoloOre.string(from: elem))"
                        //print("Sono la print di debug in generateAssunzioniFromInformazioni, prova ad inserire una assunzione programmata per il farmaco il gionro \(string)")
                        assunzione.orarioProgrammato = dateFormatterTotale.date(from: string)!
                        assunzione.assunzioniProgrammate = informazioni
                        assunzione.id = UUID()
                        assunzione.sintomiPresenti = false
                        assunzione.erogato = false
                        assunzione.associabileAlDispenser = false
                        assunzione.assunzionePassata = false
                        informazioni.addAssunzione(assunzione: assunzione)
                        salva()
                    }
                }
                

            
            default:
                return
            }
                        
            }
        }
    
    /**A partire da un array booleano di 7 elementi (i giorni della settimana) ritorna un array di interi contenente solo i giorni della settimana selezionati*/
    private func fromBooleanToArray(base: [Bool]) -> [Int]{
        var returnValue : [Int] = []
        for elem in 0..<base.capacity {
            if (base[elem]){
                returnValue.append(elem+1)
            }
        }
        return returnValue
    }
        
     
    public func allDispenser() -> [Dispenser]? {
        
        let req = Dispenser.fetchRequest()
        
        do {
            return try context.fetch(req)
        } catch {
            print("Nessun dispenser")
        }
        
        return nil
        
    }
    
    /**
            Associa  il farmaco dal dispenser
     */
    public func linkDispenserToFarmaco(dispenser: Dispenser, farmaco: Farmaco) {
        
        dispenser.contenuti = farmaco
        farmaco.associato = dispenser
        salva()
        
    }
    
    /**
            Dissocia il farmaco dal dispenser
     */
    public func removeLinkDispenserToFarmaco(dispenser: Dispenser, farmaco: Farmaco) {
        
        dispenser.contenuti = nil
        farmaco.associato = nil
        salva()
        
    }
    
    /**
        Funzione che prende in ingresso il nome del farmaco, la data e ora dell'assunzione, l'esito di questa, e aggiorna i rispettivi valori all'interno del modello.
     */
    public func confermaAssunzione(nome: String , dataOra: Date , esito: Bool){
        let list = allAssunzioneOf(farmaco: searchFarmaco(nome: nome)!)
        if (list == nil) {return}
        for temp in list!{
            let formatter = DateFormatter()
            formatter.dateFormat = "dd/MM/yyyy HH:mm"
            
            let temp1 = formatter.string(from: temp.orarioProgrammato!)
            let temp2 = formatter.string(from: dataOra)
            
            if (temp1 == temp2){
                temp.assunzionePassata = true
                temp.erogato = esito
                salva()
            }
        }
    }
    

    
/**Permette di marcare le cure che sono terminate andando a valorizzare la data di fine**/
    func fromCuraToTerminata(){
       let cure = allCureOf()
        if (!cure.isEmpty){
            for elem in cure {
                if(elem.dataFine == nil){
                    let farmaci = allFarmaciOf(cura: elem)
                    if (farmaci == nil || farmaci!.isEmpty){
                        return
                    }
                    for tmp in farmaci!{
                        let assunzioni = allAssunzioneOf(farmaco: tmp)
                        if (assunzioni != nil){
                            for tmp1 in assunzioni! {
                                if(tmp1.orarioProgrammato! > Date.now){
                                    return
                                }
                            }
                            
                        }
                    }
                } else {
                    return
                }
                elem.dataFine = Date.now
                salva()
            }
        }else {
            print("cure è vuoto")
        }
    }
    


}
