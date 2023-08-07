//
//  CompaniesAutoUpdateController.swift
//  IntermediateTraining
//
//  Created by Angela Terao on 19/07/2023.
//

import UIKit
import CoreData

class CompaniesAutoUpdateController: UITableViewController, NSFetchedResultsControllerDelegate {
    
    lazy var fetchedResultsController: NSFetchedResultsController<Company> = {
        
        let context = CoreDataManager.shared.persistentContainer.viewContext
        let request: NSFetchRequest<Company> = Company.fetchRequest()
        
        request.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        
        let frc = NSFetchedResultsController(fetchRequest: request, managedObjectContext: context, sectionNameKeyPath: "name", cacheName: nil)
        
        frc.delegate = self
        
        do {
            try frc.performFetch()
        } catch let err {
            print(err)
        }
        
        return frc
        
    }()
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fetchedResultsController.sections![section].numberOfObjects
    }
    
    let cellId = "cellId"
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! CompanyCell
        
        let company = fetchedResultsController.object(at: indexPath)
        
        cell.company = company
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "Company Auto Updates"
        
        navigationItem.leftBarButtonItems = [UIBarButtonItem(title: "Add", style: .plain, target: self, action: #selector(handleAdd)), UIBarButtonItem(title: "Delete", style: .plain, target: self, action: #selector(handleDelete))]
        
        fetchedResultsController.fetchedObjects?.forEach({ company in
            print(company.name ?? "")
        })
        
        tableView.backgroundColor = UIColor.creamColor
        tableView.register(CompanyCell.self, forCellReuseIdentifier: cellId)
        tableView.sectionHeaderTopPadding = 0.0
        
        setupNavigationStyle()
        
        Service.shared.downloadCompaniesFromServer()
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        refreshControl.tintColor = .white
        self.refreshControl = refreshControl //give the refreshControl of the controller to the one we created
        
    }
    
    @objc private func handleRefresh() {
        
        Service.shared.downloadCompaniesFromServer()
        self.refreshControl?.endRefreshing() // this allows the UI to get back the way it was
        
    }
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
     
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        switch type {
        case .insert:
            tableView.insertSections(IndexSet(integer: sectionIndex), with: .fade)
        case .delete:
            tableView.deleteSections(IndexSet(integer: sectionIndex), with: .fade)
        case .move:
            break
        case .update:
            break
        @unknown default:
            fatalError()
        }
    }
     
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            tableView.insertRows(at: [newIndexPath!], with: .fade)
        case .delete:
            tableView.deleteRows(at: [indexPath!], with: .fade)
        case .update:
            tableView.reloadRows(at: [indexPath!], with: .fade)
        case .move:
            tableView.moveRow(at: indexPath!, to: newIndexPath!)
        @unknown default:
            fatalError()
        }
    }
     
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let label = IndentedLabel()
        label.text = fetchedResultsController.sectionIndexTitles[section]
        label.backgroundColor = UIColor.pastelPinkColor
        return label
    }
    
    //La methode précédente va chercher une méthode du delegate (qui suit) pour mettre correctement les noms des sections.
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, sectionIndexTitleForSectionName sectionName: String) -> String? {
        return sectionName
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return fetchedResultsController.sections?.count ?? 0
    }
    
    @objc private func handleAdd() {
        print("Trying to add")
        
        let context = CoreDataManager.shared.persistentContainer.viewContext
        
        let company = Company(context: context)
        
        company.name = "ZZZ"
        
        do {
            try context.save()
        } catch let err {
            print("Failed saving BMW", err)
        }
        
    }
    
    @objc private func handleDelete(){
        
        let request: NSFetchRequest<Company> = Company.fetchRequest()
        
        //        request.predicate = NSPredicate(format: "name CONTAINS %@", "B")
        
        let context = CoreDataManager.shared.persistentContainer.viewContext
        
        do {
            let companies = try context.fetch(request)
            
            companies.forEach { company in
                context.delete(company)
            }
            
        } catch let err {
            print(err)
        }
        
        do {
            try context.save()
        } catch let err {
            print(err)
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let employeeController = EmployeesController()
        
        employeeController.company = fetchedResultsController.object(at: indexPath)
        
        navigationController?.pushViewController(employeeController, animated: true)
        
    }
    
}
