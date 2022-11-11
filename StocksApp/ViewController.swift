//
//  ViewController.swift
//  StocksApp
//
//  Created by Zhandos38 on 05.10.2022.
//

import UIKit
import SnapKit

class ViewController: UIViewController {
    var stocks = [Stock]()
    
    var searchResults = [Stock]()
    var isSearching = false
    
    var favouriteStocks = [Stock]()
    var isFavourite = false
    
    private let searchBar: UISearchBar = {
        let searchbar = UISearchBar()
        searchbar.searchBarStyle = .minimal
        searchbar.setImage(UIImage(named: "search-icon"), for: .search, state: .normal)
        searchbar.searchTextField.attributedPlaceholder = NSAttributedString(
            string: "Find stock by ticker or company name",
            attributes: [NSAttributedString.Key.foregroundColor : UIColor.black]
        )
        searchbar.searchTextField.textColor = .black
        searchbar.searchTextField.font = .systemFont(ofSize: 16)
        return searchbar
    }()
    
    private let menuView: UIView = {
        let menuView = UIView()
        return menuView
    }()
    
    private let stocksButton: UIButton = {
        let button = UIButton()
        button.setTitle("Stocks", for: .normal)
        return button
    }()
    
    private let favouriteButton: UIButton = {
        let button = UIButton()
        button.setTitle("Favourite", for: .normal)
        return button
    }()
    
    private let tableView: UITableView = {
        let table = UITableView()
        table.register(StockTableViewCell.self, forCellReuseIdentifier: StockTableViewCell.identifier)
        table.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        return table
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(searchBar)
        view.addSubview(menuView)
        menuView.addSubview(stocksButton)
        menuView.addSubview(favouriteButton)
        view.addSubview(tableView)
        
        let tap = UITapGestureRecognizer(target: view, action: #selector(searchBar.endEditing))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
        
        searchBar.delegate = self
        tableView.delegate = self
        tableView.dataSource = self
        
        stocksButton.addTarget(self, action: #selector(switchMode), for: .touchUpInside)
        favouriteButton.addTarget(self, action: #selector(switchMode), for: .touchUpInside)
        
        Manager.shared.getAllPrices { stock, pos in
            self.stocks.append(stock)
            if stock.favorite {
                self.favouriteStocks.append(stock)
            }
            if pos > 0, (pos%9 == 0 || pos == Manager.shared.stocks.count - 1) {
                if self.isSearching {
                    self.updateSearchResults(with: self.searchBar.text!)
                }
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
        }
    }
    
    //MARK: - Layout
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        let s = (view.frame.width) / 360
        
        searchBar.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(40 * s)
            make.leading.equalToSuperview().offset(16 * s)
            make.trailing.equalToSuperview().offset(-16 * s)
            make.height.equalTo(48 * s)
        }
        
        menuView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(108 * s)
            make.leading.equalToSuperview().offset(20 * s)
            make.width.equalTo(207 * s)
            make.height.equalTo(32 * s)
        }
        
        mainMenuUI()
        
        tableView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(156 * s)
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.bottom.equalToSuperview()
        }
    }
}
//MARK: - TableView methods

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isFavourite {
            if isSearching {
                return searchResults.count
            } else {
                return favouriteStocks.count
            }
        } else {
            if isSearching {
                return searchResults.count
            } else {
                return stocks.count
            }
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: StockTableViewCell.identifier, for: indexPath) as! StockTableViewCell
        if isFavourite {
            if isSearching {
                cell.stock = searchResults[indexPath.row]
            } else {
                cell.stock = favouriteStocks[indexPath.row]
            }
        } else {
            if isSearching {
                cell.stock = searchResults[indexPath.row]
            } else {
                cell.stock = stocks[indexPath.row]
            }
        }
        cell.delegate = self
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return view.frame.width / 360 * 76
    }
    
}

//MARK: - SearchBar methods

extension ViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText == "" {
            isSearching = false
            tableView.reloadData()
        } else {
            isSearching = true
            updateSearchResults(with: searchText)
            tableView.reloadData()
        }
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.endEditing(true)
    }
}
        
//MARK: - ClickDelegate methods

extension ViewController: ClickDelegate {
    func clicked(_ stockTableViewCell: StockTableViewCell) {
        if let stock = stockTableViewCell.stock {
            Manager.shared.changedFavouriteStatus(stock)
            if stock.favorite {
                favouriteStocks.append(stock)
                favouriteStocks.sort { $0.id < $1.id}
            } else {
                if let index = favouriteStocks.firstIndex(of: stock) {
                    favouriteStocks.remove(at: index)
                }
            }
        }
        if isFavourite {
            tableView.reloadData()
        }
    }
}

//MARK: - Custom functions

extension ViewController {
    func updateSearchResults(with searchText: String) {
        if isFavourite {
            searchResults = favouriteStocks.filter({ stock in
                return (stock.company!.lowercased().prefix(searchText.count) == searchText.lowercased() || stock.symbol!.lowercased().prefix(searchText.count) == searchText.lowercased())
            })
        } else {
            searchResults = stocks.filter({ stock in
                return (stock.company!.lowercased().prefix(searchText.count) == searchText.lowercased() || stock.symbol!.lowercased().prefix(searchText.count) == searchText.lowercased())
            })
        }
    }
    
    @objc func switchMode() {
        isFavourite = !isFavourite
        mainMenuUI()
        if isSearching {
            updateSearchResults(with: searchBar.text!)
        }
        tableView.reloadData()
    }
    
    func mainMenuUI() {
        let s = view.frame.width / 360
        if isFavourite {
            stocksButton.titleLabel?.font = .systemFont(ofSize: 18, weight: .bold)
            stocksButton.setTitleColor(.gray, for: .normal)
            
            favouriteButton.titleLabel?.font = .systemFont(ofSize: 28, weight: .bold)
            favouriteButton.setTitleColor(.black, for: .normal)
            
            stocksButton.snp.remakeConstraints { make in
                make.leading.bottom.equalToSuperview()
                make.top.equalToSuperview().offset(8 * s)
                make.width.equalTo(63 * s)
            }
            
            favouriteButton.snp.remakeConstraints { make in
                make.top.trailing.bottom.equalToSuperview()
                make.leading.equalTo(stocksButton.snp.trailing).offset(20 * s)
            }
            
        } else {
            stocksButton.titleLabel?.font = .systemFont(ofSize: 28, weight: .bold)
            stocksButton.setTitleColor(.black, for: .normal)
            
            favouriteButton.titleLabel?.font = .systemFont(ofSize: 18, weight: .bold)
            favouriteButton.setTitleColor(.gray, for: .normal)
            
            stocksButton.snp.remakeConstraints { make in
                make.top.bottom.leading.equalToSuperview()
                make.width.equalTo(98 * s)
            }
            
            favouriteButton.snp.remakeConstraints { make in
                make.top.equalToSuperview().offset(8 * s)
                make.leading.equalTo(stocksButton.snp.trailing).offset(20 * s)
                make.trailing.equalToSuperview()
                make.height.equalTo(24 * s)
            }
        }
    }
}
