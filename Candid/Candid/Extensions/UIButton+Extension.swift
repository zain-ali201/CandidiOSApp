//
//  UIButton+Extension.swift
//  Stesso
//
//  Created by Stesso on 2020/3/29.
//  Copyright © 2020 Stesso. All rights reserved.
//

import UIKit

extension UIButton{
    open override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        
        let minimumHitArea = CGSize(width: 40, height: 40)
        if self.isHidden || !self.isUserInteractionEnabled || self.alpha < 0.01{
            return nil
        }
        
        let buttonSize = self.bounds.size
        let widthToAdd = max(minimumHitArea.width - buttonSize.width, 0)
        let heightToAdd = max(minimumHitArea.height - buttonSize.height, 0)
        let largerFrame = self.bounds.insetBy(dx: -widthToAdd / 2, dy: -heightToAdd / 2)
        return (largerFrame.contains(point)) ? self: nil
    }
}

func gradient(view: UIView, radius: CGFloat, width: CGFloat = 4) -> CAGradientLayer{
    let gradient = CAGradientLayer()
    gradient.frame = CGRect(origin: CGPoint.zero, size: view.frame.size)
    gradient.startPoint = CGPoint(x: 0, y: 0.5)
    gradient.endPoint = CGPoint(x: 1, y: 0.5)
    gradient.colors = [UIColor(red: 247 / 255, green: 58 / 255, blue: 196 / 255, alpha: 1.0).cgColor, UIColor(red: 55 / 255, green: 158 / 255, blue: 246 / 255, alpha: 1.0).cgColor, UIColor(red: 245 / 255, green: 249 / 255, blue: 70 / 255, alpha: 1.0).cgColor, UIColor(red: 243 / 255, green: 78 / 255, blue: 78 / 255, alpha: 1.0).cgColor]
    let shape = CAShapeLayer()
    shape.lineWidth = width
//    shape.path = UIBezierPath(rect: view.bounds).cgPath
    shape.path = UIBezierPath(roundedRect: view.bounds, cornerRadius: radius).cgPath
    shape.strokeColor = UIColor.black.cgColor
    shape.fillColor = UIColor.clear.cgColor
    gradient.mask = shape
    return gradient
}
