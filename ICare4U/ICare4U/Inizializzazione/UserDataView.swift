//
//  UserDataView.swift
//  ICare4U
//
//  Created by Emilio Amato on 20/04/22.
//

import SwiftUI

struct UserDataView: View {
    
    @Environment(\.managedObjectContext) private var viewContext
    
    @AppStorage("welcomeScreenShown")
    var welcomeScreenShown: Bool = false
    
    @State private var name = ""
    @State private var surname = ""
    @State private var birthdate = Date()
    
    var body: some View {
        NavigationView {
            
            ZStack {
                Color(hex: "00AAFF")
                    .ignoresSafeArea()
                Circle()
                    .scale(1.8)
                    .foregroundColor(Color("defaultBackground").opacity(0.15))
                Circle()
                    .scale(1.5)
                    .foregroundColor(Color("defaultBackground"))
                VStack {
                    
                    HStack{
                    Text("Parlaci di")
                        .font(.largeTitle)
                        .bold()
                    Text("te")
                        .font(.largeTitle)
                        .bold()
                        .foregroundColor(Color(hex: "00AAFF"))
                        
                    }.padding()
                    
                    
                    TextField("Nome", text: $name)
                        .padding()
                        .frame(width: 300, height: 50)
                        .background(Color("userForm"))
                        .cornerRadius(10)
                    
                    TextField("Cognome", text: $surname)
                        .padding()
                        .frame(width: 300, height: 50)
                        .background(Color("userForm"))
                        .cornerRadius(10)
                    
                    
                    Button(){
                        
                        let newUtente = Utente(context: viewContext)
                        newUtente.id = UUID()
                        newUtente.nome = $name.wrappedValue
                        newUtente.cognome = $surname.wrappedValue
                        newUtente.dataNascita = $birthdate.wrappedValue
                        
                        do {
                            try viewContext.save()
                        }catch let error {
                            print("Error saving Core Data. \(error.localizedDescription)")
                        }
                        
                        
                        welcomeScreenShown = true
                    } label: {
                        ZStack{
                            RoundedRectangle(cornerRadius: 10)
                                .frame(width: 300, height: 50)
                                .background(!checkField(name: self.name, surname: self.surname) ? Color(hex: "00AAFF") : Color(hex: "00AAFF").opacity(0.50))
                            Text("Entra!")
                                .foregroundColor(Color(.white))
                        }
                    }
                    .cornerRadius(10)
                    .padding(.top,50)
                    .disabled(checkField(name: self.name, surname: self.surname))
                    
                    
                }.padding(.top, -100)
                
            }
            
        }
        .navigationBarHidden(true)
    }
    
    private func checkField(name: String, surname: String) -> Bool {
        
        return name.isEmpty || surname.isEmpty
    }
}

struct UserDataView_Previews: PreviewProvider {
    static var previews: some View {
        UserDataView()
    }
}
