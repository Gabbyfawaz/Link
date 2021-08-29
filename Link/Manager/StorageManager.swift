//
//  StorageManager.swift
//  Link
//
//  Created by Gabriella Fawaz on 2021/07/22.
//

import Foundation
import FirebaseStorage

/// Object to interface with firebase storage
final class StorageManager {
    static let shared = StorageManager()

    private init() {}

    private let storage = Storage.storage().reference()
    /// Upload post image
    /// - Parameters:
    ///   - data: Image data
    ///   - id: New post id
    ///   - completion: Result callback
    public func uploadPost(
        data: Data?,
        id: String,
        completion: @escaping (URL?) -> Void
    ) {
        guard let username = UserDefaults.standard.string(forKey: "username"),
              let data = data else {
            return
        }
        let ref = storage.child("\(username)/posts/\(id).png")
        ref.putData(data, metadata: nil) { _, error in
            ref.downloadURL { url, _ in
                completion(url)
            }
        }
    }
    
    
    
    public func uploadLinkPosts(
        data: [Data]?,
        id: String,
        completion: @escaping ([URL]?) -> Void
    ) {
        
        var urls = [URL]()
        let group = DispatchGroup()
        guard let username = UserDefaults.standard.string(forKey: "username"),
              let data = data else {
            return
        }
        

        data.forEach({ dataItem in
            group.enter()
            
        
            let ref = storage.child("\(username)/linkPosts/\(dataItem)/\(id).png")
            ref.putData(dataItem, metadata: nil) { _, error in
                ref.downloadURL { url, _ in
                    
                    guard let postUrl = url else {
                        return
                    }
                    
                    defer {
                        group.leave()
                    }
                 
                    urls.append(postUrl)
//                            print("postURL: \(postUrl)")
                    
                }
            }
        })
        

        
        
        group.notify(queue: .main) {
            print("URLS: \(urls)")
            completion(urls)
        }

    }
    
    
    public func uploadLinkPost(
        data: Data?,
        id: String,
        completion: @escaping (URL?) -> Void
    ) {
        guard let username = UserDefaults.standard.string(forKey: "username"),
              let data = data else {
            return
        }
        let ref = storage.child("\(username)/linkPosts/\(id).png")
        ref.putData(data, metadata: nil) { _, error in
            ref.downloadURL { url, _ in
                completion(url)
            }
        }
    }
    
    public func uploadLinkTypeImage(
        data: Data?,
        id: String,
        completion: @escaping (URL?) -> Void
    ) {
        guard let username = UserDefaults.standard.string(forKey: "username"),
              let data = data else {
            return
        }
        let ref = storage.child("\(username)/linkPosts/linkTypeImage\(id).png")
        ref.putData(data, metadata: nil) { _, error in
            ref.downloadURL { url, _ in
                completion(url)
            }
        }
    }
    
    
//    public func downloadURLS(for link: LinkModel, completion: @escaping ([URL]?) -> Void) {
//        guard let ref = link.storageReferences else {
//            completion(nil)
//            return
//        }
//        var arrayURL = [URL]()
//        ref.forEach({ refId in
//            storage.child(refId).downloadURL { url, _ in
//               guard let postURL = url else {
//                    return
//                }
//                arrayURL.append(postURL)
//            }
//
//        })
//        completion(arrayURL)
//    }

    public func downloadURL(for post: Post, completion: @escaping (URL?) -> Void) {
        guard let ref = post.storageReference else {
            completion(nil)
            return
        }
        
        storage.child(ref).downloadURL { url, _ in
            completion(url)
        }
    }

    public func profilePictureURL(for username: String, completion: @escaping (URL?) -> Void) {
        storage.child("\(username)/profile_picture.png").downloadURL { url, _ in
            completion(url)
        }
    }
    
//    public func linkPostPictureURL(for username: String, completion: @escaping (URL?) -> Void) {
//        storage.child("\(username)/profile_picture.png").downloadURL { url, _ in
//            completion(url)
//        }
//    }

    public func uploadProfilePicture(
        username: String,
        data: Data?,
        completion: @escaping (Bool) -> Void
    ) {
        guard let data = data else {
            return
        }
        storage.child("\(username)/profile_picture.png").putData(data, metadata: nil) { _, error in
            completion(error == nil)
        }
    }
    
    public func uploadBackgroundImage(
        username: String,
        data: Data?,
        completion: @escaping (Bool) -> Void
    ) {
        guard let data = data else {
            return
        }
        storage.child("\(username)/background_image.png").putData(data, metadata: nil) { _, error in
            completion(error == nil)
        }
    }
}


extension StorageManager {
    
    public typealias UploadPictureCompletion = (Result<String, Error>) -> Void
    
    /// Upload image that will be sent in a conversation message
    public func uploadMessagePhoto(with data: Data, fileName: String, completion: @escaping UploadPictureCompletion) {
        storage.child("message_images/\(fileName)").putData(data, metadata: nil, completion: { [weak self] metadata, error in
            guard error == nil else {
                // failed
                print("failed to upload data to firebase for picture")
                completion(.failure(StorageErrors.failedToUpload))
                return
            }

            self?.storage.child("message_images/\(fileName)").downloadURL(completion: { url, error in
                guard let url = url else {
                    print("Failed to get download url")
                    completion(.failure(StorageErrors.failedToGetDownloadUrl))
                    return
                }

                let urlString = url.absoluteString
                print("download url returned: \(urlString)")
                completion(.success(urlString))
            })
        })
    }

    /// Upload video that will be sent in a conversation message
    public func uploadMessageVideo(with fileUrl: URL, fileName: String, completion: @escaping UploadPictureCompletion) {
        storage.child("message_videos/\(fileName)").putFile(from: fileUrl, metadata: nil, completion: { [weak self] metadata, error in
            guard error == nil else {
                // failed
                print("failed to upload video file to firebase for picture")
                completion(.failure(StorageErrors.failedToUpload))
                return
            }

            self?.storage.child("message_videos/\(fileName)").downloadURL(completion: { url, error in
                guard let url = url else {
                    print("Failed to get download url")
                    completion(.failure(StorageErrors.failedToGetDownloadUrl))
                    return
                }

                let urlString = url.absoluteString
                print("download url returned: \(urlString)")
                completion(.success(urlString))
            })
        })
    }

    public enum StorageErrors: Error {
        case failedToUpload
        case failedToGetDownloadUrl
    }

    public func downloadURL(for path: String, completion: @escaping (Result<URL, Error>) -> Void) {
        let reference = storage.child(path)

        reference.downloadURL(completion: { url, error in
            guard let url = url, error == nil else {
                completion(.failure(StorageErrors.failedToGetDownloadUrl))
                return
            }

            completion(.success(url))
        })
    }

}

