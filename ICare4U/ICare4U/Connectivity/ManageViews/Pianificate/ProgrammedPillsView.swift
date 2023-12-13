//
//  ProgrammedPillsView.swift
//  ICare4U
//
//  Created by Antonio Bove on 22/06/22.
//

import SwiftUI

struct ProgrammedPillsView: View {
    
    @EnvironmentObject var mqttClient: MQTT
    
    @Environment(\.managedObjectContext) private var viewContext

    @ObservedObject var infoProgrammedPills: InfoProgrammedPillsClass
    
    var body: some View {
        
        ScrollView(.vertical, showsIndicators:  false) {
            
            ZStack{
                
                RoundedRectangle(cornerRadius: 25, style: .continuous)
                    .fill(Color("cardBackground"))
                    .shadow(radius: 10)
                    .frame(width: 330)
            
                VStack(spacing: 10){
                    Image(systemName: "calendar.badge.clock")
                        .resizable()
                        .frame(width: 75, height: 70)
                        .foregroundColor(Color.blue)
                        
                    Text("Erogazioni pianificate")
                        .font(.system(size: 28, weight: .bold, design: .default))
                    

                    Text("Visualizza l'elenco di tutte le assunzioni programmate.")
                        .multilineTextAlignment(.center)
                        .font(.system(size: 15, weight: .regular, design: .default))
                        .foregroundColor(.gray)
                        
                }
                .padding(.top, 20)
                
            }
            .frame(width: 370, height: 250)
            .padding(.top, 10)
            
            VStack(spacing: 20){
                
                if(infoProgrammedPills.done && !infoProgrammedPills.programmedPills.isEmpty) {
                
                    ForEach(0..<infoProgrammedPills.programmedPills.count, id: \.self) { index in
                        
                        let cura = infoProgrammedPills.programmedPills[index].cura
                        
                        let farmaco = infoProgrammedPills.programmedPills[index].farmaco
                        
                        let dataEOra = infoProgrammedPills.programmedPills[index].orario
                        
                        let dispenser = infoProgrammedPills.programmedPills[index].dispenser
                        
                        ItemCell(cura: cura, farmaco: farmaco, dataEOra: dataEOra, dispenser: dispenser)
                            .contextMenu {
                                Button(role: .destructive) {
                                    infoProgrammedPills.removeProgrammedPill(index: index, orario: dataEOra.replacingOccurrences(of: " ", with: ";"))
                                    mqttClient.publish(topic: "/removePill", message: "\(farmaco);\(dataEOra.replacingOccurrences(of: " ", with: ";"));\(dispenser == "1" ? "0" : "1")", qos: .qos0)
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
            .padding(.top, 10)
            
        }
        .onAppear {
            mqttClient.publish(topic: "/historical", message: "ack", qos: .qos0)
        }
        .onChange(of: mqttClient.isTerminated) { newValue in
            if(mqttClient.isTerminated) {
                infoProgrammedPills.done = false
                infoProgrammedPills.setContext(context: viewContext)
                infoProgrammedPills.getProgrammedPills()
                mqttClient.isTerminated = false
            }
        }
        .background(Image("medicalb").resizable().scaledToFill().ignoresSafeArea().opacity(0.2))
    }
    
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
    
}

struct ItemCell: View{
    
    var cura: String
    var farmaco: String
    var dataEOra: String
    var dispenser: String
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 30)
                .fill(LinearGradient(gradient: Gradient(colors: [Color("cardColor1.2"), Color("cardColor2.2")]), startPoint: .top, endPoint: .bottomTrailing))
                .frame(width: 320, height: 120)
            
            Text(cura)
                .fontWeight(.bold)
                .padding(.bottom, 80)

            VStack(alignment: .leading) {
                HStack(spacing: -1) {
                    Text("Farmaco: ")
                        .fontWeight(.semibold)
                    Text(farmaco)
                }
                HStack(spacing: -1) {
                    Text("Orario: ")
                        .fontWeight(.semibold)
                    Text(dataEOra)
                }
                HStack(spacing: -1) {
                    Text("Dispenser: ")
                        .fontWeight(.semibold)
                    Text(dispenser)
                }
            }
            .padding(.top, 20)
        }
    }
}

//struct ProgrammedPillsView_Previews: PreviewProvider {
//    static var previews: some View {
//        ProgrammedPillsView()
//    }
//}
