//
//  RoomMap.swift
//  CU_Meet_project
//
//  Created by Imtnk on 3/4/2569 BE.
//

import SwiftUI
import MapKit

struct RoomMapView: View {
    
    @StateObject private var viewModel = HomeViewModel()
    @State private var selectedRoom: MeetingRoom? = nil
    @State private var recentRooms: [MeetingRoom] = []
    
    private func addToRecent(_ room: MeetingRoom) {
        // Remove if already exists (avoid duplicates)
        recentRooms.removeAll { $0.id == room.id }
        
        // Insert at front
        recentRooms.insert(room, at: 0)
        
        // Keep only last 3
        if recentRooms.count > 3 {
            recentRooms = Array(recentRooms.prefix(3))
        }
    }
    
    var body: some View {
        VStack {
            
            // Map Card
            Map(
                position: Binding(
                    get: {
                        viewModel.position
                    },
                    set: { newValue in
                        // Just ignore updates here
                    }
                )
            ) {
                ForEach(rooms) { room in
                    Annotation(room.name, coordinate: room.coordinate) {
                        Button {
                            selectedRoom = room
                            addToRecent(room)
                        } label: {
                            Image(systemName: "mappin.circle.fill")
                                .resizable()
                                .frame(width: viewModel.pinSize, height: viewModel.pinSize)
                                .foregroundColor(.red)
                                .animation(.easeInOut(duration: 0.2), value: viewModel.pinSize)
                                .shadow(radius: 3)
                        }
                    }
                }
            }
            .mapStyle(.standard(elevation: .flat))
            .onMapCameraChange { context in
                viewModel.region = context.region
                viewModel.clampRegion()
            }
            .onAppear { // to fix mismatched default zoom
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    viewModel.resetView()
                }
            }
            .frame(height: 300)
            .background(Color(.systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .shadow(radius: 5)
            .padding(.horizontal)
            .padding(.top,5)
            
            // Controls
            HStack(spacing: 10) {
                Spacer()
                HStack(spacing: 20) {
                    Button(action: { viewModel.zoomIn() }) {
                        Image(systemName: "plus.magnifyingglass")
                    }
                    
                    Button(action: { viewModel.zoomOut() }) {
                        Image(systemName: "minus.magnifyingglass")
                    }
                    
                    Button(action: {viewModel.resetView()}) {
                        Image(systemName: "arrow.clockwise")
                    }
                }
                .padding(.top, 10)
            }
            .padding()
            
            // Recent
            if !recentRooms.isEmpty {
                VStack(alignment: .leading, spacing: 12) {
                    
                    Text("Recent")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    VStack(spacing: 8) {
                        ForEach(recentRooms) { room in
                            Button {
                                selectedRoom = room
                            } label: {
                                HStack {
                                    Text(room.name)
                                        .font(.body)
                                        .foregroundColor(.primary)
                                    
                                    Spacer()
                                    
                                    Image(systemName: "chevron.right")
                                        .foregroundColor(.gray)
                                }
                                .padding()
                                .background(Color(.systemBackground))
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                                .shadow(radius: 2)
                            }
                        }
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .padding(.bottom, 10)
            }
            
            Spacer()
        }
        .sheet(item: $selectedRoom) { room in
            RoomDetailSheet(room: room)
                .presentationDetents([.large])
                .presentationDragIndicator(.visible)
        }
        .navigationTitle("Select Room")
    }
}

#Preview {
    RoomMapView()
}

