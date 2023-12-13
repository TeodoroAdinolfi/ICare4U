//
//  ErrorView.swift
//  ICare4U
//
//  Created by Antonio Bove on 22/06/22.
//

import SwiftUI

struct ErrorView: View {
    
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        splashImageBackground.overlay (
            ZStack(alignment: Alignment(horizontal: .trailing, vertical: .top)) {
                VStack(spacing: 25) {
                    Image(systemName: "exclamationmark.circle.fill")
                        .resizable()
                        .frame(width: 100, height: 100)
                        .foregroundColor(Color.red)
                    
                    Text("Assicurati che il dispositivo sia acceso, connettiti e inizia ad usare lo SmartDispenser!")
                        .multilineTextAlignment(.center)
                    
                    Button(action: {
                        dismiss()
                    }, label: {
                        Text("Indietro")
                            .foregroundColor(.white)
                            .fontWeight(.bold)
                            .padding(.vertical, 10)
                            .padding(.horizontal, 25)
                            .background(Color.black)
                            .clipShape(Capsule())
                    })
                }
                .padding(.vertical, 25)
                .padding(.horizontal, 30)
                .background(BlurView())
                .cornerRadius(25)
                
            }
            .navigationBarBackButtonHidden(true)
            .padding(.top, -60)
        )
    }
    
    
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

struct BlurView: UIViewRepresentable {
    
    func makeUIView(context: Context) -> some UIVisualEffectView {
    
        let view = UIVisualEffectView(effect: UIBlurEffect(style: .systemThinMaterial))
        
        return view
    }
    
    func updateUIView(_ uiView: UIViewType, context: Context) {
        
    }
}

struct ErrorView_Previews: PreviewProvider {
    static var previews: some View {
        ErrorView()
    }
}
