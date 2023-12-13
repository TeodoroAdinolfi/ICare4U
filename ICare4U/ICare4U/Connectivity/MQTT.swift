//
//  MQTT.swift
//  ICare4U
//
//  Created by Antonio Bove on 01/06/22.
//

import Foundation
import CocoaMQTT
import SwiftUI

class MQTT: ObservableObject {
    
    @Published var isConnected = false
    @Published var isTerminated = false
    @Published var isWaterEmpty = true
    
    let controller: CoreDataController
    
    let mqtt: CocoaMQTT
    
    init(clientID: String, keepAlive: UInt16 = 1800, host: String) {
        mqtt = CocoaMQTT(clientID: clientID, host: host, port: 1883)
        mqtt.keepAlive = keepAlive
        mqtt.autoReconnect = true
        mqtt.willMessage = CocoaMQTTMessage(topic: "/will", string: "dieout")
        mqtt.willMessage?.qos = .qos0
        
        let context = PersistenceController.shared.container.viewContext
        self.controller = CoreDataController(context: context)
    }
    
    /*
        La funzione wrappa l'omonima funzione di CocoaMQTT. L'attributo @discardableResult sta ad indicare che si 
        vuole ignorare il valore di ritorno della stessa.
    */
    @discardableResult func connect() -> Bool {
        return mqtt.connect()
    }
    
    
    /*
        La funzione permette di sottoscriversi a un insieme di topic passati come parametro attraverso un'array di tuple 
        del tipo (String, CocoaMQTTQoS) e definisce, attraverso la funzione di callback 'didReceiveMessage' comportamenti 
        specifici a seconda del topic e del messaggio ad esso associato.
    */
    func subscribe(topic: [(String, CocoaMQTTQoS)]) {
        mqtt.subscribe(topic)
        mqtt.didReceiveMessage = { mqtt, message, id in
            print("Message recieved in topic \(message.topic) with payload \(message.string!)")
            if(message.topic == "/checkInit" && message.string! == "active"){
                self.isConnected = true
                print("checked")
            } else if(message.string! != "" && (message.topic == "/checkHistorical")){
                if(message.string! == "fine") {
                    self.isTerminated = true
                } else {
                    let dati = self.fromStringToInfo(string: message.string!)
                    self.controller.confermaAssunzione(nome: dati.0, dataOra:dati.1, esito: dati.2)
                }
            } else if(message.string! != "" && (message.topic == "/checkWater")) {
                if(message.string! == "false") {
                    self.isWaterEmpty = false
                } else {
                    self.isWaterEmpty = true
                }
            }
        }
    }


    /*
        La funzione wrappa l'omonima funzione di CocoaMQTT e definisce la funzione di callback 'didPublishMessage'.
    */
    func publish(topic: String, message: String, qos: CocoaMQTTQoS, retained: Bool = false) {
        mqtt.publish(topic, withString: message, qos: qos, retained: retained)
        mqtt.didPublishMessage = { mqtt, message, id in
            print("Message published in topic \(message.topic) with payload \(message.string!)")
        }
    }

    /*
        La funzione wrappa l'omonima funzione di CocoaMQTT e annulla l'iscrizione ai topics.
    */
    func disconnect() {
        mqtt.disconnect()
        mqtt.unsubscribe(["/checkInit", "/checkWater", "/checkHistorical"])
        self.isConnected = false
    }
    
    /*
        Funzione di utilità che riceve in ingresso una stringa nel formato nomeFarmaco;dataAssunzione;oraAssunzione;erogato
        e restituisce una tupla del tipo (String, Date, Bool).
    */
    private func fromStringToInfo(string: String) -> (String, Date, Bool){
        let temp = string.components(separatedBy: ";")
        let nome = temp[0]
        let dateFormat = DateFormatter()
        dateFormat.dateFormat = "dd/MM/yyyy;HH:mm"
        let dataOra = temp[1] + ";" + temp[2]
        let date = dateFormat.date(from: dataOra)
        let erogato = temp[3] == "true" ? true : false
        return (nome, date!, erogato)
    }
    
}




