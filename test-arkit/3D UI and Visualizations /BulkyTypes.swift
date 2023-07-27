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
    
    func parseBulkyiDimension(bulkyDimens: BulkyDimension) -> BulkyTypes{
        if(bulkyDimens.width <= 0.60 && bulkyDimens.height <= 0.50, bulkyDimens.depth <= 0.60){
            return BulkyTypes.standard
        }
        if(bulkyDimens.width <= 0.70 && bulkyDimens.height <= 0.60 && bulkyDimens.depth <= 0.70){
            return BulkyTypes.tire1
        }if(bulkyDimens.width <= 0.90 && bulkyDimens.height <= 0.70 && bulkyDimens.depth <= 0.90){
            return BulkyTypes.tire2
        }if(bulkyDimens.width <= 1.00 && bulkyDimens.height <= 0.80 && bulkyDimens.depth <= 1.00){
            return BulkyTypes.tire3
        }
        return BulkyTypes.overload
    }
}
