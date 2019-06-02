//
//  EmployeeFormViewController.swift
//  Employee
//
//  Created by Niraj Jha on 01/06/19.
//  Copyright © 2019 Niraj Jha. All rights reserved.
//

import UIKit
import CoreData

class EmployeeFormViewController: UIViewController {
    
    @IBOutlet weak var empTextField: UITextField!
    
    @IBOutlet weak var emailTextField: UITextField!
    
    @IBOutlet weak var cityTextField: UITextField!
    @IBOutlet weak var isMarriedSwitch: UISwitch!
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    var employeeName: String?
    var email: String?
    var city: String?
    var isMarried = false
    var navigationTitle: String?
    
    var employeeViewModel:EmployeeViewModel?
    
    //MARK:- Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setUp()
    }
    
    //MARK:- Private
    private func setUp() {
        title = navigationTitle
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .save, target: self, action:#selector(saveDetails))
        empTextField.delegate = self
        emailTextField.delegate = self
        cityTextField.delegate = self
        empTextField.text = employeeViewModel?.employeeName
        emailTextField.text = employeeViewModel?.emailId
        cityTextField.text = employeeViewModel?.city
        isMarriedSwitch.isOn = employeeViewModel?.isMarried ?? false
    }
    
    private func updateEmployeeToCoreData(dataArray:[Employee]) {
        let context = appDelegate.persistentContainer.viewContext
        let entity = NSEntityDescription.entity(forEntityName: "EmployeeItem", in: context)
        
        for index in 0..<dataArray.count {
            let item = dataArray[index]
            let newEmp = NSManagedObject(entity: entity!, insertInto: context)
            newEmp.setValue(item.employeeName, forKey: "employeeName")
            newEmp.setValue(item.emailId, forKey: "emailId")
            newEmp.setValue(item.city, forKey: "city")
            newEmp.setValue(item.isMarried, forKey: "married")
        }
        do {
            try context.save()
            let alertController  = UIAlertController(title:nil, message: "Successfully Saved", preferredStyle: .alert)
            let alertActon   = UIAlertAction(title: "OK", style: .default) { [weak self] _ in
                guard let self = self else { return }
                self.dismiss(animated: true, completion: nil)
                self.navigationController?.popViewController(animated: true
                )
            }
            alertController.addAction(alertActon)
            present(alertController, animated:true, completion: nil)
            
        } catch {
            print("Failed to save")
        }
    }
    
    @objc func saveDetails() {
        employeeName = empTextField.text?.trimmingCharacters(in: .whitespaces)
        email = emailTextField.text?.trimmingCharacters(in: .whitespaces)
        city  = cityTextField.text?.trimmingCharacters(in: .whitespaces)
        
        if let employeeName = employeeName, let email = email, let city = city {
            if !employeeName.isEmpty && !email.isEmpty && !city.isEmpty {
                var array = [Employee]()
                let emp = Employee(employeeName: employeeName, emailId: email, city: city, isMarried: isMarried)
                array.append(emp)
                updateEmployeeToCoreData(dataArray: array)
            } else {
                let alertController  = UIAlertController(title:"Error", message: "Pls fill in all details", preferredStyle: .alert)
                let alertActon   = UIAlertAction(title: "OK", style:.cancel, handler: nil)
                alertController.addAction(alertActon)
                present(alertController, animated:true, completion: nil)
            }
        }
    }
    
    @IBAction func isMarried(_ sender: UISwitch) {
        if sender.isOn {
            isMarried = true
        } else {
            isMarried = false
        }
    }
    
    //MARK:- Public
    class func storyboardInstance() -> EmployeeFormViewController {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "EmployeeFormViewController") as! EmployeeFormViewController
        return vc
    }
}

//MARK:- TextField delegate
extension EmployeeFormViewController: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == cityTextField {
            let cityVC = CitySelectionViewController()
            cityVC.delegate = self
            cityTextField.resignFirstResponder()
            UIView.animate(withDuration: 0.75) {
                UIView.setAnimationCurve(UIView.AnimationCurve.easeInOut)
                self.navigationController?.pushViewController(cityVC, animated: true)
                UIView.setAnimationTransition(UIView.AnimationTransition.flipFromRight, for: (self.navigationController?.view)!, cache: false)
            }
        }
    }
}

//MARK:- City delegate
extension EmployeeFormViewController: CityDelegate {
    
    func setSelectedValue(selectedCity: String) {
        cityTextField.text = selectedCity
    }
}
