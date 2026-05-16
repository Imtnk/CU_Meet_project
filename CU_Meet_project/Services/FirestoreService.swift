//
//  FirestoreService.swift
//  CU_Meet_project
//

import Foundation
import FirebaseFirestore

/// Singleton gateway for all Firestore reads and writes.
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

    /// Fetches all meeting rooms.
    func fetchRooms() async throws -> [MeetingRoom] {
        let snapshot = try await db.collection(C.rooms).getDocuments()
        return try snapshot.documents.map { try $0.data(as: MeetingRoom.self) }
    }

    // MARK: - Users

    /// Creates or merges the user document; existing fields absent from `user` are preserved.
    func upsertUser(_ user: AppUser) async throws {
        let ref = db.collection(C.users).document(user.id)
        let data = try Firestore.Encoder().encode(user)
        try await ref.setData(data, merge: true)
    }

    /// Returns nil when the user document does not exist.
    func fetchUser(userID: String) async throws -> AppUser? {
        let doc = try await db.collection(C.users).document(userID).getDocument()
        guard doc.exists else { return nil }
        return try? doc.data(as: AppUser.self)
    }

    /// Returns every user document in the collection.
    func fetchAllUsers() async throws -> [AppUser] {
        let snapshot = try await db.collection(C.users).getDocuments()
        return try snapshot.documents.map {
            try $0.data(as: AppUser.self)
        }
    }

    /// Performs a partial update; fields not present in `fields` are left unchanged.
    func updateUserFields(userID: String, fields: [String: Any]) async throws {
        try await db.collection(C.users).document(userID).setData(fields, merge: true)
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

    /// Returns the first group whose join code matches `code`, or nil if none is found.
    func fetchGroup(byJoinCode code: String) async throws -> Group? {
        let snapshot = try await db.collection(C.groups)
            .whereField("joinCode", isEqualTo: code)
            .limit(to: 1)
            .getDocuments()
        guard let doc = snapshot.documents.first else { return nil }
        return try doc.data(as: Group.self)
    }

    /// Generates a random 6-digit code that does not collide with any existing group's join code.
    /// - Throws: `AppError.uniqueCodeGenerationFailed` after 10 unsuccessful attempts.
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

    /// Writes a new group document; the group's `id` is used as the Firestore document key.
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

    /// Updates the `name` field of an existing group document.
    func updateGroupName(id: String, name: String) async throws {
        try await db.collection(C.groups)
            .document(id)
            .updateData(["name": name])
    }

    /// Deletes the group and all its associated bookings atomically via a batched write.
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

    /// Writes a new booking document; the booking's `id` is used as the Firestore document key.
    func addBooking(_ booking: Booking) async throws {
        let ref = db.collection(C.bookings).document(booking.id)
        let data = try Firestore.Encoder().encode(booking)
        try await ref.setData(data)
    }

    /// Updates only the `status` field of an existing booking document.
    func updateBookingStatus(id: String, status: BookingStatus) async throws {
        try await db.collection(C.bookings)
            .document(id)
            .updateData(["status": status.rawValue])
    }

    /// Updates the `notes` field of an existing booking document.
    func updateBookingNotes(id: String, notes: String?) async throws {
        try await db.collection(C.bookings)
            .document(id)
            .updateData(["notes": notes as Any])
    }

    /// Atomically appends a user rating using a weighted-average transaction.
    func rateRoom(
        roomID: String,
        userID: String,
        stars: Int
    ) async throws {

        let ref = db.collection(C.rooms).document(roomID)

        let _ = try await db.runTransaction { transaction, errorPointer in

            let snapshot: DocumentSnapshot

            do {
                snapshot = try transaction.getDocument(ref)
            } catch let err as NSError {
                errorPointer?.pointee = err
                return nil
            }

            let currentRating =
                snapshot.data()?["rating"] as? Double ?? 0

            let currentReviewCount =
                snapshot.data()?["reviewCount"] as? Int ?? 0

            let currentUserRatingTotal =
                snapshot.data()?["userRatingTotal"] as? Int ?? 0

            let currentUserRatingCount =
                snapshot.data()?["userRatingCount"] as? Int ?? 0

            let rawRatings =
                snapshot.data()?["userRatings"] as? [String: Any] ?? [:]

            var userRatings: [String: Int] = [:]

            for (key, value) in rawRatings {
                if let intValue = value as? Int {
                    userRatings[key] = intValue
                }
            }

            let oldRating = userRatings[userID]

            // Remove old rating contribution
            var updatedUserRatingTotal = currentUserRatingTotal
            var updatedUserRatingCount = currentUserRatingCount

            if let oldRating {
                updatedUserRatingTotal -= oldRating
            } else {
                updatedUserRatingCount += 1
            }

            // Add new rating
            updatedUserRatingTotal += stars

            userRatings[userID] = stars

            // Recover original mocked values
            let baseReviewCount =
                currentReviewCount - currentUserRatingCount

            let baseRatingTotal =
                (currentRating * Double(currentReviewCount))
                - Double(currentUserRatingTotal)

            // Recalculate final combined values
            let finalReviewCount =
                baseReviewCount + updatedUserRatingCount

            let finalRatingTotal =
                baseRatingTotal + Double(updatedUserRatingTotal)

            let finalRating =
                finalRatingTotal / Double(max(finalReviewCount, 1))

            transaction.updateData([
                "userRatings": userRatings,
                "userRatingTotal": updatedUserRatingTotal,
                "userRatingCount": updatedUserRatingCount,
                "rating": finalRating,
                "reviewCount": finalReviewCount
            ], forDocument: ref)

            return nil
        }
    }

}
