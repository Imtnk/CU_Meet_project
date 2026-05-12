//
//  MeetingRoom.swift
//  CU_Meet_project
//
//  Created by Imtnk on 3/4/2569 BE.
//

import Foundation
import CoreLocation
import MapKit

struct MeetingRoom: Identifiable, Codable, Equatable {
    let id: String
    let name: String
    let latitude: Double
    let longitude: Double
    let rating: Double
    let reviewCount: Int
    let facilities: [Facility]
    let capacity: Int
    let imageAssetName: String

    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}

let rooms: [MeetingRoom] = [
    MeetingRoom(
        id: UUID().uuidString,
        name: "Engineering Room",
        latitude: 13.7365,
        longitude: 100.5325,
        rating: 4.7,
        reviewCount: 32,
        facilities: [.projector, .whiteboard, .wifi, .aircon, .powerOutlets],
        capacity: 10,
        imageAssetName: "meeting_room1"
    ),
    MeetingRoom(
        id: UUID().uuidString,
        name: "Library Room",
        latitude: 13.7370,
        longitude: 100.5340,
        rating: 4.5,
        reviewCount: 21,
        facilities: [.wifi, .powerOutlets],
        capacity: 6,
        imageAssetName: "meeting_room1"
    ),
    MeetingRoom(
        id: UUID().uuidString,
        name: "Business Room",
        latitude: 13.7358,
        longitude: 100.5338,
        rating: 4.6,
        reviewCount: 18,
        facilities: [.tv, .videoConference, .wifi, .aircon],
        capacity: 8,
        imageAssetName: "meeting_room1"
    ),
    MeetingRoom(
        id: UUID().uuidString,
        name: "Lecture Hall",
        latitude: 13.7372,
        longitude: 100.5285,
        rating: 4.8,
        reviewCount: 45,
        facilities: [.projector, .aircon, .powerOutlets],
        capacity: 50,
        imageAssetName: "meeting_room1"
    ),
    MeetingRoom(
        id: UUID().uuidString,
        name: "Medical Conference Room",
        latitude: 13.7340,
        longitude: 100.5355,
        rating: 4.9,
        reviewCount: 27,
        facilities: [.projector, .videoConference, .wifi, .aircon, .powerOutlets],
        capacity: 12,
        imageAssetName: "meeting_room1"
    )
]
