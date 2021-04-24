//
//  ChatTableViewCell.swift
//  Messenger
//
//  Created by Vitaliy Yefimchuk on 22.04.2021.
//

import UIKit

class ChatTableViewCell: UITableViewCell {
    
    static let identifier = "ChatTableViewCell"

    private let userImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleToFill
        imageView.layer.cornerRadius = imageView.height/2
        imageView.layer.masksToBounds = true
        return imageView
    }()
    
    private let userNameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 21, weight: .semibold)
        return label
    }()
    
    private let userMessageLabel: UILabel = {
       let label = UILabel()
        label.font = .systemFont(ofSize: 19, weight: .regular)
        label.numberOfLines = 0
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(userImageView)
        contentView.addSubview(userNameLabel)
        contentView.addSubview(userMessageLabel)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        userImageView.frame = CGRect(x: 10, y: 10, width: 64, height: 64)
            
        userNameLabel.frame = CGRect(x: userImageView.right + 10, y: 10, width: contentView.width - 20 - userImageView.width, height: (contentView.height-20)/2)
        
        userMessageLabel.frame = CGRect(x: userImageView.right + 10, y: userNameLabel.bottom + 10, width: contentView.width - 20 - userImageView.width, height: (contentView.height-20)/2)
            }
    
    public func configure(with model: Chat) {
        self.userMessageLabel.text = model.latestMessage.text
        self.userNameLabel.text = model.name
        self.userImageView.image = UIImage(systemName: "heart.fill")
        
        self.userImageView.tintColor = .systemPink
    }

}
