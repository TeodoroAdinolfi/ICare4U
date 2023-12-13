//
//  PickPillView.swift
//  ICare4U
//
//  Created by Antonio Bove on 22/06/22.
//

import SwiftUI

struct PickPillView: View {
    
    @Environment(\.managedObjectContext) private var viewContext

    @EnvironmentObject var mqttClient: MQTT
    
    @ObservedObject var infoProgrammedPills: InfoProgrammedPillsClass

    @State private var isToggleOn = false
    
    var title = "Prossima pillola"
    var icon = "goforward"
    
    var farmaco: String = ""
    var orario: String = ""
    var dispenser: String = ""
    
    var body: some View {
        splashImageBackground.overlay(
            VStack {
            
                ZStack{
                    
                    RoundedRectangle(cornerRadius: 25, style: .continuous)
                        .fill(Color("cardBackground"))
                        .shadow(radius: 10)
                
                    VStack(spacing: 10){
                        Image(systemName: "pills")
                            .resizable()
                            .frame(width: 75, height: 70)
                            .foregroundColor(Color.blue)
                            
                        Text("Anticipa erogazione")
                            .font(.system(size: 28, weight: .bold, design: .default))
                        
                        Text("L'app ICare4U ti consente di prelevare anticipatamente la prossima pillola programmata.")
                            .multilineTextAlignment(.center)
                            .font(.system(size: 15, weight: .regular, design: .default))
                            .foregroundColor(.gray)
                            .frame(width: 300)
                    }
                    .padding(.top, 20)
                    
                }
                .frame(width: 350, height: 250)
                .padding(.top, 10)
                
                if(infoProgrammedPills.done && !infoProgrammedPills.programmedPills.isEmpty) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 30)
                            .fill(LinearGradient(gradient: Gradient(colors: [Color("cardColor1.2"), Color("cardColor2.2")]), startPoint: .top, endPoint: .bottomTrailing))
                            .frame(width: 350, height: 180)
    
                        HStack(spacing: 100) {
                            Text(title)
                                .bold()
                            
                            Button {
                                mqttClient.publish(topic: "/historical", message: "ack", qos: .qos0)
                            } label: {
                                ZStack {
                                    Circle().fill(LinearGradient(gradient: Gradient(colors: [Color("cardColor1.2"), Color("cardColor2.2")]), startPoint: .bottomTrailing, endPoint: .top))
                                        .frame(width: 40)
                                    Image(systemName: icon)
                                        .resizable()
                                        .frame(width: 20, height: 20)
                                        .foregroundColor(.white)
                                }
                                
                            }
                        }
                        .padding(.top, -100)
                        
                        VStack(alignment: .leading) {
                            
                            HStack(spacing: -1) {
                                Text("Cura: ")
                                    .fontWeight(.semibold)
                                    .frame(alignment: .leading)
                                Text((infoProgrammedPills.programmedPills.isEmpty ? "nd" : infoProgrammedPills.programmedPills.first?.cura)!)
                            }
                            
                            HStack(spacing: -1) {
                                Text("Farmaco: ")
                                    .fontWeight(.semibold)
                                    .frame(alignment: .leading)
                                Text((infoProgrammedPills.programmedPills.isEmpty ? "nd" : infoProgrammedPills.programmedPills.first?.farmaco)!)
                            }
                            
                            
                            HStack(spacing: -1) {
                                Text("Orario: ")
                                    .fontWeight(.semibold)
                                Text((infoProgrammedPills.programmedPills.isEmpty ? "nd" : infoProgrammedPills.programmedPills.first?.orario)!)
                            }
                            
                            
                            HStack(spacing: -1) {
                                Text("Dispenser: ")
                                    .fontWeight(.semibold)
                                Text((infoProgrammedPills.programmedPills.isEmpty ? "nd" : infoProgrammedPills.programmedPills.first?.dispenser)!)
                            }
                            
                        }
                        .padding(.top, 35)
                     
                    }
                    .padding()
                } else {
                    VStack(spacing: 20) {
                        
                        Image("empty").resizable().scaledToFit().frame(width: 120, height: 120)
                        ZStack{
                            RoundedRectangle(cornerRadius: 20)
                                .fill(Color("cardBackground"))
                                .shadow(radius: 5)
                                
                            Text("Nessuna pillola presente...")
                                .bold()
                        }
                        .frame(width: 350, height: 50, alignment: .center)
                    }
                    .padding(.top, 20)
                }
                
                Form {

                    Toggle(isOn: $isToggleOn) {
                        Text("Preleva acqua se disponibile")
                    }
                    .offset(x: -10)
                    
                    HStack {
                        Button(action: {
                            if(isToggleOn) {
                                mqttClient.publish(topic: "/preleva", message: "erogaConAcqua", qos: .qos0)
                            } else {
                                mqttClient.publish(topic: "/preleva", message: "eroga", qos: .qos0)
                            }
                        }) {
                            
                            Text("Preleva")
                                .foregroundColor(infoProgrammedPills.programmedPills.isEmpty ? Color.gray : Color.green)
                                .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: .center)
                        
                        }
                        .disabled(infoProgrammedPills.programmedPills.isEmpty)
                    }
                }
            
            }
            .onAppear {
                UITableView.appearance().backgroundColor = .clear
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
        )
        
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

//struct PickPillView_Previews: PreviewProvider {
//    static var previews: some View {
//        PickPillView(infoProgrammedPills: InfoProgrammedPillsClass())
//    }
//}
