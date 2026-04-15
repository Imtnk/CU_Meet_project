//
//  Facility.swift
//  CU_Meet_project
//
//  Created by Imtnk on 15/4/2569 BE.
//


enum Facility: String, CaseIterable, Identifiable {
    
    case projector = "Projector"
    case whiteboard = "Whiteboard"
    case tv = "TV Screen"
    case aircon = "Air Conditioning"
    case videoConference = "Video Conferencing"
    case powerOutlets = "Power Outlets"
    case wifi = "Wi-Fi"
    
    var id: String { rawValue }
}