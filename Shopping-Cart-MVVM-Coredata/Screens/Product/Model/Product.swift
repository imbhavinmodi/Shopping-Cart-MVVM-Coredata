//
//  Product.swift
//  iOSPracticalTest
//
//  Created by Bhavin's on 08/04/24.
//

import Foundation

// MARK: - Products
struct ProductData: Codable {
    var products: [Product]?
    var total, skip, limit: Int?
}

// MARK: - Product
struct Product: Codable, Equatable {
    var id: Int?
    var title, description: String?
    var price: Int?
    var discountPercentage, rating: Double?
    var stock: Int?
    var brand, category: String?
    var thumbnail: String?
    var images: [String]?
}
