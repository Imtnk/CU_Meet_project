//
//  FirestoreService.swift
//  CU_Meet_project
//

import Foundation
import FirebaseFirestore

final class FirestoreService {

    static let shared = FirestoreService()
    private let db = Firestore.firestore()

    private enum C {
        static let rooms    = "rooms"
        static let groups   = "groups"
        static let bookings = "bookings"
        static let users    = "users"
    }

    // MARK: - Rooms

    func fetchRooms() async throws -> [MeetingRoom] {
        let snapshot = try await db.collection(C.rooms).getDocuments()
        return try snapshot.documents.map { try $0.data(as: MeetingRoom.self) }
    }

    /// One-time seed — writes the hardcoded rooms array to Firestore as a batch.
    func seedRooms(_ rooms: [MeetingRoom]) async throws {
        let batch = db.batch()
        let encoder = Firestore.Encoder()
        for room in rooms {
            let ref = db.collection(C.rooms).document(room.id)
            let data = try encoder.encode(room)
            batch.setData(data, forDocument: ref)
        }
        try await batch.commit()
    }

    // MARK: - Users

    func upsertUser(_ user: AppUser) async throws {
        let ref = db.collection(C.users).document(user.id)
        let data = try Firestore.Encoder().encode(user)
        try await ref.setData(data, merge: true)
    }

    // MARK: - Groups

    /// Real-time listener scoped to groups where the user is a member.
    func listenToGroups(for userID: String,
                        onChange: @escaping ([Group]) -> Void) -> ListenerRegistration {
        db.collection(C.groups)
            .whereField("memberIDs", arrayContains: userID)
            .addSnapshotListener { snapshot, _ in
                guard let docs = snapshot?.documents else { return }
                onChange(docs.compactMap { try? $0.data(as: Group.self) })
            }
    }

    func fetchGroup(byJoinCode code: String) async throws -> Group? {
        let snapshot = try await db.collection(C.groups)
            .whereField("joinCode", isEqualTo: code)
            .limit(to: 1)
            .getDocuments()
        guard let doc = snapshot.documents.first else { return nil }
        return try doc.data(as: Group.self)
    }

    func createGroup(_ group: Group) async throws {
        let ref = db.collection(C.groups).document(group.id)
        let data = try Firestore.Encoder().encode(group)
        try await ref.setData(data)
    }

    /// Overwrites the memberIDs array (used for join / leave).
    func updateGroupMembers(groupID: String, memberIDs: [String]) async throws {
        try await db.collection(C.groups)
            .document(groupID)
            .updateData(["memberIDs": memberIDs])
    }

    func deleteGroup(id: String) async throws {
        try await db.collection(C.groups).document(id).delete()
    }

    // MARK: - Bookings

    /// Real-time listener for all bookings.
    func listenToBookings(onChange: @escaping ([Booking]) -> Void) -> ListenerRegistration {
        db.collection(C.bookings)
            .addSnapshotListener { snapshot, _ in
                guard let docs = snapshot?.documents else { return }
                onChange(docs.compactMap { try? $0.data(as: Booking.self) })
            }
    }

    func addBooking(_ booking: Booking) async throws {
        let ref = db.collection(C.bookings).document(booking.id)
        let data = try Firestore.Encoder().encode(booking)
        try await ref.setData(data)
    }

    func updateBookingStatus(id: String, status: BookingStatus) async throws {
        try await db.collection(C.bookings)
            .document(id)
            .updateData(["status": status.rawValue])
    }
}
