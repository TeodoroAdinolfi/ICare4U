//
//  addFarmacoView.swift
//  ICare4U
//
//  Created by Teodoro Adinolfi on 21/06/22.
//

import SwiftUI
import CoreData
import UserNotifications


struct addFarmacoView: View {
    
    @Environment(\.dismiss) var dismiss
    
    let context : NSManagedObjectContext
    let cura : Cura
    
    /**Permette di settare le opzioni da visualizare all'interno del menu frequenza**/
    private let options = ["Ogni giorno","Giorni alterni","Personalizzato"]
    
    @State var text1 = ""
    @State var text2 = "Ogni giorno"
    
    @State var stepper1 = 0
    @State var stepper2 = 0
    @State var stepper3 = 1
   
    
    @State var date = Date.now
    @State var trig = false
    @State var trigAlert = false
    @State var trigAlert1 = false
    @State var orari: [Date] = []
    
    @State var lunedi = false
    @State var martedi = false
    @State var mercoledi = false
    @State var giovedi = false
    @State var venerdi = false
    @State var sabato = false
    @State var domenica = false
    
    @ObservedObject var farmacoContainer : FarmacoContainer
    
    @FocusState private var focus : Bool
    
    
    
    var body: some View {
        NavigationView{
            splashImageBackground.overlay(
            Form{
                //Nome
                Section("Informazioni sul farmaco"){
                    TextField("Nome del farmaco", text: $text1)
                        .focused($focus)
                }
                
                Section("Somministrazione"){
                    //Data inizio assunzione
                    DatePicker("Inizio:",selection:$date,in: Date.now...,displayedComponents: [.date])
                    //Durata
                    HStack{
                        Stepper("Settimane: \(stepper3)",value:$stepper3, in: 1...100)
                    }
                    //Frequenza
                    HStack{
                        Text("Frequenza:")
                        Spacer()
                        Picker("", selection: $text2){
                                ForEach(options, id: \.self) {
                                        Text($0)
                                 }
                        }.pickerStyle(.menu)
                    }
                }
                
                if (text2 == "Personalizzato"){
                    Section("In quali giorni assumerlo:"){
                        VStack{
                            Toggle(isOn:$lunedi){
                                Text("Lunedì")
                            }
                            Toggle(isOn:$martedi){
                                Text("Martedì")
                            }
                            Toggle(isOn:$mercoledi){
                                Text("Mercoledì")
                            }
                            Toggle(isOn:$giovedi){
                                Text("Giovedì")
                            }
                            Toggle(isOn:$venerdi){
                                Text("Venerdì")
                            }
                            Toggle(isOn:$sabato){
                                Text("Sabato")
                            }
                            Toggle(isOn:$domenica){
                                Text("Domenica")
                            }
                        }
                    }
                }

         
                timeAdder(title: "Orari di assunzione", addText: "Aggiungi nuova assunzione", list: $orari)

                
                Section{
                    Button("Inserisci"){
                        let controller = CoreDataController(context: context)
                        let tmp = controller.searchFarmaco(nome: text1)
                        if (tmp?.composizione != cura){
                            if(text1 != ""  && !orari.isEmpty && (text2 == "Ogni giorno" || text2=="Giorni alterni" || (text2 == "Personalizzato" && (lunedi == true || martedi == true || mercoledi == true || giovedi == true || sabato == true || domenica == true))) ){
                                
                                let farmaco = controller.addFarmaco(cura: cura, nome: text1, aic: "aaaa", nCompresse: Int16(stepper1), quantita: Int16(stepper2), scadenza: Date.now)
                                let informazione = controller.addInformazione(farmaco:farmaco, durata: Int16(stepper3), frequenza:text2, dataInizio: date)
                                controller.generateAssunzioniFromInformazioni(informazioni: informazione, orariProgrammati: orari,  giorni: [domenica,lunedi,martedi,mercoledi,giovedi,venerdi,sabato])
                                
                                let assunzioni: [Assunzione] = controller.allAssunzioneOf(farmaco: farmaco)!
                            
                                let ora = DateFormatter()
                                ora.dateFormat = "HH"
                                
                                let minuti = DateFormatter()
                                minuti.dateFormat = "mm"
                                
                                let data = DateFormatter()
                                data.dateFormat = "dd/MM/yyyy"
                            
                                
                                for a in assunzioni {
                                    let o = ora.string(from: a.orarioProgrammato!)
                                    let m = minuti.string(from: a.orarioProgrammato!)
                                    
                                    let content = UNMutableNotificationContent()
                                    content.title = "ICare4U"
                                    content.subtitle = a.assunzioniProgrammate!.caratterizzazione!.composizione!.nome
                                    content.body = "C'è l'assunzione del farmaco "+a.assunzioniProgrammate!.caratterizzazione!.nome+" che ti aspetta!"
                                    content.sound = UNNotificationSound.defaultRingtone
                                    content.badge = 1

                                    // Programmata per un minuto prima
                                    let triggerDate = a.orarioProgrammato!.addingTimeInterval(Double(-1 * 60))
                                    let trigger = UNCalendarNotificationTrigger(
                                        dateMatching: Calendar.current.dateComponents([.timeZone, .year, .month, .day, .hour, .minute], from: triggerDate),
                                        repeats: false
                                    )

                                    let request = UNNotificationRequest(identifier: a.id!.description, content: content, trigger: trigger)


                                    UNUserNotificationCenter.current().add(request)
                                    
                                    
                                    print(a.id!.description)
                                    seedTaskfromAdd(ora: Int(o)!, minute: Int(m)!, data: a.orarioProgrammato!, fine: 1, desc: "Assunzione \(o):\(m)", id: a.id!.description, titolo: farmaco.nome)
                                }
                                
                                
                                
                                
                                farmacoContainer.aggiornaFarmaci()
                                dismiss()
                            } else {
                                trigAlert.toggle()
                            }
                        } else {
                            trigAlert1.toggle()
                        }
                    }.foregroundColor(.blue)
                        .alert(isPresented: $trigAlert){
                            Alert(title: Text("Attenzione"), message: Text("Il form deve essere interamente compilato"), dismissButton: .cancel())
                        }
                        .alert(isPresented: $trigAlert1){
                            Alert(title: Text("Attenzione"), message: Text("Hai già inserito questo farmaco"), dismissButton: .cancel())
                        }
                        
                }
            }
            )
            .navigationTitle("Aggiungi un farmaco")
            .toolbar{
                ToolbarItem(placement: .navigationBarLeading){
                    Button("Indietro"){
                        farmacoContainer.aggiornaFarmaci()
                        dismiss()
                    }.foregroundColor(.red)
                }
                
                ToolbarItem(placement: .keyboard){
                    Button("Chiudi"){
                        focus = false
                    }
                }
            }
            
            //fine form
           
        }
    }
    
    var splashImageBackground: some View {
           GeometryReader { geometry in
               Image("medicalv")
                   .resizable()
                   .aspectRatio(contentMode: .fill)
                   .edgesIgnoringSafeArea(.all)
                   .frame(width: geometry.size.width)
                   .opacity(0.15)
           }
       }
    
  /// La serie di strutture che seguono sono state utilizzate per la realizzazione di un piker di  oggetti Date personalizzato, in grado di generare dinamicamente un numero n di date, tutte in binding, rendendo di fartto possibile utilizzare le informazioni in tutta l'applicazione.
    struct timeAdder: View {
        
        var title: String
        var addText: String
        @Binding var list: [Date]
        
        func getBinding(forIndex index: Int) -> Binding<Date> {
            return Binding<Date>(get: { list[index] },
                                   set: { list[index] = $0 })
        }
        
        
        var body: some View {
            Section(title) {
                ForEach(0..<list.count, id: \.self) { index in
                    ListItem(placeholder: "\(index+1)° Assunzione", date: getBinding(forIndex: index)) { self.list.remove(at: index) }
                }
                AddButton(text: addText) { self.list.append(Date.now) }
            }
        }
    }

     struct ListItem: View {
        
        var placeholder: String
        @Binding var date: Date
        var removeAction: () -> Void
        
        var body: some View {
            HStack {
                Button(action: removeAction) {
                    Image(systemName: "minus.circle.fill")
                        .foregroundColor(.red)
                        .padding(.horizontal)
                }
                
                DatePicker(placeholder, selection: $date, displayedComponents: .hourAndMinute)
            }
        }
        
    }

      struct AddButton: View {
        
        var text: String
        var addAction: () -> Void
        
        var body: some View {
            Button(action: addAction) {
                HStack {
                    Image(systemName: "plus.circle.fill")
                        .foregroundColor(.green)
                        .padding(.horizontal)
                    Text(text)
                }
            }
        }
    }
    
}





    

