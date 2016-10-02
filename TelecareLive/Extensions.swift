//
//  extensions.swift
//  TelecareLive
//
//  Created by Scott Metcalf on 9/28/16.
//  Copyright © 2016 Syworks LLC. All rights reserved.
//

import Foundation
import UIKit

extension UIImageView{
    func setImageFromURl(stringImageUrl url: String){
        if let url = URL(string: url) {
            if let data = try? Data.init(contentsOf: url as URL) {
                self.image = UIImage(data: data as Data)
            }
        }
    }
}

extension String {
    func fromBase64() -> String {
        let data = NSData(base64Encoded: self, options: NSData.Base64DecodingOptions(rawValue: 0))
        return String(data: data! as Data, encoding: String.Encoding.utf8)!
    }
    
    func toBase64() -> String {
        let data = self.data(using: String.Encoding.utf8)
        return data!.base64EncodedString(options: NSData.Base64EncodingOptions(rawValue: 0))
    }
}

extension Date {
    func toReadable() -> String {
        let myLocale = Locale.current
        let formatter = DateFormatter()
        formatter.locale = myLocale
        formatter.dateStyle = .medium
        formatter.timeStyle = .medium
        
        var calendar = Calendar(identifier: .gregorian)
        calendar.locale = myLocale
        
        
        //: ### Fetching `DateComponents` off a `Date`
        //: Notice how *a locale is needed for the month symbols to be reported correctly*
        let dateComponents = calendar.dateComponents([.day, .month, .year], from: self)
        let monthName = calendar.monthSymbols[dateComponents.month! - 1]
        return monthName + " " + String(dateComponents.day!) + "," +  " " + String(dateComponents.year!)
    }
    
    func fromString(string: String) -> Date {
        let dateformatter = DateFormatter()
        dateformatter.dateStyle = DateFormatter.Style.long
        
        return dateformatter.date(from: string)!
    }
}

extension UIImage {
    func toBase64() -> String {
        let data = UIImagePNGRepresentation(self)
        return (data?.base64EncodedString())!
    }
    
    func fromBase64(string: String) -> UIImage {
        let data = Data.init(base64Encoded: string)
        return UIImage.init(data: data!)!
    }
}
