//
//  BulkyTypes.swift
//  ARTesting
//
//  Created by Cuong Nguyen on 19/07/2023.
//

import Foundation

struct BulkyDimension {
    let width, height, depth: Float
    let title: String
}

enum BulkyTypes {
    case standard, tire1, tire2, tire3, overload
    
    func getBulkyDimension() -> BulkyDimension {
        switch self {
        case .standard:
            return BulkyDimension(width: 0.50, height: 0.40, depth: 0.50, title: "Tiêu chuẩn")
        case .tire1:
            return BulkyDimension(width: 0.60, height: 0.50, depth: 0.60, title: "Mức 1")
        case .tire2:
            return BulkyDimension(width: 0.70, height: 0.60, depth: 0.70, title: "Mức 2")
        case .tire3:
            return BulkyDimension(width: 0.90, height: 0.70, depth: 0.90, title: "Mức 3")
        case .overload:
            return BulkyDimension(width: 1.00, height: 0.80, depth: 1.00, title: "Quá tải trọng")
        }
    }
    
    static func parseBulkyDimension(bulkyDimension :BulkyDimension) -> BulkyTypes{
        if (bulkyDimension.width <= 0.60 && bulkyDimension.height <= 0.50 && bulkyDimension.depth <= 0.60){
            return BulkyTypes.standard
        }
        if (bulkyDimension.width <= 0.70 && bulkyDimension.height <= 0.60 && bulkyDimension.depth <= 0.70){
            return BulkyTypes.tire1
        }
        if (bulkyDimension.width <= 0.90 && bulkyDimension.height <= 0.70 && bulkyDimension.depth <= 0.90){
            return BulkyTypes.tire2
        }
        if (bulkyDimension.width <= 1.00 && bulkyDimension.height <= 0.80 && bulkyDimension.depth <= 1.00){
            return BulkyTypes.tire3
        }
        return BulkyTypes.overload
    }
}
