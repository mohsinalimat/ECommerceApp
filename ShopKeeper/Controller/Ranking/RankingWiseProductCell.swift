//
//  RankingWiseProductCell.swift
//  ShopKeeper
//
//  Created by Vivek Gupta on 20/05/18.
//  Copyright © 2018 Vivek Gupta. All rights reserved.
//

import UIKit

class RankingWiseProductCell: UICollectionViewCell {

    @IBOutlet weak var productName: UILabel!
    
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var countLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.imageView.image = nil
    }

}
