//
//  UICollectionView+Additions.swift
//  ShopKeeper
//
//  Created by Vivek Gupta on 19/05/18.
//  Copyright © 2018 Vivek Gupta. All rights reserved.
//

import Foundation
import UIKit


protocol NibLoadableView: class { }

extension NibLoadableView where Self: UIView {
    static var nibName: String {
        return String(describing: self)
    }
}

protocol ReusableView: class {}

extension ReusableView where Self: UIView {
    
    static var reuseIdentifier: String {
        return String(describing: self)
    }
    
}
extension UICollectionReusableView: ReusableView { }

extension UICollectionReusableView: NibLoadableView { }

extension UICollectionView {
    
    func register<T: UICollectionViewCell>(_: T.Type)  {
        let nib = UINib(nibName: T.nibName, bundle: nil)
        register(nib, forCellWithReuseIdentifier: T.reuseIdentifier)
    }
    
    func dequeueReusableCell<T: UICollectionViewCell>(forIndexPath indexPath: IndexPath) -> T {
        guard let cell = dequeueReusableCell(withReuseIdentifier: T.reuseIdentifier, for: indexPath) as? T else {
            fatalError("Could not dequeue cell with identifier: \(T.reuseIdentifier)")
        }
        return cell
    }
    
    func register<T: UICollectionReusableView>(_: T.Type, forSupplementaryViewOfKind kind: String)  {
        let nib = UINib(nibName: T.nibName, bundle: nil)
        register(nib, forSupplementaryViewOfKind: kind, withReuseIdentifier: T.reuseIdentifier)
    }
    
    func dequeueReusableSupplementaryView<T: UICollectionReusableView>(forSupplementaryViewOfKind kind: String, forIndexPath indexPath: IndexPath) -> T {
        guard let cell = dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: T.reuseIdentifier, for: indexPath) as? T else {
            fatalError("Could not dequeue cell with identifier: \(T.reuseIdentifier)")
        }
        return cell
    }
}
