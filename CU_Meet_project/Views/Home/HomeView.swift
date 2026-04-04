//
//  HomeView.swift
//  CU_Meet_project
//
//  Created by Imtnk on 3/4/2569 BE.
//

import SwiftUI

struct HomeView: View {
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                
                Text("CU Meet").font(.title)
                Image("logo_meet").resizable().scaledToFill().frame(width: 200, height: 200).cornerRadius(75).shadow(radius: 3)
                NavigationLink(destination: RoomMapView()) {
                    Text("Book Now")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .clipShape(RoundedRectangle(cornerRadius: 15))
                        .padding(.horizontal)
                }
                
                Spacer()
            }
            .navigationTitle("Home")
        }
    }
}

#Preview {
    HomeView()
}
