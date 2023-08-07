//
//  EmployeeController.swift
//  IntermediateTraining
//
//  Created by Angela Terao on 10/05/2023.
//

import UIKit
import CoreData

class IndentedLabel: UILabel {
    
    override func drawText(in rect: CGRect) {
        let insets = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 0)
        let customRect = rect.inset(by: insets)
        super.drawText(in: customRect)
    }
    
}

class EmployeesController: UITableViewController, CreateEmployeeControllerDelegate {
    
    func didAddEmployee(employee: Employee) {
//        fetchEmployees()
//        tableView.reloadData() //no need to reload Data when we insert rows.
        
        // Ici section permet de recuperer l'index (int) dans l'array employeeType, qui soit egal au type de employee.
        // Ensuite on va recuperer le nombre d'employees dans cette section (si on compte 1, alors row = 1, donc va se rajouter a la ligne 1 (le premier est en ligne 0)
        // On cree l'indexPath, et on oublie pas de rajouter l'employe dans l'array allEmployees dans la section correspondante.
        // Animation dans la tableView.
        // L'avantage de cette methode plutot que d'utiliser fetchEmployhees et reloadData c'est qu'on a pas besoin de checker si on a le bon tri, on peut modifier l'array des types d'employees etc (modifier l'endroit des intern au debut et pas a la fin par exemple)
        
        guard let section = employeeTypes.firstIndex(of: employee.type!) else { return }
        let row = allEmployees[section].count
        
        let insertionIndexPath = IndexPath(row: row, section: section)
        
        allEmployees[section].append(employee)
        
        tableView.insertRows(at: [insertionIndexPath], with: .middle)
        
    }
    
    var company: Company?
    
    private let idCell = "idCell"
    
    //Difference betwwen viewDidLoad and viewWillAppear: didload is things called ONCE, willapear is called every time the view appears.
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationItem.title = company?.name

    }
    
    var allEmployees = [[Employee]]()
    
    var employeeTypes = [EmployeeType.Intern.rawValue, EmployeeType.Executive.rawValue,
                         EmployeeType.SeniorManagement.rawValue,
                         EmployeeType.Staff.rawValue
                         ]
    
    private func fetchEmployees() {
        guard let companyEmployees = company?.employees?.allObjects as? [Employee] else { return } //allObjects gives an array of any type
        
        allEmployees = []
        
        employeeTypes.forEach { employeeType in
            allEmployees.append(companyEmployees.filter { $0.type == employeeType })
        }
 
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return allEmployees.count
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let label = IndentedLabel()
        
        label.text = employeeTypes[section]

        label.backgroundColor = UIColor.pastelPinkColor
        label.textColor = UIColor.darkGray
        label.font = UIFont.boldSystemFont(ofSize: 16)
        return label
    }

    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        fetchEmployees()
        
        tableView.backgroundColor = .creamColor
        
        setupPlusButtonInNavBar(selector: #selector(handleAddEmployee))
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: idCell)
        tableView.sectionHeaderTopPadding = 0.0 //Otherwise space between header and navBar
        
    }
    
    @objc private func handleAddEmployee() {
        print("Trying to add employee")
        
        let createCompanyController = CreateEmployeeController()
        
        createCompanyController.delegate = self
        createCompanyController.company = company
        
        let navController = UINavigationController(rootViewController: createCompanyController)
        
        navController.modalPresentationStyle = .fullScreen
        present(navController, animated: true)
        
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allEmployees[section].count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: idCell, for: indexPath)
        
        let employee = allEmployees[indexPath.section][indexPath.row]
        
        cell.textLabel?.text = employee.name
        

        if let birthday = employee.employeeInformation?.birthday {
            
            let dateFormatter = DateFormatter()
            let locale = Locale(identifier: "EN")
            dateFormatter.dateFormat = "MMM dd, yyyy"
            dateFormatter.locale = locale
            
            let birthdayString = dateFormatter.string(from: birthday)
            
            cell.textLabel?.text = "\(employee.name ?? "")    \(birthdayString)"
        }
        
        cell.backgroundColor = .beigeColor
        cell.textLabel?.textColor = .darkGray
        cell.textLabel?.font = UIFont.boldSystemFont(ofSize: 15)
        
        return cell
    }
    
    
}
