//
//  CartListCell.swift
//  iOSPracticalTest
//
//  Created by Bhavin's on 08/04/24.
//

import UIKit

class CartListCell: UITableViewCell {
    
    // MARK: - Outlets
    
    @IBOutlet weak var productIDLabel: UILabel!
    @IBOutlet weak var productTitleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var quantityLabel: UILabel!

    // MARK: - Properties
    
    var cartProduct: ProductEntity? {
        didSet {
            productDetailConfiguration()
        }
    }
        
    // MARK: - Lifecycle
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }

    // MARK: - Configuration
    
    func productDetailConfiguration() {
        guard let cartProduct = cartProduct else { return }

        productIDLabel.text = "\(cartProduct.id)"
        productTitleLabel.text = cartProduct.title
        descriptionLabel.text = cartProduct.desc
        quantityLabel.text = "\(cartProduct.quantity)"
    }
}
