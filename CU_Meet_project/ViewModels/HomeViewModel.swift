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
            let fetched = try await FirestoreService.shared.fetchRooms()
            await MainActor.run { self.rooms = fetched }
        } catch {
            print("Failed to load rooms:", error)
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

}
