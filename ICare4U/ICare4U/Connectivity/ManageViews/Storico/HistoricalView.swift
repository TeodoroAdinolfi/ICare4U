//
//  HistoricalView.swift
//  ICare4U
//
//  Created by Antonio Bove on 22/06/22.
//

import SwiftUI

struct HistoricalView: View {

    @Environment(\.managedObjectContext) private var viewContext
    
    @EnvironmentObject var mqttClient: MQTT
    
    @StateObject var infoHistoricalPills = InfoHistoricalPillsClass()
    
    var body: some View {
        ScrollView(.vertical, showsIndicators:  false) {
            ZStack {
                RoundedRectangle(cornerRadius: 25, style: .continuous)
                    .fill(Color("cardBackground"))
                    .shadow(radius: 10)
                    .frame(width: 360)
                
                VStack(spacing: 10) {
                    Image(systemName: "archivebox")
                        .resizable()
                        .frame(width: 70, height: 70)
                        .foregroundColor(Color.blue)
                        
                    Text("Storico erogazioni")
                        .font(.system(size: 28, weight: .bold, design: .default))
                    
                    Text("L'app ICare4U ti consente di tener traccia di tutte le erogazioni che sono avvenute con successo, ma anche di quelle saltate.")
                        .multilineTextAlignment(.center)
                        .font(.system(size: 15, weight: .regular, design: .default))
                        .foregroundColor(.gray)
                        .frame(width: 330)
                }  
            }
            .frame(width: 390, height: 250)
            .padding(.top, 20)
            
            VStack(spacing: 10) {
                
                if(infoHistoricalPills.done && !infoHistoricalPills.historicalPills.isEmpty) {
                    
                    ForEach(0..<infoHistoricalPills.historicalPills.count, id: \.self) { index in
                        
                        let cura = infoHistoricalPills.historicalPills[index].cura
                        
                        let farmaco = infoHistoricalPills.historicalPills[index].farmaco
                        
                        let dataEOra = infoHistoricalPills.historicalPills[index].orario
                        
                        let stato = infoHistoricalPills.historicalPills[index].stato
                        
                        ItemHistoricalCell(cura: cura, farmaco: farmaco, dataEOra: dataEOra, stato: stato)
                            .contextMenu {
                            Button(role: .destructive) {
                                infoHistoricalPills.removeHistoricalPill(index: index, orario: dataEOra.replacingOccurrences(of: " ", with: ";"))
                            } label: {
                                Label("Elimina", systemImage: "trash")
                                    .foregroundColor(Color.red)
                            }
                        }
                    }
                } else {
                    Image("noData")
                        .resizable()
                        .frame(width: 300, height: 300, alignment: .center)
                }
            }
            .padding(.top, 20)
        }
        .onAppear {
            mqttClient.publish(topic: "/historical", message: "ack", qos: .qos0)
        }
        .onChange(of: mqttClient.isTerminated) { newValue in
            if(mqttClient.isTerminated) {
                infoHistoricalPills.done = false
                infoHistoricalPills.setContext(context: viewContext)
                infoHistoricalPills.getHistoricalPills()
                mqttClient.isTerminated = false
            }
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    infoHistoricalPills.removeAllHistoricalPill()
                }, label: {
                        Text("Svuota")
                        .foregroundColor(infoHistoricalPills.historicalPills.isEmpty ? Color.gray : Color.blue)
                })
                .disabled(infoHistoricalPills.historicalPills.isEmpty)
            }
        }
        .background(Image("medicalb").resizable().scaledToFill().ignoresSafeArea().opacity(0.2))
    }
}

struct ItemHistoricalCell: View {
    
    var cura: String
    var farmaco: String
    var dataEOra: String
    var stato: Bool  
    var icon = "circle.fill"
    
    var body: some View {
        ZStack {   
            RoundedRectangle(cornerRadius: 30)
                .fill(LinearGradient(gradient: Gradient(colors: [Color("cardColor1.2"), Color("cardColor2.2")]), startPoint: .top, endPoint: .bottomTrailing))
                .frame(width: 320, height: 110)
            
            ZStack {
                RoundedRectangle(cornerRadius: 30)
                    .fill(stato ? .green : .red)
                    .frame(width: 100, height: 30)
                
                Text(stato ? "Assunto" : "Non assunto")
                    .foregroundColor(.white)
                    .font(.system(size: 12))
            }
            .padding(.bottom, 110)
            
            VStack(alignment: .leading) {
                
                HStack(spacing: -1) {
                    Text("Cura: ")
                        .fontWeight(.bold)
                    Text(cura)
                }
                
                HStack(spacing: -1) {
                    Text("Farmaco: ")
                        .fontWeight(.bold)
                    Text(farmaco)
                }
                
                HStack(spacing: -1) {
                    Text("Orario: ")
                        .fontWeight(.bold)
                    Text(dataEOra)
                }
            }
            .padding(.top, 10)
            
        }
        .frame(height: 130)
    }
}

struct HistoricalView_Previews: PreviewProvider {
    static var previews: some View {
        HistoricalView()
    }
}
