//
//  HomeViewModel.swift
//  CU_Meet_project
//

import SwiftUI
import MapKit
import Combine

class HomeViewModel: ObservableObject {

    @Published var region: MKCoordinateRegion
    @Published var rooms: [MeetingRoom] = []

    var position: MapCameraPosition {
        .region(region)
    }

    private let defaultRegion = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 13.736717, longitude: 100.533186),
        span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
    )

    init() {
        self.region = defaultRegion
    }

    func loadRooms() async {
        do {
            var fetched = try await FirestoreService.shared.fetchRooms()
            if fetched.isEmpty {
                try await FirestoreService.shared.seedRooms(Self.seedRooms)
                fetched = Self.seedRooms
            }
            await MainActor.run { self.rooms = fetched }
        } catch {
            await MainActor.run { self.rooms = Self.seedRooms }
        }
    }

    /// Submits a star rating and returns the updated (rating, reviewCount).
    func rateRoom(
        roomID: String,
        userID: String,
        stars: Int
    ) async throws -> (Double, Int) {
        try await FirestoreService.shared.rateRoom(
            roomID: roomID,
            userID: userID,
            stars: stars
        )
        // Re-fetch just this room to get the server-computed values
        let refreshed = try await FirestoreService.shared.fetchRooms()
        if let updated = refreshed.first(where: { $0.id == roomID }) {
            await MainActor.run {
                if let idx = self.rooms.firstIndex(where: { $0.id == roomID }) {
                    self.rooms[idx] = updated
                }
            }
            return (updated.rating, updated.reviewCount)
        }
        // Fallback: optimistic estimate if re-fetch fails
        let room = rooms.first(where: { $0.id == roomID })
        let cur = room?.rating ?? 0; let cnt = room?.reviewCount ?? 0
        let newCount = cnt + 1
        let newRating = ((cur * Double(cnt)) + Double(stars)) / Double(newCount)
        return (newRating, newCount)
    }

    func zoomIn() {
        region.span.latitudeDelta /= 2
        region.span.longitudeDelta /= 2
    }

    func zoomOut() {
        region.span.latitudeDelta *= 2
        region.span.longitudeDelta *= 2
    }

    func resetView() {
        region = defaultRegion
    }

    func clampRegion() {
        let minLat = 13.734, maxLat = 13.739
        let minLon = 100.531, maxLon = 100.536
        region.center.latitude  = min(max(region.center.latitude,  minLat), maxLat)
        region.center.longitude = min(max(region.center.longitude, minLon), maxLon)
    }

    var pinSize: CGFloat {
        let zoom    = region.span.latitudeDelta
        let minZoom: CGFloat = 0.005
        let maxZoom: CGFloat = 0.03
        let clamped = max(minZoom, min(zoom, maxZoom))
        let t = (clamped - minZoom) / (maxZoom - minZoom)
        return 30 - (t * 12)  // 30 zoomed-in → 18 zoomed-out
    }

    // MARK: - Seed data (stable IDs so Firestore doesn't create duplicates)

    static let seedRooms: [MeetingRoom] = [
        MeetingRoom(
            id: "room_engineering",
            name: "Engineering Room",
            latitude: 13.7365, longitude: 100.5325,
            rating: 4.7, reviewCount: 32,
            facilities: [.projector, .whiteboard, .wifi, .aircon, .powerOutlets],
            capacity: 10, imageAssetName: "meeting_room1"
        ),
        MeetingRoom(
            id: "room_library",
            name: "Library Room",
            latitude: 13.7370, longitude: 100.5340,
            rating: 4.5, reviewCount: 21,
            facilities: [.wifi, .powerOutlets],
            capacity: 6, imageAssetName: "meeting_room2"
        ),
        MeetingRoom(
            id: "room_business",
            name: "Business Room",
            latitude: 13.7358, longitude: 100.5338,
            rating: 4.6, reviewCount: 18,
            facilities: [.tv, .videoConference, .wifi, .aircon],
            capacity: 8, imageAssetName: "meeting_room3"
        ),
        MeetingRoom(
            id: "room_lecture",
            name: "Lecture Hall",
            latitude: 13.7372, longitude: 100.5285,
            rating: 4.8, reviewCount: 45,
            facilities: [.projector, .aircon, .powerOutlets],
            capacity: 50, imageAssetName: "meeting_room4"
        ),
        MeetingRoom(
            id: "room_medical",
            name: "Medical Conference Room",
            latitude: 13.7340, longitude: 100.5355,
            rating: 4.9, reviewCount: 27,
            facilities: [.projector, .videoConference, .wifi, .aircon, .powerOutlets],
            capacity: 12, imageAssetName: "meeting_room5"
        ),
    ]
}
