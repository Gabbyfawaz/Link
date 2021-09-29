//
//  Extension.swift
//  Link
//
//  Created by Gabriella Fawaz on 2021/07/22.
//

import Foundation
import UIKit


public  var myPurple: UIColor = #colorLiteral(red: 0.8822453618, green: 0.8364266753, blue: 0.9527176023, alpha: 1)



extension UIView {
    var top: CGFloat {
        frame.origin.y
    }

    var bottom: CGFloat {
        frame.origin.y+height
    }

    var left: CGFloat {
        frame.origin.x
    }

    var right: CGFloat {
        frame.origin.x+width
    }

    var width: CGFloat {
        frame.size.width
    }

    var height: CGFloat {
        frame.size.height
    }
}

extension Decodable {
    /// Create model with dictionary
    /// - Parameter dictionary: Firestore data
    init?(with dictionary: [String: Any]) {
        guard let data = try? JSONSerialization.data(
            withJSONObject: dictionary,
            options: .prettyPrinted
        ) else {
            return nil
        }
        guard let result = try? JSONDecoder().decode(
            Self.self,
            from: data
        ) else {
            return nil
        }
        self = result
    }
}

extension Encodable {
    /// Convert model to dictionary
    /// - Returns: Optional dictionary representation
    func asDictionary() -> [String: Any]? {
        guard let data = try? JSONEncoder().encode(self) else {
            return nil
        }
        let json = try? JSONSerialization.jsonObject(
            with: data,
            options: .allowFragments
        ) as? [String: Any]
        return json
    }
}

extension DateFormatter {
    /// Static date formatter
    static let formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter
    }()
}

extension String {
    /// Convert string from Date
    /// - Parameter date: Source date
    /// - Returns: String representation
    static func date(from date: Date) -> String? {
        let formatter = DateFormatter.formatter
        let string = formatter.string(from: date)
        return string
    }
}

extension Notification.Name {
    /// Notification to inform of new post
    static let didPostNotification = Notification.Name("didPostNotification")
    static let didLoginNotification = Notification.Name("didLoginNotification")
    static let didPostLinkNotification = Notification.Name("didPostLinkNotification")
    static let didPostLinkOnMap = Notification.Name("didPostLinkOnMap")
    
}


extension UIImage {
    
func addFilter(filter : FilterTypes) -> UIImage {
let filter = CIFilter(name: filter.rawValue)
// convert UIImage to CIImage and set as input
let ciInput = CIImage(image: self)
filter?.setValue(ciInput, forKey: "inputImage")
// get output CIImage, render as CGImage first to retain proper UIImage scale
let ciOutput = filter?.outputImage
let ciContext = CIContext()
let cgImage = ciContext.createCGImage(ciOutput!, from: (ciOutput?.extent)!)
//Return the image
return UIImage(cgImage: cgImage!)
}
    
    
}


public enum FilterTypes: String {
    case Chrome = "CIPhotoEffectChrome"
    case Fade = "CIPhotoEffectFade"
    case Instant = "CIPhotoEffectInstant"
    case Mono = "CIPhotoEffectMono"
    case Noir = "CIPhotoEffectNoir"
    case Process = "CIPhotoEffectProcess"
    case Tonal = "CIPhotoEffectTonal"
    case Transfer =  "CIPhotoEffectTransfer"
}  

extension UIView {
    func roundCorners(corners:UIRectCorner, radius: CGFloat) {
        let path = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        layer.mask = mask
    }
}
