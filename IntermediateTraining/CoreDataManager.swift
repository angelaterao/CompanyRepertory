//
//  CoreDataManager.swift
//  IntermediateTraining
//
//  Created by Angela Terao on 08/05/2023.
//

import UIKit
import CoreData

struct CoreDataManager {
    
    static let shared = CoreDataManager()
    
    let persistentContainer: NSPersistentContainer = {
        // Initialization of our Core Data stack
        let container = NSPersistentContainer(name: "IntermediateTrainingModels")
        
        container.loadPersistentStores { store, err in
            if let err = err {
                fatalError("Loading of store failed: \(err)")
            }
        }
        
        return container
    }()
    
    func fetchCompanies() -> [Company] {
        
        let context = persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<Company>(entityName: "Company")
        
        do{
            let companies = try context.fetch(fetchRequest)
            return companies
        } catch let fetchErr {
            print("Failed to fetch companies:", fetchErr)
            return []
        }
    }

    
    func resetCompanies() -> [IndexPath] {
        
        let context = persistentContainer.viewContext
        
        let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: Company.fetchRequest())
        let companies = fetchCompanies()
        
        do {
            try context.execute(batchDeleteRequest)
            
            var indexPathsToRemove = [IndexPath]()
            
            for (index, _) in companies.enumerated() {
                let indexPath = IndexPath(row: index, section: 0)
                indexPathsToRemove.append(indexPath)
            }
            
            return indexPathsToRemove
            
        } catch let delErr {
            print("Failed to delete objects from CoreData: ", delErr)
            return []
        }
    }
    
    func createEmployee(name: String, type: String, birthday: Date, company: Company?) -> (Employee?, Error?) {
        
        let context = persistentContainer.viewContext
        
        let employee = Employee(context: context) // cette ligne permet de creer une nouvelle instance, register it with the context and prepares it to be saved to the persistent store.
        
        employee.name = name
        employee.type = type
        
        let employeeInformation = EmployeeInformation(context: context)
        
        employeeInformation.taxId = "456"
        employeeInformation.birthday = birthday
        
        employee.employeeInformation = employeeInformation
        
        employee.company = company // no need to create a new instance of company here because we want to keep the one we already have (in argument)

        do {
            try context.save()
            
            return (employee, nil)
        } catch let createErr {
            print("Failed to create employee:", createErr)
            return (nil, createErr)
        }
        
    }
}
