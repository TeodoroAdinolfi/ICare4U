//
//  ActionView.swift
//  ICare4U
//
//  Created by Antonio Bove on 21/06/22.
//

import SwiftUI

struct ActionView: View {
    
    @Environment(\.managedObjectContext) private var viewContext

    @EnvironmentObject var mqttClient: MQTT
    
    @StateObject var infoProgrammedPills = InfoProgrammedPillsClass()
    
    var body: some View {
        
        LazyVGrid (
            columns: [GridItem(.adaptive(minimum: 150), spacing: 20)],
            spacing: 20
        ){
            
            NavigationLink(destination: {
                if(mqttClient.isConnected) {
                    NewPillView().navigationTitle("Programma").navigationBarTitleDisplayMode(.inline).environmentObject(mqttClient)
                        .environment(\.managedObjectContext, viewContext)
                } else {
                    ErrorView()
                }
            }, label: {
                CardItemView(card: CardItemData(title: "Programma", icon: "plus", color: Color(hex: "#00AAFF"), titleColor: Color(hex: "FFFFFF")))
            })
            
            NavigationLink(destination: {
                if(mqttClient.isConnected) {
                    PickPillView(infoProgrammedPills: infoProgrammedPills).navigationTitle("Preleva").navigationBarTitleDisplayMode(.inline)
                        .environmentObject(mqttClient)
                        .environment(\.managedObjectContext, viewContext)
                } else {
                    ErrorView()
                }
            }, label: {
                CardItemView(card: CardItemData(title: "Preleva", icon: "pills", color: Color.red, titleColor: Color(hex: "FFFFFF")))
            })
            
            NavigationLink(destination: {
                if(mqttClient.isConnected) {
                    ProgrammedPillsView(infoProgrammedPills: infoProgrammedPills).navigationTitle("Assunzioni pianificate").navigationBarTitleDisplayMode(.inline)
                        .environmentObject(mqttClient)
                } else {
                    ErrorView()
                }
            }, label: {
                CardItemView(card: CardItemData(title: "Pianificate", icon: "calendar.badge.clock", color: Color.orange, titleColor: Color(hex: "FFFFFF")))
            })
            
            NavigationLink(destination: {
                if(mqttClient.isConnected) {
                    HistoricalView().navigationTitle("Storico assunzioni").navigationBarTitleDisplayMode(.inline)
                        .environmentObject(mqttClient)
                } else {
                    ErrorView()
                }
            }, label: {
                CardItemView(card: CardItemData(title: "Storico", icon: "archivebox", color: Color.green, titleColor: Color(hex: "FFFFFF")))
            })

        }
        .padding(.horizontal, 20)
        .padding(.vertical, 20)
    }
}


