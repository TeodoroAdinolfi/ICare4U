//
//  ChartsView.swift
//  ICare4U
//
//  Created by Emilio Amato on 19/06/22.
//

import SwiftUI
import CoreData

struct InsightsView: View {
        
    @Environment(\.managedObjectContext)  var context
    @State var showingSheet = false
    @FetchRequest(entity: Utente.entity(), sortDescriptors:[]) var user : FetchedResults<Utente>
    
    var body: some View {
        
        /* Recupero di tutte le cure associate all'utente fetchato, in particolar modo il primo (e unico)*/
        let cure = CoreDataController(context: context).allCureOf(utente: user.first!)!
        
        VStack{
            
           NavigationView{
               
               
               /* Se ci sono cure associate, mostra quest'ultime come navigation link con destinazione la view di raccoglimento dei farmaci associati, altrimenti
                mostra all'utente la view indicante l'assenza di farmaci associati alla cura, passando come riferimento la specifica cura e il contesto, permettendo
                di essere utilizzato nella view di destinazione */
               
               if(!cure.isEmpty){
                   
                   /* Background applicato alla view */
                   splashImageBackground.overlay(
                        List{
                            
                            ForEach(cure){ cura in
                        
                        
                        
                                    NavigationLink(destination:InfoFarmaciView(cura: cura, context:context)){
            
                                    /* Struttura associata al navigation link, con immagine e nome della cura*/
                                    HStack(spacing: 10){
                                    ZStack{
                                        
                                        Image("treatment")
                                                .resizable()
                                                .scaledToFit()
                                                .frame(width: 50, height: 50)
                                    }
                                        
                                        Text("\(cura.nome) ").font(.headline)
                                        
                                    }.padding(7)
                                
                                    }
                        
                            .navigationTitle("Insights")
                            .toolbar {
                                Button("Registra sintomi"){
                                            showingSheet.toggle()
                                }.sheet(isPresented: $showingSheet) {
                                            registraSintomiView(cura: cure, context: context) /* Form per la registrazione dei sintomi*/
                                        }
                                
                            }
                        
                        }
                    
                    }.shadow(color: .black, radius: 1, x: 1, y: 1)
                
                   )
                   
               }
               else {
                   
                   /* Background applicato alla view di visualizzazione di assenza di cure */
                   splashImageBackground.overlay(
                    
                        VStack(spacing: 20){
                            Image("notreatment").resizable().scaledToFit().frame(width: 180, height: 180)
                            
                            ZStack{
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(Color("cardBackground"))
                                    .shadow(radius: 5)
                                    
                                Text("Nessun cura ancora aggiunta").bold().font(.callout)
                            }.frame(width: 350, height: 50, alignment: .center)
                           
                        }
                        .navigationTitle("Insights")
                        
                   )
               }
               
               
                
           }
                
            
        }.onAppear(){
            
            /* Eliminazione del background color al fine dell'applicazione dello sfondo */
            UITableView.appearance().backgroundColor = .clear
            
        }

        
        
       
          
}
    
    /* Background da applicare alla view */
    var splashImageBackground: some View {
           GeometryReader { geometry in
               Image("medicalb")
                   .resizable()
                   .aspectRatio(contentMode: .fill)
                   .edgesIgnoringSafeArea(.all)
                   .frame(width: geometry.size.width)
                   .opacity(0.15)
           }
       }
}


struct InsightsView_Previews: PreviewProvider {
    static var previews: some View {
        InsightsView()
    }
}
