import Foundation
import UIKit


/*
 
- By default, Swift's `Codable` expects JSON keys to match your property names exactly, but sometimes you want to:
    - Use different names in Swift than what the API provides
    - Use Swift naming conventions (camelCase) instead of API conventions (snake_case)
    - Skip certain fields you don't need
    - Combine or transform data during decoding
 
- CodingKeys must be:
    - A nested enum inside your struct
    - Conform to `CodingKey` protocol
    - Have `String` as its raw value type
 
- The enum **case names** match your Swift property names
 
- The enum **raw values** (strings) match the JSON keys.

*/

struct SimplifiedUser: Decodable { // Decode only!
    let id: Int
    let fullName: String         // Computed from firstName + lastName
    let profileImage: String     // Renamed from "image" in JSON
    let age: Int
    let email: String
    
//    var randomAIFaceURL: URL? {
//        // Generates an arbitrary string padding like "0065243" to match their database address format
//        let randomPhotoID = String(format: "%07d", Int.random(in: 1...99999))
//        return URL(string: "https://generated.photos\(randomPhotoID).jpg")
//    }
    
    var loadedFaceImage: UIImage? = nil
    

    // This enum maps JSON keys to Swift properties
    enum CodingKeys: String, CodingKey {
        case id                  // When case name = raw value, you can omit the string
        case firstName           // We need these to compute fullName
        case lastName
        case profileImage = "image"  // Maps JSON "image" to Swift "profileImage"
        case age
        case email
    }

   
    // Custom initializer to handle the decoding
    init(from decoder: Decoder) throws {
        // Get the main container using our CodingKeys
        let container = try decoder.container(keyedBy: CodingKeys.self)

        // Decode simple properties
        self.id = try container.decode(Int.self, forKey: .id)

        // Decode and combine firstName + lastName into fullName
        let firstName = try container.decode(String.self, forKey: .firstName)
        let lastName = try container.decode(String.self, forKey: .lastName)
        self.fullName = "\(firstName) \(lastName)"

        // Decode with renamed key
        self.profileImage = try container.decode(String.self, forKey: .profileImage)
        
        // Decode age
        self.age = try container.decode(Int.self, forKey: .age)
        
        // Decode email
        self.email = try container.decode(String.self, forKey: .email)

    }
}
