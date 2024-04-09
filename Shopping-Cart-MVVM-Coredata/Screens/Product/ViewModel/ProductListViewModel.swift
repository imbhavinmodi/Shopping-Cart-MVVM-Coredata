//
//  ProductListViewModel.swift
//  iOSPracticalTest
//
//  Created by Bhavin's on 08/04/24.
//

import Foundation
import CoreData

final class ProductListViewModel {

    // MARK: - Variables
    var productsData: ProductData?
    
    private let manager = DatabaseManager()

    var eventHandler: ((_ event: Event) -> Void)?

    func fetchProducts() {
        self.eventHandler?(.loading)
        APIManager.shared.request(
            modelType: ProductData.self,
            type: ProductEndPoint.products) { response in
                self.eventHandler?(.stopLoading)
                switch response {
                case .success(let productsData):
                    self.productsData = productsData
                    self.eventHandler?(.dataLoaded)
                case .failure(let error):
                    self.eventHandler?(.error(error))
                }
            }
    }
    
    // Fetch products from CoreData
    func fetchCoreDataProducts() {
        let items = manager.fetchProduct()
        let productQuantities = items.reduce(into: [Int: Int]()) { result, item in
            result[Int(item.id)] = Int(item.quantity)
        }
        eventHandler?(.coreDataProductsFetched(items, productQuantities))
    }

    // Add product to CoreData
    func addProductToCoreData(_ product: ProductModel) {
        manager.addProduct(product)
    }

    // Update product quantity in CoreData
    func updateProductQuantity(_ productId: Int, _ newQuantity: Int) {
        guard let product = manager.fetchProduct().first(where: { $0.id == productId }) else {
            return // Product not found
        }
        product.quantity = Int32(newQuantity)
        manager.saveContext()
    }

    // Delete product from CoreData
    func deleteProductFromCoreData(_ productEntity: ProductEntity) {
        manager.deleteProduct(productEntity: productEntity)
    }
}

// MARK: - Extension

extension ProductListViewModel {
    enum Event {
        case loading
        case stopLoading
        case dataLoaded
        case error(Error?)
        case coreDataProductsFetched([ProductEntity], [Int: Int])
    }
}

