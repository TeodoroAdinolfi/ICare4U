//
//  LoadingView.swift
//  ICare4U
//
//  Created by Antonio Bove on 31/05/22.
//

import SwiftUI

struct LoadingView: View {

    @State var animate = false
    
    var placeHolder: String

    var body: some View {
        
        VStack(spacing: 28) {
            
            Circle()
                .stroke(AngularGradient(gradient: .init(colors: [Color.primary, Color.primary.opacity(0)]), center: .center))
                .frame(width: 80, height: 80)
                .rotationEffect(.init(degrees: animate ? 360 : 0))
            
            Text(placeHolder)
                .fontWeight(.bold)
                
        }
        .padding(.vertical, 25)
        .padding(.horizontal, 35)
        .background(BlurView())
        .cornerRadius(20)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            Color.primary.opacity(0.35)
        )
        .onAppear {
            withAnimation(Animation.linear(duration: 1.5).repeatForever(autoreverses: false)) {
                animate.toggle()
            }
        }
    }
        
}

struct LoadingView_Previews: PreviewProvider {
    static var previews: some View {
        LoadingView(animate: true, placeHolder: "Plase wait")
    }
}
