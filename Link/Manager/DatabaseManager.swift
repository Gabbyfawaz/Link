//
//  DatabaseManager.swift
//  Link
//
//  Created by Gabriella Fawaz on 2021/07/22.
//

import Foundation
import FirebaseFirestore
import FirebaseDatabase
import MessageKit
import CoreLocation



/// Object to manage database interactions
final class DatabaseManager {
    /// Shared instance
    static let shared = DatabaseManager()

    /// Private constructor
    private init() {}

    /// Database referenec
    private let database = Firestore.firestore()
    
    private let realDatabase =  Database.database().reference()

    ///Database safe Email
    
    static func safeEmail(emailAddress: String) -> String {
        var safeEmail = emailAddress.replacingOccurrences(of: ".", with: "-")
        safeEmail = safeEmail.replacingOccurrences(of: "@", with: "-")
        return safeEmail
    }
    
    
    
//    
//    public func createStories(newStory: LinkStory, completion: @escaping (Bool) -> Void) {
//        guard let username = UserDefaults.standard.string(forKey: "username") else {
//            completion(false)
//            return
//        }
//
//        let reference = database.document("users/\(username)/stories/\(newStory.id)")
//        guard let data = newStory.asDictionary() else {
//            completion(false)
//            return
//        }
//        reference.setData(data) { error in
//            completion(error == nil)
//        }
//    }
//    
//    
//    public func getAllStories(
//        for otherUsername: String,
//        completion: @escaping (Result<[LinkStory], Error>) -> Void
//    ) {
//        let ref = database.collection("users")
//            .document(otherUsername)
//            .collection("stories")
//        ref.getDocuments { snapshot, error in
//            guard let stories = snapshot?.documents.compactMap({
//                LinkStory(with: $0.data())
//            }),
//            error == nil else {
//                return
//            }
//            completion(.success(stories))
//        }
//    }
//    
    
    public func savePins(pinDrop: Pin, completion: @escaping (Bool) -> Void) {
 
        let reference = database.document("pins/\(pinDrop)")
        guard let data = pinDrop.asDictionary() else {
            completion(false)
            return
        }
        reference.setData(data) { error in
            completion(error == nil)
        }
    
        
    }
    
    
    public func addUserToBommingPin(locationTitle: String,completion: @escaping (Bool) -> Void ) {
        guard let username = UserDefaults.standard.string(forKey: "username") else {
            return
        }
        let user = SearchUser(name: username)
        let ref = database.collection("pins").document(locationTitle)
        ref.getDocument { snapshot, error in
                guard let data = snapshot?.data(),
                      error == nil else {
                    completion(false)
                    return
                }
            guard var pin = Pin(with: data) else {
                return
            }
            
            
            if !(pin.people.contains(user)) {
                pin.people.append(user)
                guard let data = pin.asDictionary() else {
                    completion(false)
                    return
                }
                ref.setData(data) { error in
                    completion(error == nil)
                }
            } else {
                completion(false)
            }
            
            
            
          

        }
       
    }
    public func getAllPins(
        completion: @escaping (Result<[Pin], Error>) -> Void
    ) {
        
    
        let ref = database.collection("pins")
        ref.getDocuments { snapshot, error in
            guard let pins = snapshot?.documents.compactMap({
                Pin(with: $0.data())
            }),
            error == nil else {
                return
            }
            
            completion(.success(pins))
        }

        
        
    }
    
    
    public func createLink(newLink: LinkModel, completion: @escaping (Bool) -> Void) {
        guard let username = UserDefaults.standard.string(forKey: "username") else {
            completion(false)
            return
        }

        let reference = database.document("users/\(username)/links/\(newLink.id)")
        guard let data = newLink.asDictionary() else {
            completion(false)
            return
        }
        reference.setData(data) { error in
            completion(error == nil)
        }
    }
    
    /// Get all Links
    
    public func getAllLinks(
        for otherUsername: String,
        completion: @escaping (Result<[LinkModel], Error>) -> Void
    ) {
      
        let ref = database.collection("users")
            .document(otherUsername)
            .collection("links")
   
        ref.getDocuments { snapshot, error in
            guard let links = snapshot?.documents.compactMap({
                LinkModel(with: $0.data())
            }).sorted(by: {
                return $0.postedDate > $1.postedDate
            }),
            error == nil else {
                return
            }
            print("The links are: \(links)")
            completion(.success(links))
        }
    }
    
   
    /// Link for individual post

    public func getLink(
        with identifer: String,
        from username: String,
        completion: @escaping (LinkModel?) -> Void
    ) {
        let ref = database.collection("users")
            .document(username)
            .collection("links")
            .document(identifer)
        ref.getDocument { snapshot, error in
            guard let data = snapshot?.data(),
                  error == nil else {
                completion(nil)
                return
            }
            completion(LinkModel(with: data))
        }
    }
    
   
    
    public func createQuickLink(quickLink: QuickLink, completion: @escaping(Bool) -> Void) {

        let ref = database.collection("users")
            .document(quickLink.username)
            .collection("QuickLinks")
            .document("\(quickLink.id)")
        
        guard let data = quickLink.asDictionary() else {
            completion(false)
            return
        }
        ref.setData(data) { error in
            completion(error == nil)
        }
    }
    
    public func getQuickLink(
        with identifer: String,
        from username: String,
        completion: @escaping (QuickLink?) -> Void
    ) {
        let ref = database.collection("users")
            .document(username)
            .collection("QuickLinks")
            .document(identifer)
        ref.getDocument { snapshot, error in
            guard let data = snapshot?.data(),
                  error == nil else {
                completion(nil)
                return
            }
            completion(QuickLink(with: data))
        }
    }
  
    
    public func getAllQuickLinks(
        for otherUsername: String,
        completion: @escaping (Result<[QuickLink], Error>) -> Void
    ) {
        // define the path
        
        let ref = database.collection("users")
            .document(otherUsername)
            .collection("QuickLinks")
   
        ref.getDocuments { snapshot, error in
            guard let quickLinks = snapshot?.documents.compactMap({
                QuickLink(with: $0.data())
//                QuickLink(with: $0.data())
            }).sorted(by: {
                return $0.date > $1.date
            }),
            error == nil else {
                return
            }
            print("The links are: \(quickLinks)")
            completion(.success(quickLinks))
        }
    }
    
    
    public func createBoomingPin(pin: Pin, completion: @escaping(Bool) -> Void) {
        guard let data = pin.asDictionary() else {
            completion(false)
            return
        }
        let ref = database.collection("pins").document(pin.locationString)
       
        ref.setData(data) { error in
            completion(error == nil)
        }
        
    }

    
    public func getBoomingPin(
        completion: @escaping ([Pin?]) -> Void
    ) {
        
        // want to do this search in terms of users region 
        var pins = [Pin?]()
//        let group = DispatchGroup()
        let ref = database.collection("pins")
//        group.enter()
        ref.getDocuments { documents, error in
            documents?.documents.forEach({ snapshot in
//                defer {
//                    group.leave()
//                }
                let data = snapshot.data()
                guard error == nil else {
                    completion([nil])
                    return
                }
                pins.append(Pin(with: data))
                
            })
//            group.notify(queue: .main) {
            completion(pins)
//            }
           
        }
    }
    
    public func UpdateEventRating(eventUser: String, linkid: String,rating: Double, completion:@escaping (Bool) -> Void) {
        
        guard let username = UserDefaults.standard.string(forKey: "username") else {
            return
        }
        
        let ref = database.collection("users")
            .document(eventUser)
            .collection("links")
            .document(linkid)
        getLink(with: linkid, from: eventUser) { link in
            guard var link = link else {
                completion(false)
                return
            }
            
            
           
            if !link.usersWhoRated.contains(username) {
                link.rating.append(rating)
                link.usersWhoRated.append(username)

            }
        
                
            guard let data = link.asDictionary() else {
                completion(false)
                return
            }
            
            ref.setData(data) { error in
                completion(error == nil)
            }
            
        }
    }
  
    
    
//    public func deleteLinkAfterEventComplete() {
//
//
//        var users = [String]()
//        let usersRef = database.collection("users")
//        usersRef.addSnapshotListener { snapshot, error in
//            snapshot?.documents.forEach { document in
//                users.append(document.documentID)
//            }
//
//        }
//
//            DispatchQueue.global(qos: .background).async {
//            users.forEach({ user in
//                let ref = self.database.collection("users")
//                    .document(user)
//                    .collection("links")
//                // first delete any old links
//                let date = Date().timeIntervalSince1970
//                let query =  ref.whereField("linkDate", isLessThan: date)
//                query.getDocuments { querySnapshot, error in
//                    querySnapshot?.documents.forEach({ document in
//                        document.reference.delete()
//                    })
//
//                }
//            })
//            }
//
//    }
    
    
    public func handleDeletingLink(completion: @escaping (Bool) -> Void) {
        
        guard let username = UserDefaults.standard.string(forKey: "username") else {
            return
        }
        
        let ref = self.database.collection("users")
            .document(username)
            .collection("links")
        
        // first delete any old links
      
        let date = Date().timeIntervalSince1970
//        + 10*24*60*60
        let query =  ref.whereField("linkDate", isLessThan: date)
        query.getDocuments { querySnapshot, error in
            querySnapshot?.documents.forEach({ document in
                if let link = LinkModel(with: document.data()) {
                    DispatchQueue.global(qos: .background).async {
                        StorageManager.shared.handleDeletingLinkStorage(urls: link.postArrayString , url2: link.linkTypeImage) { _ in
                        print("successfully deleted data from database")
                    }
                    }
                }
                document.reference.delete()
                completion(true)
                print("Link has been deleted")
            })

        }
        completion(false)

        
    }
    
    public func handleDeletingQuickLink(completion: @escaping (Bool) -> Void) {
        
        guard let username = UserDefaults.standard.string(forKey: "username") else {
            return
        }
        
        let ref = self.database.collection("users")
            .document(username)
            .collection("QuickLinks")
        
        // first quicklink after 24hrs
        let date = Date().timeIntervalSince1970
        let query = ref.whereField("date", isLessThan: date)
//        let query =  ref.whereField("date", isLessThan: date)
        query.getDocuments { querySnapshot, error in
            querySnapshot?.documents.forEach({ document in
                document.reference.delete()
                completion(true)
                print("QuickLink has been deleted")
            })

        }
        completion(false)

        
    }
    
    
    public func handleDeletingBoomingPins(completion: @escaping (Bool) -> Void) {
        
        guard let username = UserDefaults.standard.string(forKey: "username") else {
            return
        }
        
        let ref = self.database.collection("pins")
        
            
      
        let date = Date.now.timeIntervalSince1970
        let query = ref.whereField("timeStamp", isLessThan: date)
        query.getDocuments { querySnapshot, error in
            querySnapshot?.documents.forEach({ document in
                document.reference.delete()
                completion(true)
                print("Booming pin has been deleted")
            })

        }
        completion(false)

        
    }
    
    
    func checkBoomingPins()
    {
        NSLog("hello World")
    }
   
    
    public func findLinks(
        with linkPrefix: String,
        completion: @escaping ([LinkModel]) -> Void
    ) {
  
        /// get users from the database
//        let ref = database.collection("users")
        guard let username = UserDefaults.standard.string(forKey: "username") else {
            return
        }
        var allLinks = [LinkModel]()
//        let group = DispatchGroup()
        let otherGroup = DispatchGroup()
        
       following(for: username) { usernames in
            let users =  usernames + [username]
            
          
            users.forEach { user in
               
                otherGroup.enter()
                let postsRef = self.database.collection("users/\(username)/links")
                postsRef.getDocuments { snapshot, error in
                  
                    defer {
                        otherGroup.leave()
                    }
                    
                    guard let links = snapshot?.documents.compactMap({ LinkModel(with: $0.data()) }),
                          error == nil else {
                              return
                          }
                    
                     links.forEach { model in
                        allLinks.append(model)
                     }
                    
                    
//                    print("all the links : \(links)")
                    
                }
                                                        
            }
           
           otherGroup.notify(queue: .main) {
               let filteredPosts = allLinks.filter({
                    return  $0.linkTypeName.lowercased().hasPrefix(linkPrefix.lowercased())
                       })
                   print("filtered posts: \(filteredPosts)")
               let finalArray = Array(Set(filteredPosts))
               completion(finalArray)
           }
          
       }
        
      
      
        
    }
      

        
        
 

    
    
        
    /// Find users with prefix
    /// - Parameters:
    ///   - usernamePrefix: Query prefix
    ///   - completion: Result callback
    public func findUsers(
        with usernamePrefix: String,
        completion: @escaping ([User]) -> Void
    ) {
        let ref = database.collection("users")
        ref.getDocuments { snapshot, error in
            guard let users = snapshot?.documents.compactMap({ User(with: $0.data()) }),
                  error == nil else {
                completion([])
                return
            }
            let subset = users.filter({
                $0.username.lowercased().hasPrefix(usernamePrefix.lowercased())
            })

            completion(subset)
        }
    }
    
    
    

    /// Find posts from a given user
    /// - Parameters:
    ///   - username: Username to query
    ///   - completion: Result callback
//    public func posts(
//        for username: String,
//        completion: @escaping (Result<[Post], Error>) -> Void
//    ) {
//        let ref = database.collection("users")
//            .document(username)
//            .collection("posts")
//        ref.getDocuments { snapshot, error in
//            guard let posts = snapshot?.documents.compactMap({
//                Post(with: $0.data())
//            }).sorted(by: {
//                return $0.date > $1.date
//            }),
//            error == nil else {
//                return
//            }
//            completion(.success(posts))
//        }
//    }

    /// Find single user with email
    /// - Parameters:
    ///   - email: Source email
    ///   - completion: Result callback
    public func findUser(with email: String, completion: @escaping (User?) -> Void) {
        let ref = database.collection("users")
        ref.getDocuments { snapshot, error in
            guard let users = snapshot?.documents.compactMap({ User(with: $0.data()) }),
                  error == nil else {
                completion(nil)
                return
            }
            let user = users.first(where: { $0.email == email })
            completion(user)
        }
    }

    /// Find user with username
    /// - Parameters:
    ///   - username: Source username
    ///   - completion: Result callback
    public func findUser(username: String, completion: @escaping (User?) -> Void) {
        let ref = database.collection("users")
        ref.getDocuments { snapshot, error in
            guard let users = snapshot?.documents.compactMap({ User(with: $0.data()) }),
                  error == nil else {
                completion(nil)
                return
            }

            let user = users.first(where: { $0.username == username })
            completion(user)
        }
    }

    /// Create new post
    /// - Parameters:
    ///   - newPost: New Post model
    ///   - completion: Result callback
//    public func createPost(newPost: Post, completion: @escaping (Bool) -> Void) {
//        guard let username = UserDefaults.standard.string(forKey: "username") else {
//            completion(false)
//            return
//        }

//        let reference = database.document("users/\(username)/posts/\(newPost.id)")
//        guard let data = newPost.asDictionary() else {
//            completion(false)
//            return
//        }
//        reference.setData(data) { error in
//            completion(error == nil)
//        }
//    }

    /// Create new user
    /// - Parameters:
    ///   - newUser: User model
    ///   - completion: Result callback
    public func createUser(newUser: User, completion: @escaping (Bool) -> Void) {
        let reference = database.document("users/\(newUser.username)")
        guard let data = newUser.asDictionary() else {
            completion(false)
            return
        }
        reference.setData(data) { error in
            completion(error == nil)
        }
    }

    /// Gets posts for explore page
    /// - Parameter completion: Result callback
    public func explorePosts(completion: @escaping ([(link: LinkModel, user: User)]) -> Void) {
        let ref = database.collection("users")
        ref.getDocuments { snapshot, error in
            guard let users = snapshot?.documents.compactMap({ User(with: $0.data()) }),
                  error == nil else {
                completion([])
                return
            }

            let group = DispatchGroup()
            var aggregatePosts = [(link: LinkModel, user: User)]()

            users.forEach { user in
                group.enter()

                let username = user.username
                let postsRef = self.database.collection("users/\(username)/links")

                postsRef.getDocuments { snapshot, error in

                    defer {
                        group.leave()
                    }

                    guard let links = snapshot?.documents.compactMap({ LinkModel(with: $0.data()) }),
                          error == nil else {
                        return
                    }

                    aggregatePosts.append(contentsOf: links.compactMap({
                        (link: $0, user: user)
                    }))
                }
            }

            group.notify(queue: .main) {
                completion(aggregatePosts)
            }
        }
    }

    /// Get notifications for current user
    /// - Parameter completion: Result callback
    public func getNotifications(
        completion: @escaping ([LinkNotification]) -> Void
    ) {
        guard let username = UserDefaults.standard.string(forKey: "username") else {
            completion([])
            return
        }
        let ref = database.collection("users").document(username).collection("notifications")
        ref.getDocuments { snapshot, error in
            guard let notifications = snapshot?.documents.compactMap({
                LinkNotification(with: $0.data())
            }),
            error == nil else {
                completion([])
                return
            }

            completion(notifications)
        }
    }
    
    public func getNotification (notificationID: String,
        completion: @escaping (LinkNotification?) -> Void
    ) {
        guard let username = UserDefaults.standard.string(forKey: "username") else {
            completion(nil)
            return
        }
        let ref = database.collection("users").document(username).collection("notifications").document(notificationID)
        ref.getDocument { snapshot, error in
            guard let notifications = snapshot?.data(),
                  error == nil else {
                completion(nil)
                return
            }

            completion(LinkNotification(with: notifications))
        }
    }

    /// Creates new notification
    /// - Parameters:
    ///   - identifer: New notification ID
    ///   - data: Notification data
    ///   - username: target username
    public func insertNotification(
        identifer: String,
        data: [String: Any],
        for username: String
    ) {
        let ref = database.collection("users")
            .document(username)
            .collection("notifications")
            .document(identifer)
        ref.setData(data)
    }

    /// Get a post with id and username
    /// - Parameters:
    ///   - identifer: Query id
    ///   - username: Query username
    ///   - completion: Result callback
//    public func getPost(
//        with identifer: String,
//        from username: String,
//        completion: @escaping (Post?) -> Void
//    ) {
//        let ref = database.collection("users")
//            .document(username)
//            .collection("posts")
//            .document(identifer)
//        ref.getDocument { snapshot, error in
//            guard let data = snapshot?.data(),
//                  error == nil else {
//                completion(nil)
//                return
//            }
//
//            completion(Post(with: data))
//        }
//    }

    /// Follow states that are supported
    enum RelationshipState {
        case follow
        case unfollow
    }
    
    
    enum RelationshipStateRequest {
        case request
        case requesting
    }
    
    enum RelationshipStateAccept{
        case accept
        case accepted
    }
    
    enum RelationshipStatePrivate {
        case isPrivate
        case notPrivate
        
    }
    
    enum RelationshipStateJoin{
        case join
        case joined
    }
     
    

    /// Update relationship of follow for user
    /// - Parameters:
    ///   - state: State to update to
    ///   - targetUsername: Other user username
    ///   - completion: Result callback
    public func updateRelationship(
        state: RelationshipState,
        for targetUsername: String,
        completion: @escaping (Bool) -> Void
    ) {
        guard let currentUsername = UserDefaults.standard.string(forKey: "username") else {
            completion(false)
            return
        }

        let currentFollowing = database.collection("users")
            .document(currentUsername)
            .collection("following")

        let targetUserFollowers = database.collection("users")
            .document(targetUsername)
            .collection("followers")

        switch state {
        case .unfollow:
            // Remove follower for currentUser following list
            currentFollowing.document(targetUsername).delete()
            // Remove currentUser from targetUser followers list
            targetUserFollowers.document(currentUsername).setData(["valid": "1"])
            
            completion(true)
        case .follow:
            // Add follower for requester following list
            currentFollowing.document(targetUsername).setData(["valid": "1"])
            // Add currentUser to targetUser followers list
            targetUserFollowers.document(currentUsername).delete()

            completion(true)
        }
    }
    
    
    
//    public func uploadGuest(targertUser: String, guests: [SearchUser], linkId: String, completion: @escaping(Bool)->Void) {
//        let ref = database.collection("users").document(targertUser).collection("links").document(linkId).collection("Pending")
//
//        guests.forEach { guest in
//            ref.document(guest.name).setData(["name": "\(guest.name)"])
//            completion(true)
//        }
//    }

//    public func getPendingUsers(targetUser: String, linkId: String, completion: @escaping([SearchUser]) -> Void) {
//
//        let ref = database.collection("users").document(targetUser).collection("links").document(linkId).collection("Pending")
//        ref.getDocuments { snapshot, error in
//            guard let user = snapshot?.documents.compactMap({
//                SearchUser(with: $0.data())
//            }),
//            error == nil else {
//                completion([])
//                return
//            }
//
//            completion(user)
//        }
//    }

    
    
//    public func getAcceptedUsers(targetUser: String, linkId: String, completion: @escaping([SearchUser]) -> Void) {
//
//        let ref = database.collection("users").document(targetUser).collection("links").document(linkId).collection("Accepted")
//        ref.getDocuments { snapshot, error in
//            guard let user = snapshot?.documents.compactMap({
//                SearchUser(with: $0.data())
//            }),
//            error == nil else {
//                completion([])
//                return
//            }
//
//            completion(user)
//        }
//    }

    
    
//    public func isAccepted(targetUsername: String, linkId: String, completion: @escaping(Bool) -> Void) {
//
//        guard let currentUsername = UserDefaults.standard.string(forKey: "username") else {
//            return
//        }
//        let ref = database.collection("users").document(targetUsername).collection("links").document(linkId).collection("Accepted").document(currentUsername )
//
//        ref.addSnapshotListener { snapshot, error in
//            guard snapshot?.data() != nil, error == nil else {
//                // Not following
//                completion(false)
//                return
//            }
//            // following
//            completion(true)
//        }
//    }
    
    
    
//    public func isPending(targetUsername: String, linkId: String, completion: @escaping(Bool) -> Void) {
//
//        guard let currentUsername = UserDefaults.standard.string(forKey: "username") else {
//            return
//        }
//        let ref = database.collection("users").document(targetUsername).collection("links").document(linkId).collection("Pending").document(currentUsername )
//
//        ref.addSnapshotListener { snapshot, error in
//            guard snapshot?.data() != nil, error == nil else {
//                // Not following
//                completion(false)
//                return
//            }
//            // following
//            completion(true)
//        }
//    }
//
    

    public func updateGuestList(state: RelationshipStateAccept,
                                linkId: String,
                                eventUsername: String,
                                completion: @escaping (Bool) -> Void
    ) {

        guard let username = UserDefaults.standard.string(forKey: "username") else {
            return
        }

        let refAccept = database.collection("users").document(eventUsername).collection("links").document(linkId).collection("Accepted")

        let refPending = database.collection("users").document(eventUsername).collection("links").document(linkId).collection("Pending")

            switch state {
            case .accept:
//             delete user from accepted database
                refPending.document(username).delete()
//             add user to requesting database
                refAccept.document(username).setData(["name": "\(username)"])

                completion(true)
            case .accepted:
                // delete user from requesting database
                refAccept.document(username).delete()
                // add user to accepted database
                refPending.document(username).setData(["name": "\(username)"])
                completion(true)
                break

            }


        }

//
//
//
    
//    public func updateGuestListForInvitesOnly(state: RelationshipStateAccept,
//                                linkId: String,
//                                eventUsername: String,
//                                completion: @escaping (Bool) -> Void
//    ) {
//        
//        
//      
//        DatabaseManager.shared.getLink(with: linkId, from: eventUsername) { linkModel in
//            guard var usersArray = linkModel?.invites else {
//                return
//            }
//            
//            
//            switch state {
//            case .accepted:
//                /// find users email and add to database
//                DatabaseManager.shared.findUser(with: eventUsername) { user in
//                    guard let email = user?.email else {
//                        return
//                    }
//                    let newUser = SearchResult(name: eventUsername, email: email)
//                    usersArray.append(newUser)
//                    print("Sucessfully added user from database ")
//                    completion(true)
//                }
//                
//                
//               
//                
//                
//                
//                DatabaseManager.shared.getLink(with: linkId, from: eventUsername) { linkModel in
//                    
//                    
//                    
//                }
//                
//                completion(true)
//            case .accept:
//                /// remove  user from database!
//                completion(true)
//                break
//                
//            
//            
//                
//        }
//        
//    }
//    }
//    
    
//    public func deleteUserFromRequest(userRequesting: String,linkId: String, completion: @escaping(Bool)-> Void) {
//
//        guard let currentUsername = UserDefaults.standard.string(forKey: "username") else {
//            return
//        }
//
//        let currentRequests = database.collection("users")
//            .document(userRequesting)
//            .collection("links").document(linkId).collection("requesting")
//
//        currentRequests.document(userRequesting).delete()
//
//        completion(true)
//
//
//    }
    
//
//    public func isRequestEvent(targetUsername: String,linkId: String, completion: @escaping(Bool)-> Void) {
//        guard let currentUsername = UserDefaults.standard.string(forKey: "username") else {
//            completion(false)
//            return
//        }
//
//        let currentRequests = database.collection("users")
//            .document(targetUsername)
//            .collection("links").document(linkId).collection("requesting")
//            .document(currentUsername)
//        currentRequests.addSnapshotListener { snapshot, error in
//            guard snapshot?.data() != nil, error == nil else {
//                // Not following
//                completion(false)
//                return
//            }
//            // following
//            completion(true)
//        }
//    }
    
//    public func updateRelationshipRequest(
//        linkId: String,
//        username: String,
//        state: RelationshipStateRequest,
//        completion: @escaping (Bool) -> Void
//    ) {
//        guard let currentUsername = UserDefaults.standard.string(forKey: "username") else {
//            completion(false)
//            return
//        }
//
//        let currentRequests = database.collection("users")
//            .document(username)
//            .collection("links").document(linkId).collection("requesting")
//
//
//        switch state {
//        case .requesting:
//            currentRequests.document(currentUsername).delete()
//            completion(true)
//        case .request:
//            currentRequests.document(currentUsername).setData(["valid": "1"])
//            completion(true)
//        }
//    }


    /// Get user counts for target usre
    /// - Parameters:
    ///   - username: Username to query
    ///   - completion: Callback
    public func getUserCounts(
        username: String,
        completion: @escaping ((followers: Int, following: Int, posts: Int)) -> Void
    ) {
        let userRef = database.collection("users")
            .document(username)

        var followers = 0
        var following = 0
        var posts = 0

        let group = DispatchGroup()
        group.enter()
        group.enter()
        group.enter()

        userRef.collection("links").getDocuments { snapshot, error in
            defer {
                group.leave()
            }

            guard let count = snapshot?.documents.count, error == nil else {
                return
            }
            posts = count
        }

        userRef.collection("followers").getDocuments { snapshot, error in
            defer {
                group.leave()
            }

            guard let count = snapshot?.documents.count, error == nil else {
                return
            }
            followers = count
        }

        userRef.collection("following").getDocuments { snapshot, error in
            defer {
                group.leave()
            }

            guard let count = snapshot?.documents.count, error == nil else {
                return
            }
            following = count
        }

        group.notify(queue: .global()) {
            let result = (
                followers: followers,
                following: following,
                posts: posts
            )
            completion(result)
        }
    }
    
    
    // saves the users state isPrivate to database
    public func UpdatePrivateState(state: RelationshipStatePrivate, completion: @escaping(Bool) -> Void) {
        
        guard let username = UserDefaults.standard.string(forKey: "username") else {
            fatalError("Could not get the username and data")
        }
        
        let ref = database.collection("users").document(username).collection("links").document("isPrivate")
        
        switch state {
        case .isPrivate:
            ref.setData(["Valid": "1"])
           completion(true)
        case .notPrivate:
            ref.delete()
            completion(true)
        }

    }
    
    public func isUserPrivate(username: String, completion: @escaping(Bool) -> Void) {
        
        let ref = database.collection("users").document(username).collection("links").document("isPrivate")
        
        ref.getDocument { snapshot, error in
            guard snapshot?.data() != nil, error == nil else {
                // Not following
                completion(false)
                return
            }
            // following
            completion(true)
        }
    }
    
    public func deleteRequestingUsersWhenPublic(completion: @escaping(Bool)-> Void) {
        
        guard let currentUsername = UserDefaults.standard.string(forKey: "username") else {
            fatalError("Error fetching username")
        }
        let group = DispatchGroup()
        let ref = database.collection("users").document(currentUsername).collection("requesting")
        
        ref.getDocuments {snapshot, error in
            group.enter()
            guard let usersRequesting = snapshot?.documents.compactMap({ $0.documentID }), error == nil else {
                completion(false)
                return
            }
            usersRequesting.forEach { targetUser in
                
                     defer {
                         group.leave()
                     }
                     
                // eg gabby is the requesting party (target user) and yasmina is the current user
                let currentFollowing = self.database.collection("users")
                    .document(currentUsername)
                    .collection("followers") // yasi's followers

                let targetUserFollowers = self.database.collection("users")
                    .document(targetUser)
                    .collection("following")
                
                
                currentFollowing.document(targetUser).setData(["valid": "1"]) // put gabby in yasi followers
                targetUserFollowers.document(currentUsername).setData(["valid": "1"]) //gabby's following put yasmina

               
    
                    // print send the targetUser the notifications!
                    print("sucessfully added the user to the follow database")
                    ref.document(targetUser).delete()
                }
        
        group.notify(queue: .main) {
            
            completion(true)
            
        }
        }
        
    }
        

    

    public func updateRequestingState(targetUsername: String, state: RelationshipStateRequest, completion: @escaping(Bool) -> Void) {
    
        guard let currentUsername = UserDefaults.standard.string(forKey: "username") else {
            completion(false)
            return
        }

        let currentRequesting = database.collection("users")
            .document(targetUsername)
            .collection("requesting")


        switch state {
        case .request:
            // Remove follower for currentUser following list
            currentRequesting.document(currentUsername).delete()
            /// checks if the user is public
            /// if !isPriavet {...}
            /// update the state of target user in the following of the other user
            completion(false)
        case .requesting:
            // Add follower for requester following list
            currentRequesting.document(currentUsername).setData(["valid": "1"])

            completion(true)
        }
        
    }
    
    public func isRequesting(targetUsername: String, completion: @escaping(Bool)-> Void) {
        guard let currentUsername = UserDefaults.standard.string(forKey: "username") else {
            completion(false)
            return
        }

        let ref = database.collection("users")
            .document(targetUsername)
            .collection("requesting")
            .document(currentUsername)
        ref.getDocument { snapshot, error in
            guard snapshot?.data() != nil, error == nil else {
                // Not following
                completion(false)
                return
            }
            // following
            completion(true)
        }
    }


  
    
    /// Check if current user is following another
    /// - Parameters:
    ///   - targetUsername: Other user to check
    ///   - completion: Result callback
    public func isFollowing(
        targetUsername: String,
        completion: @escaping (Bool) -> Void
    ) {
        guard let currentUsername = UserDefaults.standard.string(forKey: "username") else {
            completion(false)
            return
        }

        let ref = database.collection("users")
            .document(targetUsername)
            .collection("followers")
            .document(currentUsername)
        ref.getDocument { snapshot, error in
            guard snapshot?.data() != nil, error == nil else {
                // Not following
                completion(false)
                return
            }
            // following
            completion(true)
        }
    }
    

    /// Get followers for user
    /// - Parameters:
    ///   - username: Username to query
    ///   - completion: Result callback
    public func followers(for username: String, completion: @escaping ([String]) -> Void) {
        let ref = database.collection("users")
            .document(username)
            .collection("followers")
        ref.getDocuments { snapshot, error in
            guard let usernames = snapshot?.documents.compactMap({ $0.documentID }), error == nil else {
                completion([])
                return
            }
            completion(usernames)
        }
    }

    /// Get users that parameter username follows
    /// - Parameters:
    ///   - username: Query usernam
    ///   - completion: Result callback
    public func following(for username: String, completion: @escaping ([String]) -> Void) {
        let ref = database.collection("users")
            .document(username)
            .collection("following")
        ref.getDocuments { snapshot, error in
            guard let usernames = snapshot?.documents.compactMap({ $0.documentID }), error == nil else {
                completion([])
                return
            }
            completion(usernames)
        }
    }

    // MARK: - User Info

    /// Get user info
    /// - Parameters:
    ///   - username: username to query for
    ///   - completion: Result callback
    public func getUserInfo(
        username: String,
        completion: @escaping (UserInfo?) -> Void
    ) {
        let ref = database.collection("users")
            .document(username)
            .collection("information")
            .document("basic")
        ref.getDocument { snapshot, error in
            guard let data = snapshot?.data(),
                  let userInfo = UserInfo(with: data) else {
                completion(nil)
                return
            }
            completion(userInfo)
        }
    }

    /// Set user info
    /// - Parameters:
    ///   - userInfo: UserInfo model
    ///   - completion: Callback
    public func setUserInfo(
        userInfo: UserInfo,
        completion: @escaping (Bool) -> Void
    ) {
        guard let username = UserDefaults.standard.string(forKey: "username"),
              let data = userInfo.asDictionary() else {
            return
        }

        let ref = database.collection("users")
            .document(username)
            .collection("information")
            .document("basic")
        ref.setData(data) { error in
            completion(error == nil)
        }
    }

    // MARK: - Comment

    /// Create a comment
    /// - Parameters:
    ///   - comment: Comment mmodel
    ///   - postID: post id
    ///   - owner: username who owns post
    ///   - completion: Result callback
    public func createComments(
        comment: Comment,
        postID: String,
        owner: String,
        completion: @escaping (Bool) -> Void
    ) {
        let newIdentifier = "\(postID)_\(comment.username)_\(Date().timeIntervalSince1970)_\(Int.random(in: 0...1000))"
        let ref = database.collection("users")
            .document(owner)
            .collection("links")
            .document(postID)
            .collection("comments")
            .document(newIdentifier)
        guard let data = comment.asDictionary() else { return }
        ref.setData(data) { error in
            completion(error == nil)
        }
    }

    /// Get comments for given post
    /// - Parameters:
    ///   - postID: Post id to query
    ///   - owner: Username who owns post
    ///   - completion: Result callback
    public func getComments(
        postID: String,
        owner: String,
        completion: @escaping ([Comment]) -> Void
    ) {
        let ref = database.collection("users")
            .document(owner)
            .collection("links")
            .document(postID)
            .collection("comments")
        ref.addSnapshotListener { snapshot, error in
            guard let comments = snapshot?.documents.compactMap({
                Comment(with: $0.data())
            }).sorted(by: { first, second in
                second.date > first.date
            }),
            error == nil else {
                completion([])
                return
            }

            completion(comments)
        }
    }

    // MARK: - Liking

   
    enum LikeState {
        case like
        case unlike
    }

    public func createLike (
        postID: String,
        owner: String,
        completion: @escaping (Bool) -> Void
    ) {
        
        guard let currentUser = UserDefaults.standard.string(forKey: "username") else {
            return
        }
        let ref = database.collection("users")
            .document(owner)
            .collection("links")
            .document(postID)
            .collection("likers").document(currentUser)
        
        ref.setData(["valid": "1"]) { error in
            completion(error == nil)
        }
    }
    public func updateLikeState(
        state: LikeState,
        postID: String,
        owner: String,
        completion: @escaping (Bool) -> Void
    ) {
        guard let currentUsername = UserDefaults.standard.string(forKey: "username") else { return }
        let ref = database.collection("users")
            .document(owner)
            .collection("links")
            .document(postID)
        getLink(with: postID, from: owner) { link in
            guard var link = link else {
                completion(false)
                return
            }

            switch state {
            case .like:
                if !link.likers.contains(currentUsername) {
                    link.likers.append(currentUsername)
                }
            case .unlike:
                link.likers.removeAll(where: { $0 == currentUsername })
            }

//            NotificationCenter.default.post(name: .updateLikeCount, object: nil, userInfo: ["likers": link.likers])
            guard let data = link.asDictionary() else {
                completion(false)
                return
            }
            
           
            ref.setData(data) { error in
                completion(error == nil)
            }
        }
    }
    
    public func updateAcceptState(
        state: RelationshipStateAccept,
        postID: String,
        owner: String,
        completion: @escaping (Bool) -> Void
    ) {
        guard let currentUsername = UserDefaults.standard.string(forKey: "username") else { return }
        let ref = database.collection("users")
            .document(owner)
            .collection("links")
            .document(postID)
        getLink(with: postID, from: owner) { link in
            guard var link = link else {
                completion(false)
                return
            }

            let user = SearchUser(name: currentUsername)
            switch state {
            case .accept:
//                if link.pending.contains(user) {
                    link.accepted.append(user)
                    link.pending.removeAll(where: { $0 == user })
//                }
          
            case .accepted:
//                if link.accepted.contains(user) {
                    link.pending.append(user)
                    link.accepted.removeAll(where: { $0 == user })
                    
//                }
          
            }


            guard let data = link.asDictionary() else {
                completion(false)
                return
            }
            
        }
    }
    
    
    public func updateNotifticationRequestButton(owner: String, notificationID: String, isAccepted: Bool?, completion: @escaping(Bool)-> Void) {
        
        let ref = database.collection("users")
            .document(owner)
            .collection("notifications")
            .document(notificationID)
        getNotification(notificationID: notificationID) { notification in
            
            guard var notification = notification else {
                completion(false)
                return
            }
            
            notification.isRequesting.removeAll()
            notification.isRequesting.append(isAccepted)
            
            guard let data = notification.asDictionary() else {
                completion(false)
                return
            }
            
           
            ref.setData(data) { error in
                completion(error == nil)
            }
    }
    
    }
    
    
    public func updateNotifticationFollowButton(owner: String, notificationID: String, isFollowing: Bool?, completion: @escaping(Bool)-> Void) {
        
        let ref = database.collection("users")
            .document(owner)
            .collection("notifications")
            .document(notificationID)
        getNotification(notificationID: notificationID) { notification in
            
            guard var notification = notification else {
                completion(false)
                return
            }
            
            notification.isFollowing.removeAll()
            notification.isFollowing.append(isFollowing)
            guard let data = notification.asDictionary() else {
                completion(false)
                return
            }
            
           
            ref.setData(data) { error in
                completion(error == nil)
            }
    }
    
    }
//    
//    
    public func updateJoinState(
        state: RelationshipStateJoin,
        linkId: String,
        owner: String,
        completion: @escaping (Bool) -> Void
    ) {
        guard let currentUsername = UserDefaults.standard.string(forKey: "username") else { return }
        let ref = database.collection("users")
            .document(owner)
            .collection("QuickLinks")
            .document(linkId)
        getQuickLink(with: linkId, from: owner) { quickLink in
            guard var quickLink = quickLink else {
                completion(false)
                return
            }

            let user = SearchUser(name: currentUsername)
            switch state {
            case .join:
                if quickLink.joined.contains(user) {
                    quickLink.joined.removeAll(where: { $0 == user })
                }
          
            case .joined:
                if !quickLink.joined.contains(where: { $0 == user } ) {
                    quickLink.joined.append(user)
                }
             
          
            }


            guard let data = quickLink.asDictionary() else {
                completion(false)
                return
            }
            
            NotificationCenter.default.post(name: .didUpdateJoinButton, object: nil, userInfo: ["isJoined": quickLink.joined])
           
            ref.setData(data) { error in
                completion(error == nil)
            }
        }
    }
    
    public func updateRequestState(
        state: RelationshipStateRequest,
        postID: String,
        owner: String,
        completion: @escaping (Bool) -> Void
    ) {
        guard let currentUsername = UserDefaults.standard.string(forKey: "username") else { return }
        let ref = database.collection("users")
            .document(owner)
            .collection("links")
            .document(postID)
        getLink(with: postID, from: owner) { link in
            guard var link = link else {
                completion(false)
                return
            }

            let user = SearchUser(name: currentUsername)
            switch state {
            case .requesting:
                  link.requesting.removeAll(where: { $0 == user })
            case .request:
                if !link.requesting.contains(user) {
                    link.requesting.append(user)
                }
            }


            guard let data = link.asDictionary() else {
                completion(false)
                return
            }
            
           
            ref.setData(data) { error in
                completion(error == nil)
            }
        }
    }
    
    
    
    
    
    
}

//MARK: - Messaging


//MARK: - Account Management


extension DatabaseManager {

    /// Returns dictionary node at child path
    public func getDataFor(path: String, completion: @escaping (Result<Any, Error>) -> Void) {
        realDatabase.child("\(path)").observeSingleEvent(of: .value) { snapshot in
            guard let value = snapshot.value else {
                completion(.failure(DatabaseError.failedToFetch))
                return
            }
            completion(.success(value))
        }
    }

}

// MARK: - Account Mgmt

extension DatabaseManager {

    /// Checks if user exists for given email
    /// Parameters
    /// - `email`:              Target email to be checked
    /// - `completion`:   Async closure to return with result
    public func userExists(with email: String,
                           completion: @escaping ((Bool) -> Void)) {

        let safeEmail = DatabaseManager.safeEmail(emailAddress: email)
        realDatabase.child(safeEmail).observeSingleEvent(of: .value, with: { snapshot in
            guard snapshot.value as? [String: Any] != nil else {
                completion(false)
                return
            }

            completion(true)
        })

    }

    /// Inserts new user to database
    public func insertUser(with user: ChatAppUser, completion: @escaping (Bool) -> Void) {
        realDatabase.child(user.safeEmail).setValue([
            "name": user.username,
        ], withCompletionBlock: { [weak self] error, _ in

            guard let strongSelf = self else {
                return
            }

            guard error == nil else {
                print("failed ot write to database")
                completion(false)
                return
            }

            strongSelf.realDatabase.child("users").observeSingleEvent(of: .value, with: { snapshot in
                if var usersCollection = snapshot.value as? [[String: String]] {
                    // append to user dictionary
                    let newElement = [
                        "name": user.username,
                        "email": user.safeEmail
                    ]
                    usersCollection.append(newElement)

                    strongSelf.realDatabase.child("users").setValue(usersCollection, withCompletionBlock: { error, _ in
                        guard error == nil else {
                            completion(false)
                            return
                        }

                        completion(true)
                    })
                }
                else {
                    // create that array
                    let newCollection: [[String: String]] = [
                        [
                            "name": user.username,
                            "email": user.safeEmail
                        ]
                    ]

                    strongSelf.realDatabase.child("users").setValue(newCollection, withCompletionBlock: { error, _ in
                        guard error == nil else {
                            completion(false)
                            return
                        }

                        completion(true)
                    })
                }
            })
        })
    }

    /// Gets all users from database
    public func getAllUsers(completion: @escaping (Result<[[String: String]], Error>) -> Void) {
        realDatabase.child("users").observeSingleEvent(of: .value, with: { snapshot in
            guard let value = snapshot.value as? [[String: String]] else {
                completion(.failure(DatabaseError.failedToFetch))
                return
            }

            completion(.success(value))
        })
    }

    public enum DatabaseError: Error {
        case failedToFetch

        public var localizedDescription: String {
            switch self {
            case .failedToFetch:
                return "This means block failed"
            }
        }
    }

    /*
        users => [
           [
               "name":
               "safe_email":
           ],
           [
               "name":
            "safe_email":
           ]
       ]
        */
}

// MARK: - Sending messages / conversations

extension DatabaseManager {

    /*
        "dfsdfdsfds" {
            "messages": [
                {
                    "id": String,
                    "type": text, photo, video,
                    "content": String,
                    "date": Date(),
                    "sender_email": String,
                    "isRead": true/false,
                }
            ]
        }

           conversaiton => [
              [
                  "conversation_id": "dfsdfdsfds"
                  "other_user_email":
                  "latest_message": => {
                    "date": Date()
                    "latest_message": "message"
                    "is_read": true/false
                  }
              ],
            ]
           */

    /// Creates a new conversation with target user emamil and first message sent
    public func createNewConversation(with otherUserEmail: String, name: String, firstMessage: Message, completion: @escaping (Bool) -> Void) {
        
        guard let currentEmail = UserDefaults.standard.value(forKey: "email") as? String,
            let currentNamme = UserDefaults.standard.value(forKey: "username") as? String else {
                return
        }
        let safeEmail = DatabaseManager.safeEmail(emailAddress: currentEmail)

        let ref = realDatabase.child("\(safeEmail)")
        ref.observeSingleEvent(of: .value, with: { [weak self] snapshot in
            guard var userNode = snapshot.value as? [String: Any] else {
                completion(false)
                print("user not found")
                return
            }

            let messageDate = firstMessage.sentDate
            let dateString = ChatViewController.dateFormatter.string(from: messageDate)

            var message = ""

            switch firstMessage.kind {
            case .text(let messageText):
                message = messageText
            case .attributedText(_):
                break
            case .photo(_):
                break
            case .video(_):
                break
            case .location(_):
                break
            case .emoji(_):
                break
            case .audio(_):
                break
            case .contact(_):
                break
            case .custom(_):
                break
            case .linkPreview(_):
                break
            }

            let conversationId = "conversation_\(firstMessage.messageId)"

            let newConversationData: [String: Any] = [
                "id": conversationId,
                "other_user_email": otherUserEmail,
                "name": name,
                "latest_message": [
                    "date": dateString,
                    "message": message,
                    "is_read": false
                ]
            ]

            let recipient_newConversationData: [String: Any] = [
                "id": conversationId,
                "other_user_email": safeEmail,
                "name": currentNamme,
                "latest_message": [
                    "date": dateString,
                    "message": message,
                    "is_read": false
                ]
            ]
            // Update recipient conversaiton entry

            self?.realDatabase.child("\(otherUserEmail)/conversations").observeSingleEvent(of: .value, with: { [weak self] snapshot in
                if var conversatoins = snapshot.value as? [[String: Any]] {
                    // append
                    conversatoins.append(recipient_newConversationData)
                    self?.realDatabase.child("\(otherUserEmail)/conversations").setValue(conversatoins)
                }
                else {
                    // create
                    self?.realDatabase.child("\(otherUserEmail)/conversations").setValue([recipient_newConversationData])
                }
            })

            // Update current user conversation entry
            if var conversations = userNode["conversations"] as? [[String: Any]] {
                // conversation array exists for current user
                // you should append

                conversations.append(newConversationData)
                userNode["conversations"] = conversations
                ref.setValue(userNode, withCompletionBlock: { [weak self] error, _ in
                    guard error == nil else {
                        completion(false)
                        return
                    }
                    self?.finishCreatingConversation(name: name,
                                                     conversationID: conversationId,
                                                     firstMessage: firstMessage,
                                                     completion: completion)
                })
            }
            else {
                // conversation array does NOT exist
                // create it
                userNode["conversations"] = [
                    newConversationData
                ]

                ref.setValue(userNode, withCompletionBlock: { [weak self] error, _ in
                    guard error == nil else {
                        completion(false)
                        return
                    }

                    self?.finishCreatingConversation(name: name,
                                                     conversationID: conversationId,
                                                     firstMessage: firstMessage,
                                                     completion: completion)
                })
            }
        })
    }

    private func finishCreatingConversation(name: String, conversationID: String, firstMessage: Message, completion: @escaping (Bool) -> Void) {
//        {
//            "id": String,
//            "type": text, photo, video,
//            "content": String,
//            "date": Date(),
//            "sender_email": String,
//            "isRead": true/false,
//        }

        let messageDate = firstMessage.sentDate
        let dateString = ChatViewController.dateFormatter.string(from: messageDate)

        var message = ""
        switch firstMessage.kind {
        case .text(let messageText):
            message = messageText
        case .attributedText(_):
            break
        case .photo(_):
            break
        case .video(_):
            break
        case .location(_):
            break
        case .emoji(_):
            break
        case .audio(_):
            break
        case .contact(_):
            break
        case .custom(_):
            break
        case .linkPreview(_):
            break
        }

        guard let myEmmail = UserDefaults.standard.value(forKey: "email") as? String else {
            completion(false)
            return
        }

        let currentUserEmail = DatabaseManager.safeEmail(emailAddress: myEmmail)

        let collectionMessage: [String: Any] = [
            "id": firstMessage.messageId,
            "type": firstMessage.kind.messageKindString,
            "content": message,
            "date": dateString,
            "sender_email": currentUserEmail,
            "is_read": false,
            "name": name
        ]

        let value: [String: Any] = [
            "messages": [
                collectionMessage
            ]
        ]

        print("adding convo: \(conversationID)")

        realDatabase.child("\(conversationID)").setValue(value, withCompletionBlock: { error, _ in
            guard error == nil else {
                completion(false)
                return
            }
            completion(true)
        })
    }

    /// Fetches and returns all conversations for the user with passed in email
    public func getAllConversations(for email: String, completion: @escaping (Result<[Conversations], Error>) -> Void) {
        realDatabase.child("\(email)/conversations").observe(.value, with: { snapshot in
            guard let value = snapshot.value as? [[String: Any]] else{
                completion(.failure(DatabaseError.failedToFetch))
                return
            }

            let conversations: [Conversations] = value.compactMap({ dictionary in
                guard let conversationId = dictionary["id"] as? String,
                    let name = dictionary["name"] as? String,
                    let otherUserEmail = dictionary["other_user_email"] as? String,
                    let latestMessage = dictionary["latest_message"] as? [String: Any],
                    let date = latestMessage["date"] as? String,
                    let message = latestMessage["message"] as? String,
                    let isRead = latestMessage["is_read"] as? Bool else {
                        return nil
                }

                let latestMmessageObject = LatestMessage(date: date,
                                                         text: message,
                                                         isRead: isRead
                                                        )
                return Conversations(id: conversationId,
                                    name: name,
                                     otherUserEmail: otherUserEmail,
                                    latestMessage: latestMmessageObject)
            })

            completion(.success(conversations))
            print("got convo info")
        })
    }

    /// Gets all mmessages for a given conversatino
    public func getAllMessagesForConversation(with id: String, completion: @escaping (Result<[Message], Error>) -> Void) {
        realDatabase.child("\(id)/messages").observe(.value, with: { snapshot in
            guard let value = snapshot.value as? [[String: Any]] else {
                completion(.failure(DatabaseError.failedToFetch))
                return
            }

            let messages: [Message] = value.compactMap({ dictionary in
                guard let name = dictionary["name"] as? String,
                    let isRead = dictionary["is_read"] as? Bool,
                    let messageID = dictionary["id"] as? String,
                    let content = dictionary["content"] as? String,
                    let senderEmail = dictionary["sender_email"] as? String,
                    let type = dictionary["type"] as? String,
                    let dateString = dictionary["date"] as? String,
                    let date = ChatViewController.dateFormatter.date(from: dateString) else {
                        return nil
                }
                
                var kind: MessageKind?
//                var type: String?
                if type == "photo" {
                    // photo
                    guard let imageUrl = URL(string: content),
                    let placeHolder = UIImage(systemName: "plus") else {
                        return nil
                    }
                    let media = Media(url: imageUrl,
                                      image: nil,
                                      placeholderImage: placeHolder,
                                      size: CGSize(width: 300, height: 300))
                    kind = .photo(media)
                }
                else if type == "video" {
                    // photo
                    guard let videoUrl = URL(string: content),
                        let placeHolder = UIImage(named: "video_placeholder") else {
                            return nil
                    }
                    
                    let media = Media(url: videoUrl,
                                      image: nil,
                                      placeholderImage: placeHolder,
                                      size: CGSize(width: 300, height: 300))
                    kind = .video(media)
                }
                else if type == "location" {
                    let locationComponents = content.components(separatedBy: ",")
                    guard let longitude = Double(locationComponents[0]),
                        let latitude = Double(locationComponents[1]) else {
                        return nil
                    }
                    print("Rendering location; long=\(longitude) | lat=\(latitude)")
                    let location = Location(location: CLLocation(latitude: latitude, longitude: longitude),
                                            size: CGSize(width: 300, height: 300))
                    kind = .location(location)
//                } else if type == "custom" {
//                    let privateLinkComponent = content.components(separatedBy: ",")
//                    let latitude = Double(privateLinkComponent[4])
//                    let longitude = Double(privateLinkComponent[5])
//                    let coordinates = CLLocationCoordinate2D(latitude: latitude ?? 0.0, longitude: longitude ?? 0.0)
//                    let timeInterval = TimeInterval(privateLinkComponent[2])
//
////                 let privateLink = PrivateLink(title: privateLinkComponent[0], desciption: privateLinkComponent[1], date: timeInterval, locationTitle: privateLinkComponent[3], coordinates: coordinates)
////
////
////                        print("quicklink: \(privateLink)")
//                    kind = .custom(privateLink)

                } else {
                    kind = .text(content)
                }

                guard let finalKind = kind else {
                    return nil
                }

                let sender = Sender(photoURL: "",
                                    senderId: senderEmail,
                                    displayName: name)

                return Message(sender: sender,
                               messageId: messageID,
                               sentDate: date,
                               kind: finalKind,
                               type: type)
            })

            completion(.success(messages))
        })
    }

    /// Sends a message with target conversation and message
    public func sendMessage(to conversation: String, otherUserEmail: String, name: String, newMessage: Message, completion: @escaping (Bool) -> Void) {
        // add new message to messages
        // update sender latest message
        // update recipient latest message

        guard let myEmail = UserDefaults.standard.value(forKey: "email") as? String else {
            completion(false)
            return
        }

        let currentEmail = DatabaseManager.safeEmail(emailAddress: myEmail)

        realDatabase.child("\(conversation)/messages").observeSingleEvent(of: .value, with: { [weak self] snapshot in
            guard let strongSelf = self else {
                return
            }

            guard var currentMessages = snapshot.value as? [[String: Any]] else {
                completion(false)
                return
            }

            let messageDate = newMessage.sentDate
            let dateString = ChatViewController.dateFormatter.string(from: messageDate)
            var message = ""
            switch newMessage.kind {
            case .text(let messageText):
                message = messageText
                break
            case .attributedText(_):
                break
            case .photo(let mediaItem):
                if let targetUrlString = mediaItem.url?.absoluteString {
                    message = targetUrlString
                }
                break
            case .video(let mediaItem):
                if let targetUrlString = mediaItem.url?.absoluteString {
                    message = targetUrlString
                }
                break
            case .location(let locationData):
                let location = locationData.location
                message = "\(location.coordinate.longitude),\(location.coordinate.latitude)"
                break
            case .emoji(_):
                break
            case .audio(_):
                break
            case .contact(_):
                break
//            case .custom(let privatelink):
//                let privatelink = privatelink as? PrivateLink
//                message = "\(privatelink?.title), \(privatelink?.desciption), \(privatelink?.date), \(privatelink?.locationTitle), \(privatelink?.coordinates?.latitude), \(privatelink?.coordinates?.longitude)"
//                break
            case .linkPreview(_):
                break
            case .custom(_):
                break
            }

            guard let myEmmail = UserDefaults.standard.value(forKey: "email") as? String else {
                completion(false)
                return
            }

            let currentUserEmail = DatabaseManager.safeEmail(emailAddress: myEmmail)

            let newMessageEntry: [String: Any] = [
                "id": newMessage.messageId,
                "type": newMessage.kind.messageKindString,
                "content": message,
                "date": dateString,
                "sender_email": currentUserEmail,
                "is_read": false,
                "name": name
            ]

            currentMessages.append(newMessageEntry)

            strongSelf.realDatabase.child("\(conversation)/messages").setValue(currentMessages) { error, _ in
                guard error == nil else {
                    completion(false)
                    return
                }

                strongSelf.realDatabase.child("\(currentEmail)/conversations").observeSingleEvent(of: .value, with: { snapshot in
                    var databaseEntryConversations = [[String: Any]]()
                    let updatedValue: [String: Any] = [
                        "date": dateString,
                        "is_read": false,
                        "message": message
                    ]

                    if var currentUserConversations = snapshot.value as? [[String: Any]] {
                        var targetConversation: [String: Any]?
                        var position = 0

                        for conversationDictionary in currentUserConversations {
                            if let currentId = conversationDictionary["id"] as? String, currentId == conversation {
                                targetConversation = conversationDictionary
                                break
                            }
                            position += 1
                        }

                        if var targetConversation = targetConversation {
                            targetConversation["latest_message"] = updatedValue
                            currentUserConversations[position] = targetConversation
                            databaseEntryConversations = currentUserConversations
                        }
                        else {
                            let newConversationData: [String: Any] = [
                                "id": conversation,
                                "other_user_email": DatabaseManager.safeEmail(emailAddress: otherUserEmail),
                                "name": name,
                                "latest_message": updatedValue
                            ]
                            currentUserConversations.append(newConversationData)
                            databaseEntryConversations = currentUserConversations
                        }
                    }
                    else {
                        let newConversationData: [String: Any] = [
                            "id": conversation,
                            "other_user_email": DatabaseManager.safeEmail(emailAddress: otherUserEmail),
                            "name": name,
                            "latest_message": updatedValue
                        ]
                        databaseEntryConversations = [
                            newConversationData
                        ]
                    }

                    strongSelf.realDatabase.child("\(currentEmail)/conversations").setValue(databaseEntryConversations, withCompletionBlock: { error, _ in
                        guard error == nil else {
                            completion(false)
                            return
                        }


                        // Update latest message for recipient user

                        strongSelf.realDatabase.child("\(otherUserEmail)/conversations").observeSingleEvent(of: .value, with: { snapshot in
                            let updatedValue: [String: Any] = [
                                "date": dateString,
                                "is_read": false,
                                "message": message
                            ]
                            var databaseEntryConversations = [[String: Any]]()

                            guard let currentName = UserDefaults.standard.value(forKey: "username") as? String else {
                                return
                            }

                            if var otherUserConversations = snapshot.value as? [[String: Any]] {
                                var targetConversation: [String: Any]?
                                var position = 0

                                for conversationDictionary in otherUserConversations {
                                    if let currentId = conversationDictionary["id"] as? String, currentId == conversation {
                                        targetConversation = conversationDictionary
                                        break
                                    }
                                    position += 1
                                }

                                if var targetConversation = targetConversation {
                                    targetConversation["latest_message"] = updatedValue
                                    otherUserConversations[position] = targetConversation
                                    databaseEntryConversations = otherUserConversations
                                }
                                else {
                                    // failed to find in current colleciton
                                    let newConversationData: [String: Any] = [
                                        "id": conversation,
                                        "other_user_email": DatabaseManager.safeEmail(emailAddress: currentEmail),
                                        "name": currentName,
                                        "latest_message": updatedValue
                                    ]
                                    otherUserConversations.append(newConversationData)
                                    databaseEntryConversations = otherUserConversations
                                }
                            }
                            else {
                                // current collection does not exist
                                let newConversationData: [String: Any] = [
                                    "id": conversation,
                                    "other_user_email": DatabaseManager.safeEmail(emailAddress: currentEmail),
                                    "name": currentName,
                                    "latest_message": updatedValue
                                ]
                                databaseEntryConversations = [
                                    newConversationData
                                ]
                            }

                            strongSelf.realDatabase.child("\(otherUserEmail)/conversations").setValue(databaseEntryConversations, withCompletionBlock: { error, _ in
                                guard error == nil else {
                                    completion(false)
                                    return
                                }

                                completion(true)
                            })
                        })
                    })
                })
            }
        })
    }

    public func deleteConversation(conversationId: String, completion: @escaping (Bool) -> Void) {
        guard let email = UserDefaults.standard.value(forKey: "email") as? String else {
            return
        }
        let safeEmail = DatabaseManager.safeEmail(emailAddress: email)

        print("Deleting conversation with id: \(conversationId)")

        // Get all conversations for current user
        // delete conversation in collection with target id
        // reset those conversations for the user in database
        let ref = realDatabase.child("\(safeEmail)/conversations")
        ref.observeSingleEvent(of: .value) { snapshot in
            if var conversations = snapshot.value as? [[String: Any]] {
                var positionToRemove = 0
                for conversation in conversations {
                    if let id = conversation["id"] as? String,
                        id == conversationId {
                        print("found conversation to delete")
                        break
                    }
                    positionToRemove += 1
                }

                conversations.remove(at: positionToRemove)
                ref.setValue(conversations, withCompletionBlock: { error, _  in
                    guard error == nil else {
                        completion(false)
                        print("faield to write new conversatino array")
                        return
                    }
                    print("deleted conversaiton")
                    completion(true)
                })
            }
        }
    }

    public func conversationExists(iwth targetRecipientEmail: String, completion: @escaping (Result<String, Error>) -> Void) {
        let safeRecipientEmail = DatabaseManager.safeEmail(emailAddress: targetRecipientEmail)
        guard let senderEmail = UserDefaults.standard.value(forKey: "email") as? String else {
            return
        }
        let safeSenderEmail = DatabaseManager.safeEmail(emailAddress: senderEmail)

        realDatabase.child("\(safeRecipientEmail)/conversations").observeSingleEvent(of: .value, with: { snapshot in
            guard let collection = snapshot.value as? [[String: Any]] else {
                completion(.failure(DatabaseError.failedToFetch))
                return
            }

            // iterate and find conversation with target sender
            if let conversation = collection.first(where: {
                guard let targetSenderEmail = $0["other_user_email"] as? String else {
                    return false
                }
                return safeSenderEmail == targetSenderEmail
            }) {
                // get id
                guard let id = conversation["id"] as? String else {
                    completion(.failure(DatabaseError.failedToFetch))
                    return
                }
                completion(.success(id))
                return
            }

            completion(.failure(DatabaseError.failedToFetch))
            return
        })
    }

}

struct ChatAppUser {
    let username: String
    let emailAddress: String

    var safeEmail: String {
        var safeEmail = emailAddress.replacingOccurrences(of: ".", with: "-")
        safeEmail = safeEmail.replacingOccurrences(of: "@", with: "-")
        return safeEmail
    }

    var profilePictureFileName: String {
        //afraz9-gmail-com_profile_picture.png
        return "\(safeEmail)_profile_picture.png"
    }
}
