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

    func generateUniqueJoinCode() async throws -> String {
        var code = ""
        var isUnique = false
        var attempts = 0
        let maxAttempts = 10

        while !isUnique && attempts < maxAttempts {
            code = String(Int.random(in: 100000...999999))
            let existing = try await fetchGroup(byJoinCode: code)
            isUnique = existing == nil
            attempts += 1
        }

        guard isUnique else {
            throw AppError.uniqueCodeGenerationFailed
        }
        return code
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
        let bookingDocs = try await db.collection(C.bookings)
            .whereField("groupID", isEqualTo: id)
            .getDocuments()
        let batch = db.batch()
        for doc in bookingDocs.documents {
            batch.deleteDocument(doc.reference)
        }
        batch.deleteDocument(db.collection(C.groups).document(id))
        try await batch.commit()
    }

    // MARK: - Bookings

    /// Real-time listener for all bookings.
    func listenToBookings(onChange: @escaping ([Booking]) -> Void) -> ListenerRegistration {
        db.collection(C.bookings)
            .addSnapshotListener { snapshot, error in
                if let error {
                    print("BookingStore listener error: \(error)")
                    return
                }
                guard let snapshot else { return }
                let decoded = snapshot.documents.compactMap { try? $0.data(as: Booking.self) }
                onChange(decoded)
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

    // MARK: - Mock Data (DEBUG only)

    func seedMockData(currentUserID: String) async throws {
        let encoder = Firestore.Encoder()
        let cal = Calendar.current
        let today = cal.startOfDay(for: Date())

        // Groups — written in a separate batch (rules allow any authenticated user)
        // Current user is added to Alpha so their bookings appear on Home.
        // Mock user IDs are kept as memberIDs for structural realism; no user
        // documents are written for them since rules restrict writes to own UID.
        let alphaMembers = ["mock_user_alice", "mock_user_bob", currentUserID]
            .filter { !$0.isEmpty }
        let mockGroups: [Group] = [
            Group(id: "mock_group_alpha", name: "Alpha Team", joinCode: "000001", memberIDs: alphaMembers),
            Group(id: "mock_group_beta",  name: "Beta Team",  joinCode: "000002", memberIDs: ["mock_user_bob", "mock_user_charlie"]),
        ]
        let groupBatch = db.batch()
        for group in mockGroups {
            let ref = db.collection(C.groups).document(group.id)
            groupBatch.setData(try encoder.encode(group), forDocument: ref)
        }
        try await groupBatch.commit()

        // Bookings — future dates so they surface in upcomingBookings()
        let mockBookings: [Booking] = [
            Booking(id: "mock_booking_1", roomID: "room_engineering", roomName: "Engineering Room",
                    groupID: "mock_group_alpha", date: cal.date(byAdding: .day, value: 1, to: today)!,
                    timeSlot: "09:00 - 10:00"),
            Booking(id: "mock_booking_2", roomID: "room_library",     roomName: "Library Room",
                    groupID: "mock_group_beta",  date: cal.date(byAdding: .day, value: 2, to: today)!,
                    timeSlot: "14:00 - 15:00"),
            Booking(id: "mock_booking_3", roomID: "room_business",    roomName: "Business Room",
                    groupID: "mock_group_alpha", date: cal.date(byAdding: .day, value: 3, to: today)!,
                    timeSlot: "11:00 - 12:00"),
        ]
        let bookingBatch = db.batch()
        for booking in mockBookings {
            let ref = db.collection(C.bookings).document(booking.id)
            bookingBatch.setData(try encoder.encode(booking), forDocument: ref)
        }
        try await bookingBatch.commit()
    }
}
