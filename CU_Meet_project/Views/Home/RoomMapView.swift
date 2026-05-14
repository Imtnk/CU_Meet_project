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
    @State private var recentRooms: [MeetingRoom] = []
    @State private var searchText = ""
    @State private var showFilters = false
    @State private var selectedFacilities: Set<Facility> = []
    @State private var minCapacity = 1

    private var isFiltering: Bool {
        !searchText.isEmpty || !selectedFacilities.isEmpty || minCapacity > 1
    }

    private var filteredRooms: [MeetingRoom] {
        viewModel.rooms.filter { room in
            let matchesSearch = searchText.isEmpty ||
                room.name.localizedCaseInsensitiveContains(searchText)
            let matchesFacilities = selectedFacilities.isEmpty ||
                selectedFacilities.isSubset(of: Set(room.facilities))
            let matchesCapacity = room.capacity >= minCapacity
            return matchesSearch && matchesFacilities && matchesCapacity
        }
    }

    private func addToRecent(_ room: MeetingRoom) {
        recentRooms.removeAll { $0.id == room.id }
        recentRooms.insert(room, at: 0)
        if recentRooms.count > 3 {
            recentRooms = Array(recentRooms.prefix(3))
        }
    }

    var body: some View {
        VStack(spacing: 0) {

            // Search bar + filter button
            HStack(spacing: 8) {
                HStack {
                    Image(systemName: "magnifyingglass").foregroundColor(.gray)
                    TextField("Search rooms…", text: $searchText)
                        .autocorrectionDisabled()
                }
                .padding(10)
                .background(Color(.systemGray6))
                .clipShape(RoundedRectangle(cornerRadius: 10))

                Button {
                    showFilters = true
                } label: {
                    Image(systemName: selectedFacilities.isEmpty && minCapacity == 1
                          ? "line.3.horizontal.decrease.circle"
                          : "line.3.horizontal.decrease.circle.fill")
                        .font(.title2)
                        .foregroundColor(selectedFacilities.isEmpty && minCapacity == 1 ? .primary : .blue)
                }
            }
            .padding(.horizontal)
            .padding(.top, 10)
            .padding(.bottom, 8)

            // Map
            Map(
                position: Binding(
                    get: { viewModel.position },
                    set: { _ in }
                )
            ) {
                ForEach(filteredRooms) { room in
                    Annotation(room.name, coordinate: room.coordinate) {
                        NavigationLink(destination: RoomDetailView(room: room)) {
                            Image(systemName: "mappin.circle.fill")
                                .resizable()
                                .frame(width: viewModel.pinSize, height: viewModel.pinSize)
                                .foregroundColor(.red)
                                .animation(.easeInOut(duration: 0.2), value: viewModel.pinSize)
                                .shadow(radius: 3)
                        }
                        .simultaneousGesture(TapGesture().onEnded {
                            addToRecent(room)
                        })
                    }
                }
            }
            .mapStyle(.standard(elevation: .flat))
            .onMapCameraChange { context in
                viewModel.region = context.region
                viewModel.clampRegion()
            }
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    viewModel.resetView()
                }
            }
            .task { await viewModel.loadRooms() }
            .frame(height: 280)
            .background(Color(.systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .shadow(radius: 5)
            .padding(.horizontal)
            .padding(.top, 5)

            // Map controls
            HStack(spacing: 10) {
                Spacer()
                HStack(spacing: 20) {
                    Button(action: { viewModel.zoomIn() }) {
                        Image(systemName: "plus.magnifyingglass")
                    }
                    Button(action: { viewModel.zoomOut() }) {
                        Image(systemName: "minus.magnifyingglass")
                    }
                    Button(action: { viewModel.resetView() }) {
                        Image(systemName: "arrow.clockwise")
                    }
                }
                .padding(.top, 10)
            }
            .padding()

            // Room list — filtered results when searching, recent otherwise
            VStack(alignment: .leading, spacing: 12) {

                Text(isFiltering ? "Results (\(filteredRooms.count))" : "Recent")
                    .font(.headline)
                    .padding(.horizontal)

                let displayRooms = isFiltering ? filteredRooms : recentRooms

                VStack(spacing: 8) {
                    if displayRooms.isEmpty {
                        Text(isFiltering ? "No rooms match your search" : "No recent rooms")
                            .foregroundColor(.gray)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding(.vertical, 20)
                    } else {
                        ForEach(displayRooms) { room in
                            NavigationLink(destination: RoomDetailView(room: room)) {
                                HStack {
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(room.name)
                                            .foregroundColor(.primary)
                                        Text("Capacity: \(room.capacity)")
                                            .font(.caption)
                                            .foregroundColor(.gray)
                                    }
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                        .foregroundColor(.gray)
                                }
                                .padding()
                                .background(Color(.systemBackground))
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                                .shadow(radius: 2)
                            }
                            .simultaneousGesture(TapGesture().onEnded {
                                addToRecent(room)
                            })
                        }
                    }
                }
                .padding()
                .background(Color(.systemGray6))
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .padding(.bottom, 10)

            Spacer()
        }
        .navigationTitle("Select Room")
        .sheet(isPresented: $showFilters) {
            FilterSheet(selectedFacilities: $selectedFacilities, minCapacity: $minCapacity)
                .presentationDetents([.medium])
        }
    }
}

struct FilterSheet: View {
    @Binding var selectedFacilities: Set<Facility>
    @Binding var minCapacity: Int
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationStack {
            Form {
                Section("Facilities") {
                    ForEach(Facility.allCases) { facility in
                        Toggle(facility.rawValue, isOn: Binding(
                            get: { selectedFacilities.contains(facility) },
                            set: { isOn in
                                if isOn { selectedFacilities.insert(facility) }
                                else { selectedFacilities.remove(facility) }
                            }
                        ))
                    }
                }

                Section("Minimum Capacity") {
                    Picker("Minimum capacity", selection: $minCapacity) {
                        Text("Any").tag(1)
                        Text("5+").tag(5)
                        Text("10+").tag(10)
                        Text("20+").tag(20)
                        Text("50+").tag(50)
                    }
                    .pickerStyle(.menu)
                }

                Section {
                    Button("Clear Filters", role: .destructive) {
                        selectedFacilities = []
                        minCapacity = 1
                    }
                }
            }
            .navigationTitle("Filter Rooms")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        RoomMapView()
    }
}
