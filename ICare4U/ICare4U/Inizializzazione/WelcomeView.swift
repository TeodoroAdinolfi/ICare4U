//
//  WelcomeView.swift
//  ICare4U
//
//  Created by Antonio Bove on 19/04/22.
//

import SwiftUI

struct WelcomeView: View {
    
    @Environment(\.managedObjectContext) private var viewContext
    
    @State private var flag = false
    
    var body: some View {
        
        if !flag {
            ScrollView {
                VStack(alignment: .center) {

                    Spacer()

                    TitleView()

                    InformationContainerView()

                    Spacer(minLength: 30)

                    Button{
                        
                        for i in 0..<2 {
                            let dispenser = Dispenser(context: viewContext)
                            dispenser.nome = "Dispenser \(i+1)"
                            do {
                                try viewContext.save()
                                print("Dispenser creato e salvato")
                            } catch {
                                print("Salvataggio fallito")
                            }
                        }
                        flag.toggle()
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
                
                }
            }
        } else {
            UserDataView()
                .environment(\.managedObjectContext, viewContext)
        }
    }
}

struct TitleView: View {
    var body: some View {
        VStack {
            Text("Benvenuto in")
                .customTitleText()
                .foregroundColor(Color("textForced"))

            Text("ICare4U")
                .customTitleText()
                .foregroundColor(Color(hex: "00AAFF"))
                
        }.padding(.top, 90)
    }
}

struct InformationContainerView: View {
    var body: some View {
        VStack(alignment: .leading) {
            InformationDetailView(title: "Pianifica", subTitle: "Quando assumere i tuoi medicinali, con diverse modalità di schedulazione ", imageName: "calendar.badge.clock")

            InformationDetailView(title: "Ricorda", subTitle: "Riceverai una notifica quando le tue assunzioni stanno per arrivare", imageName: "bell.badge")

            InformationDetailView(title: "Analizza", subTitle: "Un insieme di statistiche riassumeranno l'andamento delle tue cure", imageName: "chart.line.uptrend.xyaxis")
            
            InformationDetailView(title: "Erogazione smart", subTitle: "Per la gestione del tuo dispenser di farmaci", imageName: "lightbulb")
            
            
        }
        .padding(.horizontal)
    }
}

struct InformationDetailView: View {
    var title: String = "title"
    var subTitle: String = "subTitle"
    var imageName: String = "car"

    var body: some View {
        HStack(alignment: .center) {
            Image(systemName: imageName)
                .font(.largeTitle)
                .foregroundColor(Color(hex: "00AAFF"))
                .padding()
                .accessibility(hidden: true)

            VStack(alignment: .leading) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(.primary)
                    .accessibility(addTraits: .isHeader)

            Text(subTitle)
                .font(.body)
                .foregroundColor(.secondary)
                .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(.top)
    }
}


extension Text {
    func customTitleText() -> Text {
        self
            .fontWeight(.black)
            .font(.system(size: 36))
            
    }
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

struct WelcomeView_Previews: PreviewProvider {
    static var previews: some View {
        WelcomeView()
            .previewInterfaceOrientation(.portrait)
    }
}




