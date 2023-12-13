//
//  ControlView.swift
//  ICare4U
//
//  Created by Antonio Bove on 26/06/22.
//

import SwiftUI

struct ControlView: View {
    
    @Environment(\.managedObjectContext) private var viewContext
    
    @StateObject var mqttClient = MQTT(clientID: "iCare4U", host: "mqtt.eclipseprojects.io")
    
    var body: some View {
        
        NavigationView {
            splashImageBackground.overlay (
                ZStack {
                    VStack {
                        HStack {
                            HeaderView(isConnected: mqttClient.isConnected).environmentObject(mqttClient)
                                .padding(.top, 25)
                                .padding(.bottom, 15)
                        } 
                        HStack {
                            ZStack {
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(Color("cardBackground"))
                                    .shadow(radius: 5)
                                HStack {
                                    Button {
                                        if(!mqttClient.isConnected){  
                                            let dateFormatter = DateFormatter()
                                            dateFormatter.dateFormat = "dd/MM/yyyy, HH:mm:ss"
                                            let time = dateFormatter.string(from: Date.now)
                                            dateFormatter.dateFormat = "dd/MM/yyyy;HH:mm"
                                            
                                            var str: String = "\(time), "
                                            
                                            let dispenser = CoreDataController(context: viewContext).allDispenser()
                                            
                                            if(dispenser != nil) {
                                                for elem in dispenser! {
                                                    let farmaco = elem.contenuti
                                                    if(farmaco != nil) {
                                                        let assunzioni = CoreDataController(context: viewContext).allAssunzioneOf(farmaco: elem.contenuti!)
                                                        if(assunzioni != nil) {
                                                            for item in assunzioni! {
                                                                if(item.associabileAlDispenser == true && !item.assunzionePassata) {
                                                                str.append("\(farmaco!.nome);\(dateFormatter.string(from: item.orarioProgrammato!));\(elem.nome == "Dispenser 1" ? "0" : "1")&")
                                                                }
                                                            }
                                                        }
                                                    }
                                                }
                                            }
                                            
                                            if(str == "\(time), ") {
                                                str.append("void")
                                            }
                                            
                                            mqttClient.subscribe(topic: [("/checkInit", .qos0), ("/checkWater", .qos0), ("/checkHistorical", .qos0)])
                                            mqttClient.publish(topic: "/connection", message: str, qos: .qos0)
                
                                        } else {
                                            mqttClient.disconnect()
                                        }
                                    } label: {
                                        ZStack {
                                            Image(systemName: "power")
                                                .font(.system(size: 25))
                                            RoundedRectangle(cornerRadius: 25)
                                                .stroke(Color.gray, lineWidth: 1)
                                                .frame(width: 50, height: 50)
                                                .foregroundColor(.white)
                                        }
                                    }
                                    
                                    VStack(alignment: .leading) {
                                        Text("Premi per connetterti")
                                            .font(.system(size: 25, weight: .bold, design: .default))
                                        Text(mqttClient.isConnected ? "Connesso" : "Disconnesso")
                                            .font(.system(size: 15, weight: .semibold, design: .default))
                                            .foregroundColor(mqttClient.isConnected ? .green : .red)
                                    }
                                }
                                
                            }
                            .frame(width: 350, height: 80, alignment: .center)

                            Spacer()
                        }
                        .padding(.leading, 18)
                        .padding(.vertical, 20)
                        
                        ActionView()
                            .environmentObject(mqttClient)
                            .environment(\.managedObjectContext, viewContext)
                    }
                }
                .padding(.top, -150)
            )
        }
        .edgesIgnoringSafeArea(.all)
        .onAppear {
            mqttClient.connect()
        }
    }
    
    var splashImageBackground: some View {
        GeometryReader { geometry in
            Image("medicalb")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .edgesIgnoringSafeArea(.all)
                .frame(width: 485)
                .opacity(0.15)
        }
    }
}

struct ControlView_Previews: PreviewProvider {
    static var previews: some View {
        ControlView()
    }
}

struct HeaderView: View {

    @Environment(\.managedObjectContext) private var viewContext
    
    @EnvironmentObject var mqttClient: MQTT
    
    var isConnected: Bool
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text("Benvenuto in")
                    .font(.system(size: 15, weight: .medium, design: .default))
                    .foregroundColor(.blue)
                Text("SmartDispenser")
                    .font(.system(size: 35, weight: .bold, design: .default))
                    
            }
            .padding(.leading, 30)
            .padding(.top, 30)
            
            Spacer()
            
            NavigationLink(destination: {
                if(isConnected) {
                    StatusDispenserView().navigationTitle("Stato").navigationBarTitleDisplayMode(.inline)
                        .environment(\.managedObjectContext, viewContext)
                        .environmentObject(mqttClient)  
                } else { 
                    ErrorView()   
                }
                    
            }, label: {
                Image(systemName: "gear")
                    .resizable()
                    .frame(width: 35, height: 35)
                    .padding(.trailing, 30)
                    .foregroundColor(.blue)
            })
        }
        .navigationBarHidden(true)
    }

}
