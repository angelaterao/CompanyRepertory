//
//  CompanyCell.swift
//  IntermediateTraining
//
//  Created by Angela Terao on 09/05/2023.
//

import UIKit

class CompanyCell: UITableViewCell {
    
    var company: Company? {
        didSet {

            if let imageData = company?.imageData {
                companyImageView.image = UIImage(data: imageData)
            }
            
            if let name = company?.name, let founded = company?.founded {
                
                let dateFormatter = DateFormatter()
                let locale = Locale(identifier: "EN")
                dateFormatter.dateFormat = "MMM dd, yyyy"
                dateFormatter.locale = locale
                
                let foundedString = dateFormatter.string(from: founded)
                
                nameFoundedDateLabel.text = "\(name) - Founded: \(foundedString)"
            } else {
                nameFoundedDateLabel.text = company?.name
            }
            
        }
    }
    
    let companyImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "select_photo_empty"))
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 20
        imageView.clipsToBounds = true
        imageView.layer.borderColor = UIColor.black.cgColor
        imageView.layer.borderWidth = 1
        return imageView
    }()
    
    let nameFoundedDateLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Company name"
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.textColor = .darkGray
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        backgroundColor = .beigeColor
        
        addSubview(companyImageView)
        addSubview(nameFoundedDateLabel)
        
        companyImageView.leftAnchor.constraint(equalTo: safeAreaLayoutGuide.leftAnchor, constant: 16).isActive = true
        companyImageView.widthAnchor.constraint(equalToConstant: 40).isActive = true
        companyImageView.heightAnchor.constraint(equalToConstant: 40).isActive = true
        companyImageView.centerYAnchor.constraint(equalTo: safeAreaLayoutGuide.centerYAnchor).isActive = true
        
        nameFoundedDateLabel.leftAnchor.constraint(equalTo: companyImageView.rightAnchor, constant: 8).isActive = true
        nameFoundedDateLabel.rightAnchor.constraint(equalTo: safeAreaLayoutGuide.rightAnchor).isActive = true
        nameFoundedDateLabel.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor).isActive = true
        nameFoundedDateLabel.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor).isActive = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}
