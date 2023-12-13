//
//  addCuraView.swift
//  ICare4U
//
//  Created by Teodoro Adinolfi on 16/06/22.
//

import SwiftUI

struct addCuraView: View {
    

    
    @FetchRequest(entity: Utente.entity(), sortDescriptors:[]) var user : FetchedResults<Utente>
    
    @Environment(\.managedObjectContext) private var context
    @Environment(\.dismiss) private var dismiss
    
    @State private var info1 : String
    @State private var info2 : String
    @State private var info3 : String
    @State private var data = Date.now
    
    @State var trig: Binding<Bool>
    @EnvironmentObject var cure : CureContainer
    
    @State var alertTrig = false
    
    let cura : Cura?
    
    init(trig: Binding<Bool>,cura: Cura?){
        self._trig = State(initialValue: trig)
        self.cura = cura
        
        if (cura != nil){
            _info1 = State(initialValue: cura!.medico)
            _info2 = State(initialValue: cura!.descrizione!)
            _info3 = State(initialValue: cura!.nome)
        } else {
            _info1 = State(initialValue: "")
            _info2 = State(initialValue: "")
            _info3 = State(initialValue: "")
        }
    }

    

    
    
    var body: some View {
        
        splashImageBackground.overlay(
            ScrollView{
                VStack{
                    Text( cura == nil ? "Registra una cura" : "Modifica una cura")
                        .font(.largeTitle)
                        .bold()
                    formElem(title:"Dai un nome alla tua cura", placeholder:"Nome cura" ,inf:$info3)
                        .padding(15)
                    formElem(title:"Medico curante", placeholder:"Inserisci un medico" ,inf:$info1)
                        .padding(15)
                    formElemDescription(title: "Descrivici la tua cura" ,inf:$info2)
                        .padding(15)
                    if (cura == nil ){
                        customDate(date: $data)
                    }
                    Button{
                        let res = CoreDataController(context: context).searchCura(nome: info3)
                        if (res == nil){
                            if(cura==nil){
                                CoreDataController(context: context).addPrescrizione(utente: user.first!,nome: info3 ,descrizione: info2, medico: info1, dataInizio: data)
                                CoreDataController(context: context).fromCuraToTerminata()
                                cure.uploadCure()
                                trig.wrappedValue.toggle()
                            } else {
                                CoreDataController(context: context).updateCura(cura: cura!,nome: info3 ,descrizione: info2, medico: info1, dataInizio: cura!.dataInizio)
                                CoreDataController(context: context).fromCuraToTerminata()
                                cure.uploadCure()
                                dismiss()
                            }
                        } else {
                            alertTrig.toggle()
                        }
                    } label: {
                        ZStack{
                            RoundedRectangle(cornerRadius: 10)
                                .frame(width: 300, height: 50)
                                .background(Color(hex: "00AAFF"))
                            Text("Iniziamo!")
                                .foregroundColor(Color(.white))
                        }
                    }
                    .cornerRadius(10)
                    .alert(isPresented:$alertTrig){
                        Alert(title: Text("Attenzione"), message: Text("È già presente una cura con lo stesso nome"), dismissButton: Alert.Button.default(Text("Ok")))
                    }
                    
                        
                }
                .modifier(TopPadding(cura: cura))
            }
            .navigationBarTitleDisplayMode(.inline)
        )
    }
    
    struct TopPadding: ViewModifier {
        let cura : Cura?
        func body(content: Content) -> some View {
                if (cura != nil){
                content
                    .padding(.top,20)
                } else {
                    content
                }
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
    
    private struct formElem:View {
        var title: String
        var placeholder: String
        var inf: Binding<String>
        
        var body: some View {
            ZStack{
                RoundedRectangle(cornerRadius: 25, style: .continuous)
                .fill(Color("cardBackground"))
                .shadow(radius: 10)

                VStack(alignment: .leading){
                    Text(title)
                    TextField(placeholder, text: inf)
                        .disableAutocorrection(true)
                        .overlay(
                            Rectangle()
                                .frame(height: 2)
                                .padding(.top, 30)
                                .foregroundColor(Color(hex: "#00AAFF"))
                                .opacity(0.5)
                        )
                        
                    
                }.padding(15)
            }
            .frame(width: 350, height: 80)
        }
    }
    
    private struct formElemDescription:View {
        var title: String
        var inf: Binding<String>
        
        var body: some View {
            ZStack{
                RoundedRectangle(cornerRadius: 25, style: .continuous)
                .fill(Color("cardBackground"))
                .shadow(radius: 10)

                VStack(alignment: .leading){
                    Text(title)
                    ZStack(alignment: .topLeading){
                        RoundedRectangle(cornerRadius: 25, style: .continuous)
                            .fill(.gray)
                            .opacity(0.2)
                        TextEditor(text: inf)
                            .disableAutocorrection(true)
                            .onAppear{
                                UITextView.appearance().backgroundColor = .clear
                            }
                            .padding()
                    }.zIndex(1)
                }.padding(15)
            }
            .frame(width: 350, height: 250)
        }
    }
    
    private struct customDate: View {
        
        var date: Binding<Date>
        
        var body: some View{
            
            ZStack{
                RoundedRectangle(cornerRadius: 25, style: .continuous)
                .fill(Color("cardBackground"))
                .shadow(radius: 10)

                VStack{
                    DatePicker("Inizio cura:",selection:date,in: Date.now... ,displayedComponents: [.date])
                    
                    
                }.padding(10)
            }
            .frame(width: 300, height: 80)
            .padding(10)
        }
        
    }
    
    
}

/*Grafica , textifeld personalizzata*/
extension View {
    func underlineTextField() -> some View {
        self
            .padding(.vertical, 10)
            .padding(10)
    }
}





