//
//  DatabaseManager.swift
//  iOSTest
//
//  Created by Bhavin's on 08/04/24.
//

import UIKit
import CoreData

class DatabaseManager {

    // MARK: - Variables
    
    private var context: NSManagedObjectContext {
        return (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    }

    // MARK: - Methods
    
    func addProduct(_ product: ProductModel) {
        let productEntity = ProductEntity(context: context)
        addUpdateProduct(productEntity: productEntity, product: product)
    }

    func updateProduct(product: ProductModel, productEntity: ProductEntity) {
        addUpdateProduct(productEntity: productEntity, product: product)
    }

    private func addUpdateProduct(productEntity: ProductEntity, product: ProductModel) {
        productEntity.id = product.id
        productEntity.title = product.title
        productEntity.desc = product.desc
        productEntity.quantity = product.quantity
        saveContext()
    }

    func fetchProduct() -> [ProductEntity] {
        var products: [ProductEntity] = []

        do {
            products = try context.fetch(ProductEntity.fetchRequest())
        } catch {
            print("Fetch product error:", error)
        }

        return products
    }

    func saveContext() {
        do {
            try context.save()
        } catch {
            print("Save context error:", error)
        }
    }

    func deleteProduct(productEntity: ProductEntity) {
        context.delete(productEntity)
        saveContext()
    }
}
