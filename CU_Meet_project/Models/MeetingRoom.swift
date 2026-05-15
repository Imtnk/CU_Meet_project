//
//  MeetingRoom.swift
//  CU_Meet_project
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

    var userRatings: [String: Int]?
    var userRatingTotal: Int?
    var userRatingCount: Int?

    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(
            latitude: latitude,
            longitude: longitude
        )
    }
}
