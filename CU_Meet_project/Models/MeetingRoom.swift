//
//  MeetingRoom.swift
//  CU_Meet_project
//

import Foundation
import CoreLocation
import MapKit

/// Metadata for a bookable meeting room, including location and facilities.
struct MeetingRoom: Identifiable, Codable, Equatable {
    let id: String
    let name: String
    let latitude: Double
    let longitude: Double
    /// Aggregate star rating from all reviews.
    let rating: Double
    /// Number of reviews that contribute to `rating`.
    let reviewCount: Int
    let facilities: [Facility]
    /// Maximum number of occupants.
    let capacity: Int
    /// Asset catalog name for the room's cover image.
    let imageAssetName: String

    /// Map of Firebase UID to the star rating that user submitted.
    var userRatings: [String: Int]?
    /// Sum of all user-submitted star ratings.
    var userRatingTotal: Int?
    /// Number of user-submitted ratings.
    var userRatingCount: Int?

    /// Map coordinate derived from `latitude` and `longitude`.
    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(
            latitude: latitude,
            longitude: longitude
        )
    }
}
