//
//  CareKitView.swift
//  ICare4U
//
//  Created by Emilio Amato on 03/06/22.
//

import SwiftUI

struct CareKitView: View {
    
    @FetchRequest(entity: Utente.entity(), sortDescriptors:[]) var user : FetchedResults<Utente>
    
    
    var body: some View {
        
        
        VStack(spacing: 0){
    
            VStack(alignment: .leading){
                Text("Benvenuto, \(user.first!.nome!) \(user.first!.cognome!)")
                    .font(.title2)
                    .bold()
                    .padding(.leading, 15)
                    .padding(.top, 10)
                splashImageBackground.overlay( CareController() ) /*View contenente il controller di visualizzazione dei task, ottenuto attraverso bridge da CareKit e configurato*/
            }.background(Color("defaultBackground"))
            
        }.edgesIgnoringSafeArea(.bottom)
        
            
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

struct CareKitView_Previews: PreviewProvider {
    static var previews: some View {
        CareKitView()
    }
}







