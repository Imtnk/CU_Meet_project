//
//  RoomMapView.swift
//  CU_Meet_project
//

import SwiftUI
import MapKit

/// Map and list view for discovering and searching meeting rooms.
struct RoomMapView: View {

    @StateObject private var viewModel = HomeViewModel()
    /// Rooms tapped most recently, capped at three entries.
    @State private var recentRooms: [MeetingRoom] = []
    /// Text entered in the search field.
    @State private var searchText = ""
    /// Controls presentation of the FilterSheet.
    @State private var showFilters = false
    /// Facilities that must all be present on a room to pass the filter.
    @State private var selectedFacilities: Set<Facility> = []
    /// Minimum room capacity to include in results.
    @State private var minCapacity = 1

    /// True when any search text or filter criterion is active.
    private var isFiltering: Bool {
        !searchText.isEmpty || !selectedFacilities.isEmpty || minCapacity > 1
    }

    /// Rooms from the view model that satisfy the current search text and filter criteria.
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

    /// Prepends `room` to the recent list and trims it to three entries.
    private func addToRecent(_ room: MeetingRoom) {
        recentRooms.removeAll { $0.id == room.id }
        recentRooms.insert(room, at: 0)
        if recentRooms.count > 3 { recentRooms = Array(recentRooms.prefix(3)) }
    }

    /// True when a non-default filter criterion is set (ignores free-text search).
    private var hasActiveFilter: Bool {
        !selectedFacilities.isEmpty || minCapacity > 1
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {

                // Search bar + filter button
                HStack(spacing: 10) {
                    HStack(spacing: 8) {
                        Image(systemName: "magnifyingglass").foregroundColor(.mutedGray)
                        TextField("Search rooms…", text: $searchText)
                            .autocorrectionDisabled()
                    }
                    .padding(12)
                    .background(Color.cardBackground)
                    .clipShape(RoundedRectangle(cornerRadius: AppTheme.buttonRadius))
                    .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)

                    Button { showFilters = true } label: {
                        Image(systemName: hasActiveFilter
                              ? "line.3.horizontal.decrease.circle.fill"
                              : "line.3.horizontal.decrease.circle")
                            .font(.title2)
                            .foregroundColor(hasActiveFilter ? .brandPink : .mutedGray)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)

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
                                ZStack {
                                    Circle()
                                        .fill(Color.brandPink)
                                        .frame(width: viewModel.pinSize, height: viewModel.pinSize)
                                        .shadow(color: .brandPink.opacity(0.4), radius: 4)
                                    Image(systemName: "mappin")
                                        .font(.system(size: viewModel.pinSize * 0.45))
                                        .foregroundColor(.white)
                                }
                                .animation(.easeInOut(duration: 0.2), value: viewModel.pinSize)
                            }
                            .simultaneousGesture(TapGesture().onEnded { addToRecent(room) })
                        }
                    }
                }
                .mapStyle(.standard(elevation: .flat))
                .onMapCameraChange { context in
                    viewModel.region = context.region
                    viewModel.clampRegion()
                }
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { viewModel.resetView() }
                }
                .task { await viewModel.loadRooms() }
                .frame(height: 280)
                .clipShape(RoundedRectangle(cornerRadius: AppTheme.cardRadius))
                .shadow(color: .black.opacity(0.08), radius: 8, x: 0, y: 4)
                .padding(.horizontal, 16)
                .overlay(alignment: .bottomTrailing) {
                    mapControls.padding(.trailing, 28).padding(.bottom, 16)
                }

                // Room list
                VStack(alignment: .leading, spacing: 10) {
                    Text(isFiltering ? "Results (\(filteredRooms.count))" : "Recent")
                        .font(.headline).fontWeight(.bold).foregroundColor(.charcoal)
                        .padding(.horizontal, 16)

                    let displayRooms = isFiltering ? filteredRooms : recentRooms

                    if displayRooms.isEmpty {
                        Text(isFiltering ? "No rooms match your search" : "No recent rooms")
                            .font(.subheadline).foregroundColor(.mutedGray)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding(.vertical, 24)
                    } else {
                        ForEach(displayRooms) { room in
                            NavigationLink(destination: RoomDetailView(room: room)) {
                                roomRow(room)
                            }
                            .buttonStyle(.plain)
                            .simultaneousGesture(TapGesture().onEnded { addToRecent(room) })
                            .padding(.horizontal, 16)
                        }
                    }
                }

                Spacer(minLength: 20)
            }
        }
        .background(Color.warmGray.ignoresSafeArea())
        .navigationTitle("Find a Room")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showFilters) {
            FilterSheet(selectedFacilities: $selectedFacilities, minCapacity: $minCapacity)
                .presentationDetents([.medium])
        }
    }

    // MARK: - Room row card
    /// Row card showing the room thumbnail, name, capacity, and rating.
    @ViewBuilder
    private func roomRow(_ room: MeetingRoom) -> some View {
        HStack(spacing: 12) {
            Rectangle()
                .fill(Color.brandPinkDark)
                .overlay(Image(room.imageAssetName).resizable().scaledToFill())
                .frame(width: 64, height: 64)
                .clipShape(RoundedRectangle(cornerRadius: 10))

            VStack(alignment: .leading, spacing: 4) {
                Text(room.name)
                    .font(.subheadline).fontWeight(.semibold).foregroundColor(.charcoal)
                Text("Up to \(room.capacity) people")
                    .font(.caption).foregroundColor(.mutedGray)
                HStack(spacing: 4) {
                    Image(systemName: "star.fill").font(.caption2).foregroundColor(.brandPink)
                    Text(String(format: "%.1f", room.rating))
                        .font(.caption).fontWeight(.medium).foregroundColor(.charcoal)
                }
            }

            Spacer()
            Image(systemName: "chevron.right").font(.caption).foregroundColor(.mutedGray)
        }
        .padding(14)
        .background(Color.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.cardRadius))
        .shadow(color: .black.opacity(0.05), radius: 6, x: 0, y: 2)
    }

    // MARK: - Map controls
    /// Zoom-in, zoom-out, and reset-position buttons overlaid on the map.
    private var mapControls: some View {
        VStack(spacing: 8) {
            ForEach([
                ("plus.magnifyingglass", { viewModel.zoomIn() }),
                ("minus.magnifyingglass", { viewModel.zoomOut() }),
                ("arrow.clockwise", { viewModel.resetView() })
            ] as [(String, () -> Void)], id: \.0) { icon, action in
                Button(action: action) {
                    Image(systemName: icon)
                        .font(.subheadline).fontWeight(.semibold)
                        .foregroundColor(.brandPink)
                        .frame(width: 36, height: 36)
                        .background(Color.cardBackground)
                        .clipShape(Circle())
                        .shadow(color: .black.opacity(0.1), radius: 4)
                }

            }
        }
    }
}

// MARK: - Filter Sheet
/// Modal sheet for filtering rooms by required facilities and minimum capacity.
struct FilterSheet: View {
    /// Facilities that must all be present on a room to match.
    @Binding var selectedFacilities: Set<Facility>
    /// Minimum room capacity required to match.
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
                        .tint(.brandPink)
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
                        .foregroundColor(.brandPink)
                }
            }
        }
    }
}

#Preview {
    NavigationStack { RoomMapView() }
}
