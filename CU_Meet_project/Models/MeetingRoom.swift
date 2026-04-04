//
//  MeetingRoom.swift
//  CU_Meet_project
//
//  Created by Imtnk on 3/4/2569 BE.
//

import Foundation
import CoreLocation

struct MeetingRoom: Identifiable {
    let id = UUID()
    let name: String
    let coordinate: CLLocationCoordinate2D
}

let rooms: [MeetingRoom] = [
    MeetingRoom(
        name: "Engineering Room",
        coordinate: CLLocationCoordinate2D(latitude: 13.7365, longitude: 100.5325)
    ),
    MeetingRoom(
        name: "Library Room",
        coordinate: CLLocationCoordinate2D(latitude: 13.7370, longitude: 100.5340)
    ),
    MeetingRoom(
        name: "Business Room",
        coordinate: CLLocationCoordinate2D(latitude: 13.7358, longitude: 100.5338)
    ),
    MeetingRoom(
        name: "Lecture Hall",
        coordinate: CLLocationCoordinate2D(latitude: 13.7372, longitude: 100.5285)
    ),
    MeetingRoom(
        name: "Medical Conference Room",
        coordinate: CLLocationCoordinate2D(latitude: 13.7340, longitude: 100.5355)
    )
]
