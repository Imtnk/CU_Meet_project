//
//  HomeViewModel.swift
//  CU_Meet_project
//

import SwiftUI
import MapKit
import Combine

/// Owns map camera state and the list of meeting rooms shown on the home screen.
class HomeViewModel: ObservableObject {

    /// Current visible map region; drives the map camera position.
    @Published var region: MKCoordinateRegion

    /// Meeting rooms fetched from Firestore and displayed as map pins.
    @Published var rooms: [MeetingRoom] = []

    /// Map camera position derived from `region`.
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

    /// Fetches all meeting rooms from Firestore and publishes the result on the main actor.
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

    /// Halves the map span, zooming the camera in.
    func zoomIn() {
        region.span.latitudeDelta /= 2
        region.span.longitudeDelta /= 2
    }

    /// Doubles the map span, zooming the camera out.
    func zoomOut() {
        region.span.latitudeDelta *= 2
        region.span.longitudeDelta *= 2
    }

    /// Resets the map to the default CU campus region.
    func resetView() {
        region = defaultRegion
    }

    /// Constrains the map center within the CU campus bounding box.
    func clampRegion() {
        let minLat = 13.734, maxLat = 13.739
        let minLon = 100.531, maxLon = 100.536
        region.center.latitude  = min(max(region.center.latitude,  minLat), maxLat)
        region.center.longitude = min(max(region.center.longitude, minLon), maxLon)
    }

    /// Annotation pin diameter scaled inversely with zoom level (30 pt zoomed-in → 18 pt zoomed-out).
    var pinSize: CGFloat {
        let zoom    = region.span.latitudeDelta
        let minZoom: CGFloat = 0.005
        let maxZoom: CGFloat = 0.03
        let clamped = max(minZoom, min(zoom, maxZoom))
        let t = (clamped - minZoom) / (maxZoom - minZoom)
        return 30 - (t * 12)  // 30 zoomed-in → 18 zoomed-out
    }

}
