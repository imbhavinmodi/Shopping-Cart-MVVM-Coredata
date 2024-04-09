//
//  CartListViewController.swift
//  iOSPracticalTest
//
//  Created by Bhavin's on 08/04/24.
//

import UIKit
import CoreData

class CartListViewController: UIViewController {

    // MARK: - Properties

    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    
    private let manager = DatabaseManager()
    
    private var items: [ProductEntity] = []
    
    var cartProducts: [Product] = [] // Property to hold selected products
    var productQuantities: [Int: Int] = [:] // Property to hold product quantities
    var productListProductQuantities: [Int: Int] = [:]
    
    // MARK: - Outlets
    
    @IBOutlet weak var cartTableView: UITableView!
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        fetchDataFromCoreData()
    }
    
    // MARK: - UI Setup
    
    private func setupTableView() {
        cartTableView.delegate = self
        cartTableView.dataSource = self
        cartTableView.register(UINib(nibName: "CartListCell", bundle: nil), forCellReuseIdentifier: "CartListCell")
        cartTableView.register(UINib(nibName: "CheckoutButtonCell", bundle: nil), forCellReuseIdentifier: "CheckoutButtonCell")
    }
    
    // MARK: - Data Handling
    
    private func fetchDataFromCoreData() {
        items = manager.fetchProduct()
        
        for item in items {
            // Directly unwrap user.id since it's not optional
            let id = item.id
            productQuantities[Int(id)] = Int(item.quantity)
        }
        
        cartTableView.reloadData()
    }
    
    // MARK: - Actions
    
    @IBAction func backTapped(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    // MARK: - Deinitializer
    
    deinit {
        print("CartListViewController is being deallocated")
    }
    
    // MARK: - Methods
    
    func deleteProductsAndShowAlert() {
        // Delete all items from CoreData
        for item in items {
            manager.deleteProduct(productEntity: item)
        }
        // Clear the items array after deleting from CoreData
        items.removeAll()
                
        showAlert(title: "Success", message: "Database Cleared!")
    }
    
    func showAlert(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okay = UIAlertAction(title: "Ok", style: .default) { _ in
            // Call the navigation function after the alert is dismissed
            self.navigateBack()
        }
        alertController.addAction(okay)
        present(alertController, animated: true)
    }
    
    func navigateBack() {
        // Navigate back to the previous view controller
        DispatchQueue.main.async {
            self.navigationController?.popViewController(animated: true)
        }
    }
}

extension CartListViewController: UITableViewDataSource, UITableViewDelegate {
    
    // MARK: - UITableViewDataSource Methods
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count + 1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == cartProducts.count {
            let cell = tableView.dequeueReusableCell(withIdentifier: "CheckoutButtonCell") as! CheckoutButtonCell
            cell.configureButton()
            cell.delegate = self
            return cell
        } else {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "CartListCell", for: indexPath) as? CartListCell else {
                return UITableViewCell()
            }
            
            let product = self.items[indexPath.row]
            cell.cartProduct = product

            return cell
        }
    }
    
    // MARK: - UITableViewDelegate Methods
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == cartProducts.count {
            return 80
        } else {
            return 120
        }
    }
}

extension CartListViewController: CheckoutButtonCellDelegate {
    
    // MARK: - CheckoutButtonCellDelegate Method
    
    func checkoutButtonTapped() {
        deleteProductsAndShowAlert()
    }
}
