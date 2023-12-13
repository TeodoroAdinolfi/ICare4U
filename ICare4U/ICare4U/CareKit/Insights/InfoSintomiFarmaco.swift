//
//  InfoSintomiFarmaco.swift
//  ICare4U
//
//  Created by Emilio Amato on 23/06/22.
//

import SwiftUI
import CoreData
import CareKit
import CareKitUI
import CareKitStore

struct InfoSintomiFarmaco: View {
    
    let context: NSManagedObjectContext
    let farmaco: Farmaco
    
    
    
    init(farmaco: Farmaco, context: NSManagedObjectContext){
        self.farmaco = farmaco
        self.context = context
    }
    
    
    
    var body: some View {
        
        /* Se ci sono assunzioni registrare con sintomi, mostra i charts ad essa associati con la relativa lista delle registrazioni, altrimenti una vista contenente come indicazioni
         l'assenza di sintomi registrati */
        
            if(!ottieniAssunzioni().isEmpty){
                
                VStack{
                    
                        /* Scroll view orizzontale all'interno della quale vengono generati i charts riportanti i trend relativi all'impatto del farmaco sulla cura da parte delll'utente*/
                        ScrollView(.horizontal){
                            
                            let a = ottieniEffetti().keys.count /* conteggio del numero di assunzioni registrare con sintomi */
                            let num = Int(a/7) /* Divisione per 7 al fine di poter ottenere il numero di charts da generare, essendo ognuno di essi gestito per raggruppare 7 assunzioni*/
                            HStack(alignment: .center, spacing: 30){
                                
                                /*Generazione dei charts, richiamando la view ChartViewLines la quale riceve come parametri la settimana associata (in termini di 7 assunzioni conseguite)
                                 ottenuta attraverso la funzione di utilità ottieniSettimana, e il numero della settimana */
                                ForEach(0...num, id: \.self){ index in
                                    ChartViewLines(effect: ottieniSettimana(effetti: ottieniEffetti(), settimana: index), settimana: index).frame(width: 360, height: 270)
                                }
                                
                            }.padding(17)
                        }.frame(height: 300)
                    
                    
                        /*Lista contente tutte le assunzioni registrate con sintomi ordinate per data, attraverso la funzione di utilità ottieni assunzioni*/
                        List(ottieniAssunzioni()){ assunzione in
                            HStack(spacing: 10){
                                
                                Image("symptom")
                                     .resizable()
                                     .scaledToFit()
                                     .frame(width: 35, height: 35)
            
                                VStack(alignment: .leading, spacing: 5){
                                    
                                    Text(assunzione.desc).font(.caption2)
                                    Text(assunzione.sintomo).font(.caption)
                                    
                                }
                                
                            }.padding(7)
                            
                        }.shadow(color: .black, radius: 1, x: 1, y: 1)
                    
                }.background(Image("medical").resizable().scaledToFill().ignoresSafeArea().opacity(0.15)).onAppear(){
                    
                    /* Eliminazione dello sfondo al fine dell'applicazione della background image */
                   UITableView.appearance().backgroundColor = .clear
                    
                 }
              
                
            }else{
                
                /* Background image applicato alla vista di indicazione di assenza di sintomi registrati*/
                splashImageBackground.overlay(
                    VStack(spacing: 20){
                        Image("nosymp").resizable().scaledToFit().frame(width: 180, height: 180)
                        Text("Nessun sintomo ancora registrato").bold()
                    }
                )
            }
        }
    
    
    /* Background da applicare alla view */
    var splashImageBackground: some View {
           GeometryReader { geometry in
               Image("medical")
                   .resizable()
                   .aspectRatio(contentMode: .fill)
                   .edgesIgnoringSafeArea(.all)
                   .frame(width: geometry.size.width)
                   .opacity(0.15)
           }
       }
    
    
    /* Funzione di utilità per la generazione dell'assunzioni con un array di tipo "sint", al fine di adattarsi al
     protocollo identifiable per la struttura del foreach, ordinate per date*/
    
    func ottieniAssunzioni() -> [sint] {
        
        var sin: [sint] = []
        
        /* Recupero delle sole assunzioni i cui sintomi sono registrati */
        let assunzioni = CoreDataController(context: context).allAssunzioniWithSintomi(farmaco: farmaco)
        
        
        let data = DateFormatter()
        data.dateFormat = "MM/dd HH:mm"
        
        for a in assunzioni {

            sin.append(sint(desc: data.string(from: a.orarioProgrammato!), sintomo: a.sintomi!))
        }
        
        let sinordered = sin.sorted{
            $0.desc < $1.desc
        }
        
        return sinordered /* assunzioni con sintomi registrati, ordinati per data */
        
    }
    
    
    /* Funzione di utilità per la generazione degli effetti in un dizionario di tipo string:int con chiave
     la data e valore l'intero associato all'effetto del farmaco registrato */
    
    func ottieniEffetti() -> [String:Int] {
        
        var effetti: [String:Int] = [:]
       
        let assunzioni = CoreDataController(context: context).allAssunzioniWithSintomi(farmaco: farmaco)
        
        let formatter = DateFormatter()
        formatter.dateFormat = "MM-dd-yyyy HH:mm"

        for a in assunzioni {

            effetti.updateValue(Int(a.effetto), forKey: formatter.string(from: a.orarioProgrammato!))
        }
    
        return effetti
    
        
    }
    
    
    /* View associata ai chart, definita a partire da UIKit in SwiftUI attraverso il protocollo UIViewRepresentable (bridge della view messa a disposizione del
     framework CareKit, nella fattispecie nel pacchetto CareKitUI), la quale viene ad essere inizializzata prendendo come parametri una stringa, che andrà a definire
     il titolo del chart, un dizionario di effetti che conterrà data:valore per gestire gli assi del chart e la settimana come intero,per associare alla specifica
     settimana il chart visualizzato */
    
    struct ChartViewLines: UIViewRepresentable{
        
        @State var str = ""
        var effect :[String:Int]
        var settimana :Int
     
        
        func makeUIView(context: Context) -> OCKCartesianChartView{
            let chart = OCKCartesianChartView(type: .line)
            return chart
            
        }
        
        func updateUIView(_ uiView: OCKCartesianChartView, context: Context) {
            
            let formatter = DateFormatter()
            formatter.dateFormat = "MM-dd-yyyy HH:mm"
            
            /* ordinamento per date degli effetti del farmaco registrati*/
            let myArrayOfTuples = effect.sorted {
                formatter.date(from: $0.0)! < formatter.date(from: $1.0)!
            }

            var eff :[CGFloat] = [] /* Valori da mostrare nel chart*/
            var dat :[String] = [] /* Asse orizzontale del chart*/
        
            
            for ef in myArrayOfTuples{
                eff.append(CGFloat(ef.value)) /* popolamento dei valori del chart con gli effetti del farmaco misurati*/
                dat.append(String(ef.key.prefix(5))) /* associazione della data all'effetto misurato, mostrata sull'asse orizzotale del chart*/
            }
            
            
            /* Configurazione del chart */
            uiView.headerView.titleLabel.text = "Tracciamento \(settimana+1)ª assunzione settimanale"
            var series = OCKDataSeries(values: eff, title: "Effetto cura")
            series.size = 4
            series.gradientStartColor = .purple
            series.gradientEndColor = .cyan
            uiView.graphView.dataSeries = [series]
            uiView.graphView.horizontalAxisMarkers = dat
            uiView.graphView.yMaximum = 10
            uiView.graphView.yMinimum = 0
            
           
            
        }
    }
    
    
    /* Funzione di utilità per la restituzione delle specifiche assunzioni associate all' i-esima settimana, al fine del popolamento dello specifico chart. Prende come parametri
     l'insieme degli effetti come dizionario di string:int (data:valore) e la settimana associata per la quale si vogliono conoscere gli effeti */
    
    func ottieniSettimana(effetti: [String:Int], settimana: Int) -> [String: Int]{
        
        var i = 0 /*utilizzata per il conteggio */
        var settimanale: [String:Int] = [:] /* dizionario che andrà a contenere le registrazioni dei sintomi della settimana specificata */
        
        let formatter = DateFormatter()
        formatter.dateFormat = "MM-dd-yyyy HH:mm"
        
       
        /* ordinamento per date degli effetti dei sintomi registrati*/
        let myArrayOfTuples = effetti.sorted {
            formatter.date(from: $0.0)! < formatter.date(from: $1.0)!
        }

        /* Scorrimento di tutti gli effetti, andando ad aggiungere al dizionario solo quelli con indice compreso fra (settimana indicata * 7) e ((settimana indicata * 7) + 7),
         ovvero solo nei 7 giorni di interesse. Ciò garantisce che venga scelta la settimana passata come parametro intero dal momento in cui  gli effetti vengono ad essere
         ordinati per date  */
        
        for value in myArrayOfTuples {
            
            if(i >= settimana*7 && i < (settimana*7+7)){
                settimanale.updateValue(value.value, forKey: value.key)
                i = i + 1
            }else{
                i = i + 1
            }
        }
        
        return settimanale  /* dizionario che contiene le registrazioni dei sintomi della settimana specificata */
    }
}




/* Struttura per gestire i sintomi con descrizione (data) e sintomo, adattata al protocollo identifiable */
struct sint: Identifiable{
    
    let id = UUID()
    let desc: String
    let sintomo: String

}


/* Struttura per gestire gli effetti con data, adattata al protocollo identifiable */

struct effect: Identifiable{
    
    let id = UUID()
    let effetto: Int
    let data: String
}



