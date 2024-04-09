//
//  ProductListViewController.swift
//  iOSPracticalTest
//
//  Created by Bhavin's on 08/04/24.
//

import UIKit
import CoreData

class ProductListViewController: UIViewController {

    // MARK: - Properties

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    private let manager =  DatabaseManager()
    var product: ProductEntity?

    private var items: [ProductEntity] = []

    @IBOutlet weak var productTableView: UITableView!
   
    @IBOutlet weak var viewCartCounter: UIView!

    
    @IBOutlet weak var labelCartCounter: UILabel! {
        didSet {
            updateCartCounterLabel()
        }
    }

    private var productQuantities: [Int: Int] = [:] {
        didSet {
            updateCartCounterLabel()
        }
    }
    
    private let viewModel = ProductListViewModel()
    private var products: [Product] = []
    
    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        tableviewViewSetup()
        configuration()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Fetch data from CoreData and update products array
        items = manager.fetchProduct()
        
        // Update productQuantities
        productQuantities.removeAll()
        for item in items {
            let id = item.id
            productQuantities[Int(id)] = Int(item.quantity)
        }

        // Reload table view
        productTableView.reloadData()
        
        // Fetch data from API
        viewModel.fetchProducts()
    }

    // MARK: - UI Setup
    
    private func setupUI() {
        viewCartCounter.layer.cornerRadius = viewCartCounter.frame.size.height / 2
        viewCartCounter.layer.borderWidth = 2
        viewCartCounter.layer.borderColor = UIColor.red.cgColor
        viewCartCounter.layer.masksToBounds = true
    }
    
    private func tableviewViewSetup() {
        productTableView.delegate = self
        productTableView.dataSource = self
    }
    
    // MARK: - Helper Methods

    private func updateCartCounterLabel() {
        let totalCount = productQuantities.values.reduce(0, +)
        labelCartCounter.text = "\(totalCount)"
    }
    
    func showAlert(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okay = UIAlertAction(title: "Ok", style: .default)
        alertController.addAction(okay)
        present(alertController, animated: true)
    }

    // MARK: - Action Methods

    @IBAction func cart_Clicked(_ sender: Any) {
        if items.isEmpty {
            showAlert(title: "iOSTest", message: "No item available")
        } else {
            if let vc = self.storyboard?.instantiateViewController(withIdentifier: "CartListViewController") as? CartListViewController {
                // Pass selected products to CartListViewController
                let selectedProducts = products.filter { productQuantities[$0.id ?? 0] ?? 0 > 0 }
                vc.cartProducts = selectedProducts
                // Pass product quantities to CartListViewController
                vc.productListProductQuantities = productQuantities
                
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
}

extension ProductListViewController {
    
    // MARK: - Configuration
    
    func configuration() {
        productTableView.register(UINib(nibName: "ProductListCell", bundle: nil), forCellReuseIdentifier: "ProductListCell")
        observeEvent()
    }
    
    // MARK: - Event Observation
    
    func observeEvent() {
        viewModel.eventHandler = { [weak self] event in
            guard let self = self else { return }
            switch event {
            case .loading:
                print("Product loading....")
            case .stopLoading:
                print("Stop loading...")
            case .dataLoaded:
                print("Data loaded...")
                self.products = self.viewModel.productsData?.products ?? []
                DispatchQueue.main.async {
                    self.productTableView.reloadData()
                }
            case .error(let error):
                print(error?.localizedDescription ?? "")
            case .coreDataProductsFetched(let products, let quantities):
                // Handle core data products fetched state if needed
                self.items = products
                self.productQuantities = quantities
                DispatchQueue.main.async {
                    self.productTableView.reloadData()
                    self.updateCartCounterLabel()
                }
            }
        }
    }
}

extension ProductListViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.products.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ProductListCell") as? ProductListCell else {
            return UITableViewCell()
        }
        
        let product = self.products[indexPath.row]
        cell.productData = product
        updateCounterLabel(for: cell, at: indexPath) // Update counter label initially
        cell.delegate = self // Set delegate

        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 150
    }

}

extension ProductListViewController: ProductListCellDelegate {
    
    func didIncrementButtonTapped(for cell: ProductListCell) {
        guard let indexPath = productTableView.indexPath(for: cell) else { return }
        let productId = products[indexPath.row].id ?? 0
        let productTitle = products[indexPath.row].title ?? ""
        let productDesc = products[indexPath.row].description ?? ""

        productQuantities[productId, default: 0] += 1
        updateCounterLabel(for: cell, at: indexPath)

        // Check if the product exists in CoreData
        let existingProduct = items.first(where: { $0.id == productId })
        if let existingProduct = existingProduct {
            // Update existing CoreData item
            let newQuantity = existingProduct.quantity + 1
            let updatedProduct = ProductModel(id: existingProduct.id,
                                              title: existingProduct.title ?? "",
                                              desc: existingProduct.desc ?? "",
                                              quantity: newQuantity)
            manager.updateProduct(product: updatedProduct, productEntity: existingProduct)
            items = manager.fetchProduct()
        } else {
            // Add new item to CoreData
            let newProduct = ProductModel(id: Int32(productId),
                                          title: productTitle,
                                          desc: productDesc,
                                          quantity: 1)
            manager.addProduct(newProduct)
            items = manager.fetchProduct()
        }
    }

    func didDecrementButtonTapped(for cell: ProductListCell) {
        guard let indexPath = productTableView.indexPath(for: cell) else { return }
        let productId = products[indexPath.row].id ?? 0
        if let quantity = productQuantities[productId], quantity > 0 {
            productQuantities[productId] = quantity - 1
            updateCounterLabel(for: cell, at: indexPath)
        }
        
        // Remove item from CoreData
        guard let existingProductIndex = items.firstIndex(where: { $0.id == productId }) else { return                 // Show alert if quantity becomes zero again
            showAlert(title: "iOSTest", message: "No item available")
            
        }
        
        // Check if the product exists in CoreData
        let existingProduct = items.first(where: { $0.id == productId })
        if let existingProduct = existingProduct {
            let newQuantity = existingProduct.quantity - 1
            
            if newQuantity == 0 {
                // Delete existing CoreData item
                self.manager.deleteProduct(productEntity: existingProduct)
                items.remove(at: existingProductIndex) // Remove using existing index
                
                // Update users array
                items = manager.fetchProduct()
                
            } else {
                // Update existing CoreData item
                let updatedProduct = ProductModel(id: existingProduct.id,
                                                  title: existingProduct.title ?? "",
                                                  desc: existingProduct.desc ?? "",
                                                  quantity: newQuantity)
                manager.updateProduct(product: updatedProduct, productEntity: existingProduct)
                items = manager.fetchProduct()
            }
        } else {
            // Add new item to CoreData
            showAlert(title: "iOSTest", message: "No item available")
        }
    }

    
    private func updateCounterLabel(for cell: ProductListCell, at indexPath: IndexPath) {
        let productId = products[indexPath.row].id ?? 0
        cell.counterLabel.text = "\(productQuantities[productId] ?? 0)"
    }
}
