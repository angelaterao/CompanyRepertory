//
//  Service.swift
//  IntermediateTraining
//
//  Created by Angela Terao on 20/07/2023.
//

import Foundation
import CoreData

struct Service {
    
    static let shared = Service()
    
    let urlString = "https://api.letsbuildthatapp.com/intermediate_training/companies"

    func downloadCompaniesFromServer() {
        print("Attempting to download companies")
        
        guard let url = URL(string: urlString) else { return }
        
        URLSession.shared.dataTask(with: url) { data, resp, err in
            
            if let err = err {
                print("Failed to download companies", err)
                return
            }
            
            guard let data = data else { return }
            
            let jsonDecoder = JSONDecoder()
            
            do {
                let jsonCompanies = try jsonDecoder.decode([JSONCompany].self, from: data)
                
                let privateContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
                
                privateContext.parent = CoreDataManager.shared.persistentContainer.viewContext
                
                jsonCompanies.forEach { jsonCompany in
                    
                    let company = Company(context: privateContext)

                    company.name = jsonCompany.name
                    
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "MM/dd/yyyy"
                    let foundedDate = dateFormatter.date(from: jsonCompany.founded ?? "")
                    company.founded = foundedDate
                    
                    
                    jsonCompany.employees?.forEach({ jsonEmployee in
                        print("   \(jsonEmployee.name)")
                        
                        let employee = Employee(context: privateContext)
                        employee.name = jsonEmployee.name
                        employee.company = company
                        employee.type = jsonEmployee.type
                        
                        let employeeInformation = EmployeeInformation(context: privateContext)
                        let birthdayDate = dateFormatter.date(from: jsonEmployee.birthday)
                        employeeInformation.birthday = birthdayDate
                        
                        employee.employeeInformation = employeeInformation
                        
                        
                    })
                    
                    do {
                        try privateContext.save()
                        try privateContext.parent?.save()
                    } catch let saveErr {
                        print("Failed to save companies", saveErr)
                    }
                    
                }
                
            } catch let jsonDecoderErr {
                print("Failed decoding data: ", jsonDecoderErr)
                
            }
            
            
        }.resume()
        
    }
    
}

struct JSONCompany: Decodable {
    
    let name: String
    let founded: String?
    let photoURL: String?
    var employees: [JSONEmployee]?
    
}

struct JSONEmployee: Decodable {
    let name: String
    let type: String
    let birthday: String
    
}
