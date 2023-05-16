//
//  StockTableViewCell.swift
//  StocksApp
//
//  Created by Zhandos38 on 12.10.2022.
//

import UIKit
import SnapKit
import Kingfisher

class StockTableViewCell: UITableViewCell {
    
    var stock: Stock? {
        didSet {
            configure(with: stock!)
        }
    }
    
    weak var delegate: ClickDelegate?
    
    public let customView: UIView = {
        let customView = UIView()
        return customView
    }()
    
    private let logoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.isHidden = true
        imageView.contentMode = .scaleToFill
        return imageView
    }()
    
    private let symbolLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.sizeToFit()
        label.font = .systemFont(ofSize: 18, weight: .bold)
        return label
    }()
    
    private let starButton: UIButton = {
        let button = UIButton()
        return button
    }()
    
    private let companyLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.font = .systemFont(ofSize: 12, weight: .semibold)
        return label
    }()
    
    private let priceLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.sizeToFit()
        label.font = .systemFont(ofSize: 18, weight: .bold)
        return label
    }()
    
    private let changeLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.sizeToFit()
        label.font = .systemFont(ofSize: 12, weight: .semibold)
        label.textColor = UIColor(red: 36/255, green: 179/255, blue: 93/255, alpha: 1)
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.addSubview(customView)
        customView.addSubview(logoImageView)
        customView.addSubview(symbolLabel)
        customView.addSubview(starButton)
        customView.addSubview(companyLabel)
        customView.addSubview(priceLabel)
        customView.addSubview(changeLabel)
        starButton.addTarget(self, action: #selector(favoriteTapped), for: .touchUpInside)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let s = (contentView.frame.width) / 360
        customView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(4 * s)
            make.leading.equalToSuperview().offset(16 * s)
            make.width.equalTo(328 * s)
            make.height.equalTo(68 * s)
        }
        
        logoImageView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(8 * s)
            make.leading.equalToSuperview().offset(8 * s)
            make.width.equalTo(52 * s)
            make.height.equalTo(52 * s)
        }
        
        symbolLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(14 * s)
            make.leading.equalToSuperview().offset(72 * s)
            make.height.equalTo(24 * s)
        }
        
        starButton.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(17 * s)
            make.leading.equalTo(symbolLabel.snp.trailing).offset(6 * s)
            make.width.equalTo(16 * s)
            make.height.equalTo(16 * s)
        }
        
        priceLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(14 * s)
            make.trailing.equalToSuperview().offset(-17 * s)
            make.height.equalTo(24 * s)
        }
        
        changeLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(44 * s)
            make.trailing.equalToSuperview().offset(-12 * s)
            make.height.equalTo(16 * s)
        }
        
        companyLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(44 * s)
            make.leading.equalToSuperview().offset(72 * s)
            make.width.equalTo(140 * s)
            make.height.equalTo(16 * s)
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        logoImageView.image = nil
        symbolLabel.text = nil
        companyLabel.text = nil
        priceLabel.text = nil
        changeLabel.text = nil
    }
    
    public func configure(with stock: Stock) {
        displayLogo(of: stock)
        favoriteUI()
        symbolLabel.text = stock.symbol!
        priceLabel.text = "$\(stock.price)"
        var pChange: String {
            if stock.priceChange > 0 {
                changeLabel.textColor = .systemGreen
                return "+$\(stock.priceChange)"
            } else {
                changeLabel.textColor = .systemRed
                return "-$\(-stock.priceChange)"
            }
        }
        let perChange = round(stock.percentChange * 100) / 100.0
        changeLabel.text = "\(pChange) (\(perChange)%)"
        companyLabel.text = stock.company!
    }
    
    @objc
    func favoriteTapped() {
        self.delegate?.clicked(self)
        favoriteUI()
    }
    
    func favoriteUI() {
        if stock!.favorite {
            starButton.setBackgroundImage(UIImage(named: "Path"), for: .normal)
        } else {
            starButton.setBackgroundImage(UIImage(named: "Path-2"), for: .normal)
        }
    }
    
    private func displayLogo(of stock: Stock) {
        let url = URL(string: stock.logo!)
        logoImageView.kf.setImage(with: url)
        logoImageView.isHidden = false
    }
}

protocol ClickDelegate : AnyObject {
    func clicked(_ stockTableViewCell: StockTableViewCell)
}
