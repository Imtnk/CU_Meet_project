//
//  MeetingRoom.swift
//  CU_Meet_project
//
//  Created by Imtnk on 3/4/2569 BE.
//

import Foundation
import CoreLocation
import MapKit

struct MeetingRoom: Identifiable {
    let id = UUID()
    let name: String
    let coordinate: CLLocationCoordinate2D
    
    let rating: Double
    let reviewCount: Int
    let facilities: [Facility]
    let capacity: Int
}

let rooms: [MeetingRoom] = [
    MeetingRoom(
        name: "Engineering Room",
        coordinate: CLLocationCoordinate2D(latitude: 13.7365, longitude: 100.5325),
        rating: 4.7,
        reviewCount: 32,
        facilities: [.projector, .whiteboard, .wifi, .aircon, .powerOutlets],
        capacity: 10
    ),
    MeetingRoom(
        name: "Library Room",
        coordinate: CLLocationCoordinate2D(latitude: 13.7370, longitude: 100.5340),
        rating: 4.5,
        reviewCount: 21,
        facilities: [.wifi, .powerOutlets],
        capacity: 6
    ),
    MeetingRoom(
        name: "Business Room",
        coordinate: CLLocationCoordinate2D(latitude: 13.7358, longitude: 100.5338),
        rating: 4.6,
        reviewCount: 18,
        facilities: [.tv, .videoConference, .wifi, .aircon],
        capacity: 8
    ),
    MeetingRoom(
        name: "Lecture Hall",
        coordinate: CLLocationCoordinate2D(latitude: 13.7372, longitude: 100.5285),
        rating: 4.8,
        reviewCount: 45,
        facilities: [.projector, .aircon, .powerOutlets],
        capacity: 50
    ),
    MeetingRoom(
        name: "Medical Conference Room",
        coordinate: CLLocationCoordinate2D(latitude: 13.7340, longitude: 100.5355),
        rating: 4.9,
        reviewCount: 27,
        facilities: [.projector, .videoConference, .wifi, .aircon, .powerOutlets],
        capacity: 12
    )
]
