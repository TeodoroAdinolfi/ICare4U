//
//  NewPillView.swift
//  ICare4U
//
//  Created by Antonio Bove on 22/06/22.
//

import SwiftUI

struct NewPillView: View {

    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss

    @EnvironmentObject var mqttClient: MQTT
    
    @StateObject var infoAddPill = InfoAddPillClass()
    
    @FetchRequest(entity: Utente.entity(), sortDescriptors:[]) var result : FetchedResults<Utente>

    @State private var selectedDisp: String = ""
    @State private var selectedPill: String = ""
    @State private var selectedCura: String = ""
    
    @State private var isSelectedDisp: Bool = false
    @State private var isSelectedCura: Bool = false
    @State private var isSelectedPill: Bool = false
    
    @State private var trigAlert: Bool = false
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
                    
                    ZStack {
                        
                        RoundedRectangle(cornerRadius: 25, style: .continuous)
                            .fill(Color("cardBackground"))
                            .shadow(radius: 10)
                    
                        VStack(spacing: 10) {
                            Image(systemName: "plus")
                                .resizable()
                                .frame(width: 70, height: 70)
                                .foregroundColor(Color.blue)
                                
                            Text("Programma erogazione")
                                .font(.system(size: 28, weight: .bold, design: .default))
                            
                            Text("L'app ICare4U, grazie all'interazione con lo smartDispenser, ti consente di programmare le assunzioni dei farmaci delle tue cure in corso.")
                                .multilineTextAlignment(.center)
                                .font(.system(size: 15, weight: .regular, design: .default))
                                .foregroundColor(.gray)
                        }
                        .padding(.top, 20)
                        
                    }
                    .frame(width: 350, height: 250)
                    .padding(.top, 10)
                    
                    Form {

                        Section("Dispenser", content: {
                            
                            Picker("Dispenser", selection: $selectedDisp) {
                                
                                ForEach(infoAddPill.dispenser, id: \.self) {
                                    Text($0)
                                }
                            }
                            .pickerStyle(.menu)
                            .onChange(of: selectedDisp) { _ in
                                if(selectedDisp == "Nessuna selezione") {
                                    isSelectedDisp = false
                                    isSelectedCura = false
                                } else {
                                    infoAddPill.getCure()
                                    isSelectedDisp = true
                                }
                            }
                            
                        })
                        
                        if(isSelectedDisp) {
                            
                            Section("Cura", content: {
                                
                                Picker("Cure", selection: $selectedCura) {
                                    
                                    ForEach(infoAddPill.cure, id: \.self) {
                                        Text($0)
                                    }
                                }
                                .pickerStyle(.menu)
                                .onChange(of: selectedCura) { _ in
                                    if(selectedCura == "Nessuna selezione") {
                                        isSelectedCura = false
                                    } else {
                                        infoAddPill.getFarmaci(cura: selectedCura)
                                        isSelectedCura = true
                                    }
                                }
                                
                            })
                            
                        }
                        
                        if(isSelectedCura) {
                            
                            Section("Pillola", content: {
                                
                                Picker("Pillole", selection: $selectedPill) {
                                    
                                    ForEach(infoAddPill.farmaci, id: \.self) {
                                        Text($0)
                                    }
                                }.pickerStyle(.menu)
                                .onChange(of: selectedPill) { _ in
                                    if(selectedPill != "Nessuna selezione"){
                                        infoAddPill.getAssunzioni(farmaco: selectedPill)
                                        isSelectedPill = true
                                    }
                                }
                                
                            })
                            
                        }
                        
                    }.toolbar {
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button(action: {

                                var str = "" 
                                var numDisp: Int

                                if(selectedDisp == "Dispenser 1"){
                                    numDisp = 0
                                } else {
                                    numDisp = 1
                                }

                                for elem in infoAddPill.orari {
                                    str += "\(selectedPill);\(elem);\(numDisp)&"
                                }

                                if(infoAddPill.linkDispenserToFarmaco(dispenser: selectedDisp, farmaco: selectedPill)){
                                    
                                    mqttClient.publish(topic: "/newPill", message: str, qos: .qos1)
                                    
                                    showLoadingView = true
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 6) {
                                        showLoadingView = false
                                        dismiss()
                                    }
                                    
                                } else {
                                    isSelectedDisp = false
                                    isSelectedCura = false
                                    trigAlert.toggle()
                                }

                            }, label: {

                                    Text("Aggiungi")
                                        .foregroundColor(selectedPill == "Nessuna selezione" || selectedPill == "" ? Color.gray : Color.blue)
                            })
                            .disabled(selectedPill == "Nessuna selezione" || selectedPill == "")
                        }
                    }
                }
                .onAppear {
                    UITableView.appearance().backgroundColor = .clear
                    infoAddPill.setContext(context: viewContext)
                    infoAddPill.getDispenser()
                }
                .alert(isPresented: $trigAlert) {
                    Alert(title: Text("Attenzione"), message: Text("Impossibile programmare l'assunzione, il farmaco risulta già associato a un dispenser! Vai nelle impostazioni del dispositivo per svuotarlo."), dismissButton: Alert.Button.default(Text("Ok")))
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

struct NewPillView_Previews: PreviewProvider {
    static var previews: some View {
        NewPillView()
    }
}
