//
//  UIImage+Resize.swift
//  StartIt
//
//  Created by Булат Мусин on 30.10.2023.
//

import UIKit

extension UIImage {
    func resizeImage(targetSize: CGSize) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: targetSize)
        return renderer.image { (context) in
            self.draw(in: CGRect(origin: .zero, size: targetSize))
        }
    }
    
    func normalizeByWidth(targetWidth width: CGFloat) -> UIImage {
        let parameter = width / self.size.width
        let newImage = self.resizeImage(targetSize: CGSize(
            width: self.size.width * parameter,
            height: self.size.height * parameter
        ))
        return newImage
    }
}
