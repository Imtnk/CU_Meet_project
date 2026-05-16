//
//  GroupsView.swift
//  CU_Meet_project
//
//  Created by Imtnk on 3/4/2569 BE.
//

import SwiftUI

/// Screen listing the current user's groups with options to create or join one.
struct GroupsView: View {

    /// Provides group data and real-time listener.
    @EnvironmentObject var groupStore: GroupStore
    /// Provides the current user's ID for group membership filtering.
    @EnvironmentObject var authManager: AuthManager
    /// Controls presentation of the Create Group sheet.
    @State private var showCreate = false
    /// Controls presentation of the Join Group sheet.
    @State private var showJoin = false
    /// Controls visibility of the create/join confirmation dialog.
    @State private var showActionSheet = false

    /// Groups the current user belongs to.
    private var myGroups: [Group] {
        groupStore.myGroups(currentUserID: authManager.currentUserID)
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Header
                    VStack(alignment: .leading, spacing: 4) {
                        Text("My Groups")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.charcoal)
                        Text("Collaborate with your team")
                            .font(.subheadline)
                            .foregroundColor(.mutedGray)
                    }
                    .padding(.horizontal, 20)

                    LazyVStack(spacing: 12) {
                        if groupStore.isLoading {
                        ProgressView("Loading groups…")
                            .frame(maxWidth: .infinity)
                            .padding(.top, 40)
                    } else if myGroups.isEmpty {
                        VStack(spacing: 16) {
                            Image(systemName: "person.3.fill")
                                .font(.system(size: 52))
                                .foregroundColor(.mutedGray)
                            Text("No groups yet")
                                .font(.title3)
                                .fontWeight(.semibold)
                                .foregroundColor(.charcoal)
                            Text("Tap + to create or join a group")
                                .font(.subheadline)
                                .foregroundColor(.mutedGray)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.top, 60)
                    } else {
                        ForEach(myGroups) { group in
                            NavigationLink(destination: GroupDetailView(group: group)) {
                                GroupCard(group: group)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 20)
                }
            }
            .background(Color.warmGray.ignoresSafeArea())
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showActionSheet = true
                    } label: {
                        Image(systemName: "plus")
                            .fontWeight(.semibold)
                            .foregroundColor(.brandPink)
                    }
                }
            }
            .confirmationDialog("Group Options", isPresented: $showActionSheet) {
                Button("Create Group") { showCreate = true }
                Button("Join Group")   { showJoin   = true }
                Button("Cancel", role: .cancel) {}
            }
            .onAppear {
                groupStore.startListening(for: authManager.currentUserID ?? "")
            }
            .onChange(of: authManager.currentUserID) { _, newID in
                groupStore.startListening(for: newID ?? "")
            }
            .sheet(isPresented: $showCreate) {
                CreateGroupView()
                    .environmentObject(groupStore)
                    .presentationDetents([.medium])
                    .presentationDragIndicator(.visible)
            }
            .sheet(isPresented: $showJoin) {
                JoinGroupView()
                    .environmentObject(groupStore)
                    .presentationDetents([.medium])
                    .presentationDragIndicator(.visible)
            }
        }
    }
}
