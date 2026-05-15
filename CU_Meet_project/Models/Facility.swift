//
//  Facility.swift
//  CU_Meet_project
//
//  Created by Imtnk on 15/4/2569 BE.
//


/// Available amenities that a meeting room may provide.
enum Facility: String, CaseIterable, Identifiable, Codable {

    case projector       = "Projector"
    case whiteboard      = "Whiteboard"
    case tv              = "TV Screen"
    case aircon          = "Air Conditioning"
    case videoConference = "Video Conferencing"
    case powerOutlets    = "Power Outlets"
    case wifi            = "Wi-Fi"

    /// Stable identifier matching the display string raw value.
    var id: String { rawValue }
}
