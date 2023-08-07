//
//  ViewController.swift
//  IntermediateTraining
//
//  Created by Angela Terao on 02/05/2023.
//

//if you have any errors when building, try to clean (product/clean build folder) as sometimes it get stuck with coredata.

import UIKit
import CoreData

class CompaniesController: UITableViewController {

    var companies = [Company]()
    
    @objc private func doUpdates() {
   
        CoreDataManager.shared.persistentContainer.performBackgroundTask { backgroundContext in
            
            let request: NSFetchRequest<Company> = Company.fetchRequest()
            
            
            do {
                let companies = try backgroundContext.fetch(request)
                
                companies.forEach { company in
                    print(company.name ?? "")
                    company.name = "B: \(company.name ?? "")"
                }
                
                do {
                    try backgroundContext.save()
                    
                    DispatchQueue.main.async {
                        CoreDataManager.shared.persistentContainer.viewContext.reset()
                        self.companies = CoreDataManager.shared.fetchCompanies()
                        self.tableView.reloadData()
                    }
                    
                } catch let saveErr {
                    print("Failed to save on background:", saveErr)
                }
                
            } catch let err {
                print("Failed to fetch companies on background:", err)
            }
            
        }
        
    }
    
    @objc private func doNestedUpdates() {
        
        DispatchQueue.global(qos: .background).async {
            //We'll first construct a custom MOC (Managed Object Context)
            
            let privateContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
            privateContext.parent = CoreDataManager.shared.persistentContainer.viewContext
            
            //Execute updates on privateContext now
            let request: NSFetchRequest<Company> = Company.fetchRequest()
            request.fetchLimit = 1
            
            do {
                let companies = try privateContext.fetch(request)
                
                companies.forEach { company in
                    print(company.name ?? "")
                    company.name = "D: \(company.name ?? "")"
                }
                
                do {
                    try privateContext.save()
                    
                    //Mettre a jour l'UI
                    DispatchQueue.main.async {
                        
                        // Save le main context, sinon n'apparait pas dans CoreData
                        do {
                            let context = CoreDataManager.shared.persistentContainer.viewContext
                            
                            //Important selon la documentation
                            if context.hasChanges {
                                try context.save()
                            }
                            
                            self.tableView.reloadData()
                            
                        } catch let finalSaveErr {
                            print("Failed to save main context:", finalSaveErr)
                        }
                        
                        
                    }
                    
                } catch let saveErr {
                    print("Failed to save on private context", saveErr)
                }
                
            } catch let fetchErr {
                print("Failed to fetch companies on private context:", fetchErr)
            }
            
            
            
        }
        
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.companies = CoreDataManager.shared.fetchCompanies()
        
        view.backgroundColor = .white
        navigationItem.title = "Company"
        
        setupPlusButtonInNavBar(selector: #selector(handleAddCompany))
        navigationItem.leftBarButtonItems = [ UIBarButtonItem(title: "Reset", style: .plain, target: self, action: #selector(handleReset))]
        
        tableView.backgroundColor = .creamColor
        tableView.separatorStyle = .none
        
        tableView.register(CompanyCell.self, forCellReuseIdentifier: "idCell")
        tableView.sectionHeaderTopPadding = 0.0 //Otherwise space between header and navBar
        
        setupNavigationStyle()
   
    }
    
    @objc func handleAddCompany() {
        
        print("Adding company")
        let createCompanyController = CreateCompanyController()
        let navController = CustomNavigationController(rootViewController: createCompanyController)
        
        navController.modalPresentationStyle = .fullScreen
        
        createCompanyController.delegate = self
        
        present(navController, animated: true)
    }
    
    @objc private func handleReset() {
        
        print("Trying to reset")
        
        let indexPathsToRemove = CoreDataManager.shared.resetCompanies()
        
        companies.removeAll()
        tableView.deleteRows(at: indexPathsToRemove, with: .top)

    }
}



