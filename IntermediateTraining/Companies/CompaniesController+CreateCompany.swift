//
//  CompaniesController+CreateCompany.swift
//  IntermediateTraining
//
//  Created by Angela Terao on 10/05/2023.
//

import UIKit

extension CompaniesController: CreateCompanyControllerDelegate {
    
    func didEditCompany(company: Company) {
        let row = companies.firstIndex(of: company)
        
        let reloadIndexPath = IndexPath(row: row!, section: 0)
        
        tableView.reloadRows(at: [reloadIndexPath], with: .fade)
    }
    
    
    func didAddCompany(company: Company) {

        //1- Modify the array
        companies.append(company)

        //2- Insert a new index path into tableview
        let newIndexPath = IndexPath(row: companies.count - 1, section: 0)

        tableView.insertRows(at: [newIndexPath], with: .automatic)
    }
    
}
