//
//  HomeViewModel.swift
//  CU_Meet_project
//
//  Created by Imtnk on 3/4/2569 BE.
//
import SwiftUI
import MapKit
import Combine

class HomeViewModel: ObservableObject {
    
    @Published var region: MKCoordinateRegion
    
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
        let minLat = 13.734
        let maxLat = 13.739
        let minLon = 100.531
        let maxLon = 100.536
        
        region.center.latitude = min(max(region.center.latitude, minLat), maxLat)
        region.center.longitude = min(max(region.center.longitude, minLon), maxLon)
    }
    
    var pinSize: CGFloat {
        let zoom = region.span.latitudeDelta
        
        let minZoom: CGFloat = 0.005   // most zoomed in
        let maxZoom: CGFloat = 0.03    // most zoomed out
        
        let clamped = max(minZoom, min(zoom, maxZoom))
        
        // Normalize (0 → zoomed in, 1 → zoomed out)
        let t = (clamped - minZoom) / (maxZoom - minZoom)
        
        let minSize: CGFloat = 18   // when zoomed OUT
        let maxSize: CGFloat = 30   // when zoomed IN
        
        return maxSize - (t * (maxSize - minSize))
    }
}
