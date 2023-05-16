//
//  Manager.swift
//  StocksApp
//
//  Created by Zhandos38 on 05.10.2022.
//

import Foundation
import UIKit
import CoreData
import Alamofire

struct Manager {
    static let shared = Manager()
    private let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    var stocks: [Stock] {
        var stockList = [Stock]()
        if isEmpty {
            var stockArray = [Stock]()
            for i in 0..<Constants.symbols.count {
                let stock = Stock(context: context)
                stock.id = Double(i)
                stock.symbol = Constants.symbols[i]
                stock.company = Constants.companies[i]
                stock.logo = Constants.logos[i]
                stockArray.append(stock)
                do {
                    try context.save()
                } catch {
                    print("Error saving category")
                }
            }
        }
        
        let request : NSFetchRequest<Stock> = Stock.fetchRequest()
        do {
            stockList = try context.fetch(request).sorted(by: { $0.id < $1.id })
        } catch {
            print("Error loading stocks \(error)")
        }
        return stockList
    }
    
    
    
    func deleteAllData() {
        for stock in stocks {
            context.delete(stock)
        }
        do {
            try context.save()
        } catch {
            print("Error deleting stocks \(error)")
        }
    }
    
    func getAllPrices(completion: @escaping (Stock, Int) -> Void) {
        var i = 0
        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in
            if i < stocks.count {
                DispatchQueue.main.async {
                    getPriceData(stock: stocks[i]) { result in
                        if result {
                            completion(stocks[i], i)
                            i += 1
                        } else {
                            sleep(5)
                        }
                    }
                }
            } else {
                timer.invalidate()
            }
        }
    }
    
    func getPriceData(stock: Stock, completion: @escaping (Bool) -> Void) {
        AF.request("https://finnhub.io/api/v1/quote?symbol=\(stock.symbol!)&token=cbt3kuqad3i9sd7nn77g") {$0.timeoutInterval = 10}
            .responseDecodable(of: PriceData.self) { response in
            if let e = response.error {
                print(e)
                completion(false)
            }
            if let priceData = response.value {
                stock.price = priceData.c
                stock.priceChange = priceData.d
                stock.percentChange = priceData.dp
                do {
                    try context.save()
                } catch {
                    print("Error saving category")
                }
                completion(true)
            }
        }
    }
    
    func changedFavouriteStatus(_ stock: Stock) {
        stock.favorite = !stock.favorite
        do {
            try context.save()
        } catch {
            print("Error changing favourite \(error)")
        }
    }
}

struct PriceData: Codable {
    let c: Double
    let d: Double
    let dp: Double
}
