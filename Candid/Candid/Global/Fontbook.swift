//
//  Fontbook.swift
//  Candid
//
//  Created by Rupinder on 04/05/21.
//

import UIKit
import Foundation

private let familyName = "GalanoClassic"

enum AppFont: String {
    case BoldItalic = "BoldItalic"
    case Regular = "Regular"
    case SemiBold = "SemiBold"
    case Medium = "Medium"
    case SemiBoldItalic = "SemiBoldItalic"
    case ExtraBoldItalic = "ExtraBoldItalic"

    func size(_ size: CGFloat) -> UIFont {
        if let font = UIFont(name: fullFontName, size: size + 1.0) {
            return font
        }
        fatalError("Font '\(fullFontName)' does not exist.")
    }
    fileprivate var fullFontName: String {
        return rawValue.isEmpty ? familyName : familyName + "-" + rawValue
    }
}
