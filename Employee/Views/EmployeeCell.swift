//
//  EmployeeCellTableViewCell.swift
//  Employee
//
//  Created by Niraj Jha on 01/06/19.
//  Copyright © 2019 Niraj Jha. All rights reserved.
//

import UIKit

struct EmployeeViewModel {
    let employeeName: String
    let emailId: String
    let city: String
    let isMarried: Bool
    let accessoryType: UITableViewCell.AccessoryType
    
    init(model:Employee) {
        self.employeeName = model.employeeName
        self.emailId = model.emailId
        self.city = model.city
        self.isMarried = model.isMarried
        accessoryType = .disclosureIndicator
    }
}


class EmployeeCell: UITableViewCell {
    
    var employeeViewModel:EmployeeViewModel? {
        didSet {
            textLabel?.text = employeeViewModel?.employeeName
            detailTextLabel?.text = employeeViewModel?.emailId
            accessoryType = employeeViewModel!.accessoryType
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
    }

}
