//
//  EmployeeType.swift
//  IntermediateTraining
//
//  Created by Angela Terao on 17/07/2023.
//

import Foundation

//Enumerations are by default a type of Integer, so we need to change it to a String type

enum EmployeeType : String {
    case Executive
    case SeniorManagement = "Senior Management"
    case Staff
    case Intern
}
