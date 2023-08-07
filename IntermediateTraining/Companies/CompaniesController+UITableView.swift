//
//  CompaniesController+UITableView.swift
//  IntermediateTraining
//
//  Created by Angela Terao on 10/05/2023.
//

import UIKit

extension CompaniesController {
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let employeesController = EmployeesController()
        
        employeesController.company = companies[indexPath.row]
        
        navigationController?.pushViewController(employeesController, animated: true)
        
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return companies.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "idCell", for: indexPath) as! CompanyCell

        let company = companies[indexPath.row]
        
        cell.company = company

        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView()
        view.backgroundColor = .pastelPinkColor
        return view
    }
    
    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let label = UILabel()
        label.text = "No companies available."
        label.textColor = .darkGray
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.textAlignment = .center
        return label
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return companies.count == 0 ? 150 : 0 //si jamais il y a des companies alors le footer n'existe pas
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { action, view, boolValue in
            self.deleteHandlerFunction(contextualAction: action, view: view, escaping: boolValue, indexPath: indexPath)
        }
        
        let editAction = UIContextualAction(style: .normal, title: "Edit") { (action, view, boolValue) in
            self.editHandlerFunction(contextualAction: action, view: view, escaping: boolValue, indexPath: indexPath)
        }
        
        editAction.backgroundColor = .darkGray

        let swipeActions = UISwipeActionsConfiguration(actions: [deleteAction, editAction])
        
        swipeActions.performsFirstActionWithFullSwipe = false

        return swipeActions
    }
    
    private func editHandlerFunction(contextualAction: UIContextualAction, view: UIView, escaping: @escaping (Bool) -> Void, indexPath: IndexPath) {
        
        let editCompanyController = CreateCompanyController()
        let navController = CustomNavigationController(rootViewController: editCompanyController)
        
        editCompanyController.delegate = self
        editCompanyController.company = companies[indexPath.row]
        
        navController.modalPresentationStyle = .fullScreen
        
        present(navController, animated: true)
        
        tableView.setEditing(false, animated: true) //Que les swipe actions disparaissent
        
    }
    
    private func deleteHandlerFunction(contextualAction: UIContextualAction, view: UIView, escaping: @escaping (Bool) -> Void, indexPath: IndexPath) {
        
        let company = self.companies[indexPath.row]
        
        //Do not forget to remove it from the companies array as well and not just the tableView otherwidse the app will crash.
        self.companies.remove(at: indexPath.row)
        self.tableView.deleteRows(at: [indexPath], with: .automatic)
        
        //Delete from the core data. Here we need to save the context otherwise the deleting will work but won't persist.
        let context = CoreDataManager.shared.persistentContainer.viewContext
        context.delete(company)
        
        do {
            try context.save()
        } catch let saveErr {
            print("Failed deleting company:", saveErr)
        }
    }

    
}
