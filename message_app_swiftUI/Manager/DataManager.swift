//
//  DataManager.swift
//  message_app_swiftUI
//
//  Created by Aysema Çam on 30.07.2024.
//

import Foundation

class DataManager {
    static let shared = DataManager()
    
    private let userDefaults = UserDefaults.standard
    private let usersKey = "users"

    private init() {}
    
    func saveUserChat(for user: User) {
        var users = fetchUsers()
        if let index = users.firstIndex(where: { $0.id == user.id }) {
            users[index].userChat = user.userChat
            print("Saving user chat for user: \(user.username)")
        } else {
            print("User not found in the list: \(user.username)")
        }
        saveUsers(users)
    }
    
    func fetchUsers() -> [User] {
        guard let data = userDefaults.data(forKey: usersKey),
              let users = try? JSONDecoder().decode([User].self, from: data) else {
            print("No users found in UserDefaults.")
            return []
        }
        print("Fetched users from UserDefaults.")
        return users
    }
    
    func fetchUser(byID id: UUID) -> User? {
        return fetchUsers().first(where: { $0.id == id })
    }
    
     func saveUsers(_ users: [User]) {
        guard let data = try? JSONEncoder().encode(users) else {
            print("Failed to encode users.")
            return
        }
        userDefaults.set(data, forKey: usersKey)
        print("Users saved to UserDefaults.")
    }
}
