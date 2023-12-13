//
//  InfoFarmaciView.swift
//  ICare4U
//
//  Created by Emilio Amato on 22/06/22.
//

import SwiftUI
import CoreData



struct InfoFarmaciView: View {
    
    let context: NSManagedObjectContext
    let cura: Cura
    @State var showingSheet = false
    
    init(cura: Cura, context: NSManagedObjectContext){
        self.cura = cura
        self.context = context
    }
    

    
    var body: some View {
            
            /*Recupero farmaci associati alla cura selezionata dal navigation link della vista InsightsView*/
            let farmaci  = CoreDataController(context: context).allFarmaciOf(cura: cura)
        
                VStack{
                    
                        if(!farmaci!.isEmpty){
                            
                            List{
                            
                                ForEach(farmaci!){farmaco in
                                    
                                    HStack(spacing: 10){
                                       Image("medicine")
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 50, height: 50)

                                        Button("\(farmaco.nome)"){
                                                             showingSheet.toggle()

                                        }
                                        .foregroundColor(Color("textForced"))
                                            .font(.headline)
                                            .sheet(isPresented: $showingSheet) {
                                                            InfoSintomiFarmaco(farmaco: farmaco, context: context)
                                                         }
                                            
                                    }.padding(7)
                                    
                                }
                                
                            }


                                .navigationTitle("Sintomi dei farmaci")


                        }else{
                            
                            /* Background applicato alla view di visualizzazione di assenza farmaci */
                            
                            splashImageBackground.overlay(
                            
                                    VStack(spacing: 20){
                                        
                                        Image("empty").resizable().scaledToFit().frame(width: 180, height: 180)
                                        ZStack{
                                            RoundedRectangle(cornerRadius: 20)
                                                .fill(Color("cardBackground"))
                                                .shadow(radius: 5)
                                                
                                            Text("Nessun farmaco ancora aggiunto alla cura").bold().font(.callout)
                                        }.frame(width: 350, height: 50, alignment: .center)
                                        
                                    }
                                    
                            )
                        }

                }.background(Image("medicalb").resizable().scaledToFill().ignoresSafeArea().opacity(0.2)).onAppear(){
                    
                    /* Eliminazione dello sfondo al fine dell'applicazione della background image */
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
    



