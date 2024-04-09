//
//  ProductListCell.swift
//  iOSPracticalTest
//
//  Created by Bhavin's on 08/04/24.
//

import UIKit

protocol ProductListCellDelegate: AnyObject {
    func didIncrementButtonTapped(for cell: ProductListCell)
    func didDecrementButtonTapped(for cell: ProductListCell)
}

class ProductListCell: UITableViewCell {

    // MARK: - Outlets
    
    @IBOutlet weak var productIDLabel: UILabel!
    @IBOutlet weak var productTitleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var decrementButton: UIButton!
    @IBOutlet weak var incrementButton: UIButton!
    @IBOutlet weak var counterLabel: UILabel!
    @IBOutlet weak var containerView: UIView!

    // MARK: - Properties
    
    var productData: Product? {
        didSet {
            productDetailConfiguration()
        }
    }
    
    weak var delegate: ProductListCellDelegate?

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
        guard let productData = productData else { return }

        productIDLabel.text = "\(productData.id ?? 0)"
        productTitleLabel.text = productData.title
        descriptionLabel.text = productData.description
        counterLabel.text = "0" // Initially set to 0
    }
    
    // MARK: - Actions
    
    @IBAction func decrementButtonTapped(_ sender: Any) {
        delegate?.didDecrementButtonTapped(for: self)
    }
    
    @IBAction func incrementButtonTapped(_ sender: Any) {
        delegate?.didIncrementButtonTapped(for: self)
    }
}
