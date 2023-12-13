//
//  StatusDispenserView.swift
//  ICare4U
//
//  Created by Antonio Bove on 22/06/22.
//

import SwiftUI

struct StatusDispenserView: View {
    
    @Environment(\.managedObjectContext) private var viewContext

    @EnvironmentObject var mqttClient: MQTT
    
    @Environment(\.dismiss) private var dismiss
    
    @State private var cleanDisp1: Bool = false
    @State private var cleanDisp2: Bool = false
    @State private var showLoadingView: Bool = false
    
    var body: some View {
        
        if(showLoadingView) {
        
            splashImageBackground.overlay (
                LoadingView(animate: true, placeHolder: "Attendi")
                    .navigationBarBackButtonHidden(true)
            )
            
        } else {
    
            splashImageBackground.overlay (
                VStack { 
                    ZStack{
                        RoundedRectangle(cornerRadius: 25, style: .continuous)
                            .fill(Color("cardBackground"))
                            .shadow(radius: 10)
                    
                        VStack(spacing: 10) {
                            Image(systemName: "gear.circle")
                                .resizable()
                                .frame(width: 70, height: 70)
                                .foregroundColor(Color.blue)
                                
                            Text("Stato SmartDispenser")
                                .font(.system(size: 28, weight: .bold, design: .default))
                            

                            Text("Svuota i dispenser per associarli a un nuovo farmaco e controlla se è necessario rifornire il serbatoio dell'acqua.")
                                .multilineTextAlignment(.center)
                                .font(.system(size: 15, weight: .regular, design: .default))
                                .foregroundColor(.gray)
                        }
                        .padding(.top, 20)
                        
                    }
                    .frame(width: 350, height: 250)
                    .padding(.top, 10)
                    
                Form {
                    
                    Section(header: Text("Dispenser 1")){
                        Text(CoreDataController(context: viewContext).allDispenser()![0].contenuti == nil ? "Nessun farmaco associato" : CoreDataController(context: viewContext).allDispenser()![0].contenuti!.nome)
                            .fontWeight(.semibold)
                        
                        Button(action: {
                            showLoadingView = true
                            DispatchQueue.main.asyncAfter(deadline: .now() + 14) {
                                showLoadingView = false
                            }
                            
                            mqttClient.publish(topic: "/empty", message: "dispenser1", qos: .qos0)
                            
                            let farmaco = CoreDataController(context: viewContext).allDispenser()![0].contenuti
                            
                            CoreDataController(context: viewContext).removeLinkDispenserToFarmaco(dispenser: CoreDataController(context: viewContext).allDispenser()![0], farmaco: farmaco!)
                            
                            cleanDisp1 = false
                            
                        }) {
                            Text("Svuota")
                                .foregroundColor(!cleanDisp1 ? Color.gray : Color.blue)
                        }
                        .disabled(!cleanDisp1)    
                    }
                    
                    Section(header: Text("Dispenser 2")){
                        Text(CoreDataController(context: viewContext).allDispenser()![1].contenuti == nil ? "Nessun farmaco associato" : CoreDataController(context: viewContext).allDispenser()![1].contenuti!.nome)
                            .fontWeight(.semibold)
                        
                        Button(action: {
                            showLoadingView = true
                            DispatchQueue.main.asyncAfter(deadline: .now() + 14) {
                                showLoadingView = false
                            }
                            
                            mqttClient.publish(topic: "/empty", message: "dispenser2", qos: .qos0)
                            
                            let farmaco = CoreDataController(context: viewContext).allDispenser()![1].contenuti
                            
                            CoreDataController(context: viewContext).removeLinkDispenserToFarmaco(dispenser: CoreDataController(context: viewContext).allDispenser()![1], farmaco: farmaco!)
                            
                            cleanDisp2 = false
                            
                        }) {
                            Text("Svuota")
                                .foregroundColor(!cleanDisp2 ? Color.gray : Color.blue)
                        }
                        .disabled(!cleanDisp2)
                    }
                    
                    Section(header: Text("Acqua ")){
                        Text(mqttClient.isWaterEmpty ? "Non disponibile" : "Disponibile")
                            .foregroundColor(mqttClient.isWaterEmpty ? .red : .green)
                    }
                    
                }
                .onAppear {
                    mqttClient.publish(topic: "/water", message: "stato", qos: .qos0)
                    
                    if(CoreDataController(context: viewContext).allDispenser()![0].contenuti == nil){
                        cleanDisp1 = false    
                    } else {        
                        cleanDisp1 = true             
                    }
                    
                    if(CoreDataController(context: viewContext).allDispenser()![1].contenuti == nil){        
                        cleanDisp2 = false                 
                    } else {                
                        cleanDisp2 = true              
                    }
                }
                    
                }
                .onAppear(){
                    UITableView.appearance().backgroundColor = .clear
                }
            )
            
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
}

struct StatusDispenserView_Previews: PreviewProvider {
    static var previews: some View {
        StatusDispenserView()
    }
}
