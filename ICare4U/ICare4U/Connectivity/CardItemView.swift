//
//  CardItemView.swift
//  ICare4U
//
//  Created by Antonio Bove on 23/06/22.
//

import SwiftUI

struct CardItemView: View {
    
    var card: CardItemData
    
    var body: some View {
            
        VStack {
            HStack {
                Image(systemName: card.icon)
                    .resizable()
                    .frame(width: 40, height: 35)
                    .foregroundColor(Color.white)
                Spacer()
            }
            .padding(.leading, 15)
            .padding(.bottom, 20)
            
            HStack {
                VStack(alignment: .leading) {
                    Text(card.title)
                        .font(.system(size: 20, weight: .bold, design: .default))
                        .foregroundColor(card.titleColor)
                }
                Spacer()
            }
            .padding(.leading, 15)
            
        }
        .frame(width: 160, height: 160)
        .background(card.color)
        .cornerRadius(30)
        .overlay(RoundedRectangle(cornerRadius: 30).stroke(Color.gray, lineWidth: 1))

    }
    
}

//struct CardItemView_Previews: PreviewProvider {
//    static var previews: some View {
//        CardItemView()
//    }
//}
