//
//  CreateCompanyController.swift
//  IntermediateTraining
//
//  Created by Angela Terao on 03/05/2023.
//

import UIKit
import CoreData

protocol CreateCompanyControllerDelegate {
    
    func didAddCompany(company: Company)
    func didEditCompany(company: Company)
    
}


class CreateCompanyController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var company: Company? {
        didSet {
            nameTextField.text = company?.name
            
            if let imageData = company?.imageData {
                companyImageView.image = UIImage(data: imageData)
                setupCircularImageStyle()
            }
            
            guard let founded = company?.founded else { return }
            
            datePicker.date = founded
        }
    }
    
    var delegate: CreateCompanyControllerDelegate?
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.text = "Name"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let nameTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Company Name"
        textField.translatesAutoresizingMaskIntoConstraints = false
        
        return textField
    }()
    
    private let datePicker: UIDatePicker = {
        let dp = UIDatePicker()
        dp.translatesAutoresizingMaskIntoConstraints = false
        dp.datePickerMode = .date
        return dp
    }()
    
    lazy var companyImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "select_photo_empty"))
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        imageView.isUserInteractionEnabled = true
        
        imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleSelectPhoto)))
        
        imageView.contentMode = .scaleAspectFill
        
        return imageView
    }()
    
    @objc private func handleSelectPhoto() {
        print("Trying to select photo")
        
        let imagePickerController = UIImagePickerController()
        
        imagePickerController.delegate = self
        imagePickerController.allowsEditing = true
        
        present(imagePickerController, animated: true)
        
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        
        dismiss(animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let editedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            companyImageView.image = editedImage
        } else if let originalImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            companyImageView.image = originalImage
        }
        
        setupCircularImageStyle()
        
        dismiss(animated: true)
    }
    
    private func setupCircularImageStyle() {
        companyImageView.layer.cornerRadius = companyImageView.frame.width / 2
        companyImageView.clipsToBounds = true
        companyImageView.layer.borderWidth = 2
        companyImageView.layer.borderColor = UIColor.black.cgColor
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationItem.title = company == nil ? "Create Company" : "Edit Company"
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        
        view.backgroundColor = .creamColor

        setupSaveButtonInNavBar(selector: #selector(handleSave))
        setupCancelButtonInNavBar()
        
        setupNavigationStyle()
    }
    
    func setupUI() {
        
        setupBeigeBackgroundView(height: 250)
        
        view.addSubview(nameLabel)
        view.addSubview(nameTextField)
        view.addSubview(datePicker)
        view.addSubview(companyImageView)
        
        companyImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8).isActive = true
        companyImageView.widthAnchor.constraint(equalToConstant: 100).isActive = true
        companyImageView.heightAnchor.constraint(equalToConstant: 100).isActive = true

        companyImageView.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor).isActive = true
        
        nameLabel.topAnchor.constraint(equalTo: companyImageView.bottomAnchor).isActive = true
        nameLabel.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 16).isActive = true
        nameLabel.heightAnchor.constraint(equalToConstant: 50).isActive = true
        nameLabel.widthAnchor.constraint(equalToConstant: 100).isActive = true
        
        nameTextField.topAnchor.constraint(equalTo: nameLabel.topAnchor).isActive = true
        nameTextField.bottomAnchor.constraint(equalTo: nameLabel.bottomAnchor).isActive = true
        nameTextField.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor).isActive = true
        nameTextField.leftAnchor.constraint(equalTo: nameLabel.rightAnchor).isActive = true

        datePicker.topAnchor.constraint(equalTo: nameTextField.bottomAnchor).isActive = true
        datePicker.leftAnchor.constraint(equalTo: nameTextField.leftAnchor).isActive = true
        datePicker.widthAnchor.constraint(equalToConstant: 80).isActive = true
        datePicker.heightAnchor.constraint(equalToConstant: 50).isActive = true

    }
    
    @objc func handleSave(){

        if company == nil {
            createCompany()
        } else {
            saveCompanyChanges()
        }

    }
    
    private func saveCompanyChanges() {
        
        let context = CoreDataManager.shared.persistentContainer.viewContext
        
        company?.name = nameTextField.text
        company?.founded = datePicker.date
        
        if let companyImage = companyImageView.image {
            let imageData = companyImage.jpegData(compressionQuality: 0.8)
            company?.imageData = imageData
        }
        
        do {
            try context.save()
            
            dismiss(animated: true) {
                self.delegate?.didEditCompany(company: self.company!)
            }
        } catch let saveErr {
            print("Failed to save company changes:", saveErr)
        }
        
        
        
    }
    
    private func createCompany() {
        
        //We need to call this singleton because otherwise, the context is not persistent when we save + dismiss (the completion part of the dismiss is done once everything is done, and in the meanwhile the context is erased).
        let context = CoreDataManager.shared.persistentContainer.viewContext
        
        let company = NSEntityDescription.insertNewObject(forEntityName: "Company", into: context)
        
        company.setValue(nameTextField.text, forKey: "name")
        company.setValue(datePicker.date, forKey: "founded")
        
        if let companyImage = companyImageView.image {
            let imageData = companyImage.jpegData(compressionQuality: 0.8)
            company.setValue(imageData, forKey: "imageData")
        }
        
        // Perform save (when it doesn't throw and error)
        do {
            try context.save()
            
            //Success on saving the new company
            dismiss(animated: true) {
                self.delegate?.didAddCompany(company: company as! Company)
            }
            
        } catch let saveErr {
            print("Failed to save company \(saveErr)")
        }
    }
    
}


extension UIViewController {
    
    func setupNavigationStyle() {
        
        navigationController?.navigationBar.prefersLargeTitles = true
        UINavigationBar.appearance().tintColor = .white

        let navigationBarAppearace = UINavigationBarAppearance()

        navigationBarAppearace.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        navigationBarAppearace.titleTextAttributes = [.foregroundColor: UIColor.white]
        navigationBarAppearace.backgroundColor = .peachColor
        
        navigationController?.navigationBar.standardAppearance = navigationBarAppearace
        navigationController?.navigationBar.scrollEdgeAppearance = navigationBarAppearace

    }
    
}

