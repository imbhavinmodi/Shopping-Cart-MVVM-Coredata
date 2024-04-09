//
//  CheckoutButtonCell.swift
//  iOSPracticalTest
//
//  Created by Bhavin's on 08/04/24.
//

import UIKit

protocol CheckoutButtonCellDelegate: AnyObject {
    func checkoutButtonTapped()
}

class CheckoutButtonCell: UITableViewCell {
    
    // MARK: - Outlets
    
    @IBOutlet weak var checkoutButton: UIButton!
    
    // MARK: - Properties
    
    weak var delegate: CheckoutButtonCellDelegate?

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
    
    func configureButton() {
        // Configure button appearance
        checkoutButton.setTitle("Checkout", for: .normal)
        checkoutButton.setTitleColor(.white, for: .normal)
        checkoutButton.backgroundColor = UIColor(named: "primaryColor")
        checkoutButton.addTarget(self, action: #selector(checkoutButtonAction), for: .touchUpInside)
    }
    
    // MARK: - Actions
    
    @objc func checkoutButtonAction() {
        delegate?.checkoutButtonTapped()
    }
}
