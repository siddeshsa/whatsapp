//
//  HelperFunctions.swift
//  WhatsappBySid
//
//  Created by mac on 20/04/20.
//  Copyright © 2020 mac. All rights reserved.
//

import Foundation
import UIKit
import FirebaseFirestore

//MARK: GLOBAL FUNCTIONS
private let dateFormat = "yyyyMMddHHmmss"

func dateFormatter() -> DateFormatter {
    let dateFormatter = DateFormatter()
    dateFormatter.timeZone = TimeZone(secondsFromGMT: TimeZone.current.secondsFromGMT())
    dateFormatter.dateFormat = dateFormat
    return dateFormatter
}

func imageFromInitials(firstname: String?, lastname: String?, withBlock: @escaping (_ image: UIImage)-> Void) {
    var string: String!
    var size = 36
    
    if firstname != nil && lastname != nil {
        string = String(firstname!.first!).uppercased() + String(lastname!.first!).uppercased()
    }else{
        string = String(firstname!.first!).uppercased()
        size = 72
    }
    
    let lblNameInitialize = UILabel()
    lblNameInitialize.frame.size = CGSize(width: 100, height: 100)
    lblNameInitialize.textColor = .white
    lblNameInitialize.font = UIFont(name: lblNameInitialize.font.fontName, size: CGFloat(size))
    lblNameInitialize.text = string
    lblNameInitialize.textAlignment = NSTextAlignment.center
    lblNameInitialize.backgroundColor = UIColor.lightGray
    lblNameInitialize.layer.cornerRadius = 25
    
    UIGraphicsBeginImageContext(lblNameInitialize.frame.size)
    lblNameInitialize.layer.render(in: UIGraphicsGetCurrentContext()!)
    
    let img = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    withBlock(img!)
    }

func imageFromData(pictureData: String,withBlock: (_ image:UIImage?) -> Void ){
    var image : UIImage?
    let decodeData = NSData(base64Encoded: pictureData, options: NSData.Base64DecodingOptions(rawValue: 0))
    image = UIImage(data: decodeData! as Data)
    withBlock(image)
}


//MARK: UIImageExtension

extension UIImage{
    
    var isPortrait: Bool { return size.height > size.width }
    var isLandscape: Bool { return size.width > size.height }
    var breadth: CGFloat { return min(size.width, size.height)}
    var breadthSize: CGSize { return CGSize(width: breadth, height: breadth)}
    var breadthRect: CGRect { return CGRect(origin: .zero, size: breadthSize)}
    
    var circleMasked: UIImage? {
        UIGraphicsBeginImageContextWithOptions(breadthSize, false, scale)
        defer {UIGraphicsEndImageContext()}
        guard let cgImage = cgImage?.cropping(to: CGRect(origin: CGPoint(x: isLandscape ? floor((size.width - size.height) / 2) : 0, y: isPortrait  ? floor((size.height - size.width) / 2) : 0), size: breadthSize)) else { return nil }
        UIBezierPath(ovalIn: breadthRect).addClip()
        UIImage(cgImage: cgImage).draw(in: breadthRect)
        return UIGraphicsGetImageFromCurrentImageContext()
    }

 
}
