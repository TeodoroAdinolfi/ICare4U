//
//  CareController.swift
//  ICare4U
//
//  Created by Emilio Amato on 03/06/22.
//

import Foundation
import CareKit
import SwiftUI
import CareKitUI
import CareKitStore

let store = OCKStore(name: "mystore", type: .onDisk())  /* Definizione dello store (CoreData) associato al controller di visualizzazione  dei task per la gestione giornaliera*/
let storemanager = OCKSynchronizedStoreManager(wrapping: store) /* Store manager per gestire le operazioni sullo store*/


/* Rappresentazione in SwiftUI del controller nativo in UIKit tramite protocollo UIViewControllerRepresentable per la gestione e sincronizzazione giornaliera dei task tramite bridge*/

struct CareController: UIViewControllerRepresentable {
    
    func makeUIViewController(context: Context) -> OCKDailyTasksPageViewController {
        
    let contr = OCKDailyTasksPageViewController(storeManager: storemanager)
    return contr
        
    }
    
    
    func updateUIViewController(_ uiViewController: OCKDailyTasksPageViewController, context: Context) {
    
    }
    

}



/* Funzione di utilità per l'aggiunta di un task allo store con una specifica schedulazione, direttamente sincronizzato con il controller di visualizzazione dei task al fine
 di poter garantire la visualizzazione e gestione del task aggiunto. Richiamata durante la fase di configurazione della cura e aggiunta dei farmaci, assunzione per assunzione */

func seedTaskfromAdd(ora: Int, minute: Int, data: Date,fine: Int, desc: String, id: String, titolo: String ) {
    let onBoardSchedule = OCKSchedule.dailyAtTime(hour: ora, minutes: minute, start: data, end: Calendar.current.date(byAdding: .minute , value: fine, to: data), text: desc, duration: .minutes(30))
    
    let onBoardTask = OCKTask(id: id, title: titolo, carePlanUUID: nil, schedule: onBoardSchedule)
   
    storemanager.store.addAnyTasks([onBoardTask], callbackQueue: .global()) { result in }
    
}


/* Funzione di utilità per l'eliminazione di un task dallo store con una specifica schedulazione, direttamente sincronizzato con il controller di visualizzazione dei task al fine
 di poter garantire l'eliminazione dalla visualizzazione  del task scelto. Richiamata durante la fase di eliminazione della cura o del farmaco specifico, assunzione per assunzione*/

func deleteTask(id: String){
 
    storemanager.store.fetchAnyTask(withID: id, callbackQueue: .global()){result in
        
        switch result {

                    case .failure:
                        print("errore")

                    case .success:
                    let task = try? result.get()
                    if(task != nil){
                        store.deleteAnyTask(task!, callbackQueue: .global()){
                            result in
                        }
                }

        }
    }
}


                                



