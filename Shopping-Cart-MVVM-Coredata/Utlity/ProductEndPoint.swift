//
//  ProductEndPoint.swift
//  iOSPracticalTest
//
//  Created by Bhavin's on 08/04/24.
//

import Foundation

enum ProductEndPoint {
    case products
}

extension ProductEndPoint: EndPointType {

    // MARK: - Properties
    
    var path: String {
        switch self {
        case .products:
            return "products"
        }
    }

    var baseURL: String {
        switch self {
        case .products:
            return "https://dummyjson.com/"
        }
    }

    var url: URL? {
        return URL(string: "\(baseURL)\(path)")
    }

    var method: HTTPMethods {
        switch self {
        case .products:
            return .get
        }
    }

    var body: Encodable? {
        switch self {
        case .products:
            return nil
        }
    }

    var headers: [String : String]? {
        APIManager.commonHeaders
    }
}

