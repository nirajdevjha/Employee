//
//  EmployeeListViewController.swift
//  Employee
//
//  Created by Niraj Jha on 01/06/19.
//  Copyright © 2019 Niraj Jha. All rights reserved.
//

import UIKit
import CoreData

class EmployeeListViewController: UIViewController {
    
    @IBOutlet weak var employeeTableView: UITableView!
    var employeeArray:[EmployeeViewModel]?
    var isEdit = false
    var selectedIndexPath: IndexPath?
    
    //MARK:- Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setUp()
        
    }
    override func viewWillAppear(_ animated: Bool) {
        //Fetch Data from Database
        getDataFromCoreData()
    }
    
    //MARK:- Private
    private func setUp() {
        employeeTableView.tableFooterView = UIView(frame: .zero)
        
        employeeTableView.delegate = self
        employeeTableView.dataSource = self
        
        self.title = "Employee"
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addEmployee))
    }
    
    private func getDataFromCoreData() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let context = appDelegate.persistentContainer.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "EmployeeItem")
        
        let sort = NSSortDescriptor(key: #keyPath(EmployeeItem.employeeName), ascending: true) //Fetching with Stored Order
        request.sortDescriptors = [sort]
        
        do {
            //Get list of ManagedObjects
            let result = try context.fetch(request)
            var array:[Employee] = []
            //Checking is data is previous data data or not
            if !result.isEmpty {
                for data in result as! [NSManagedObject] {
                    let employeeName = data.value(forKey: "employeeName") as! String
                    let email = data.value(forKey: "emailId") as! String
                    let city = data.value(forKey: "city") as! String
                    let isMarried = data.value(forKey: "married") as! Bool
                    
                    let employeeModel = Employee(employeeName: employeeName,
                                                 emailId: email,
                                                 city: city,
                                                 isMarried: isMarried)
                    
                    array.append(employeeModel)
                }
                employeeArray = array.map({ (model) -> EmployeeViewModel in
                    return EmployeeViewModel(model: model)
                })
                
                employeeTableView.reloadData()
            }
        } catch {
            //TO::DO Error
        }
    }
    
    
    @objc func addEmployee() {
        navigateToEmployeeForm()
    }
    
    private func navigateToEmployeeForm() {
        let employeeFormVC = EmployeeFormViewController.storyboardInstance()
        if isEdit {
            let employeeViewModel = employeeArray![(selectedIndexPath?.row)!]
            employeeFormVC.employeeViewModel = employeeViewModel
            employeeFormVC.navigationTitle = "Edit Employee"
            employeeFormVC.isUpdate = true
            isEdit = false
        } else {
            employeeFormVC.navigationTitle = "Add Employee"
            employeeFormVC.isUpdate = false
        }
        UIView.animate(withDuration: 0.75) {
            UIView.setAnimationCurve(UIView.AnimationCurve.easeInOut)
            self.navigationController?.pushViewController(employeeFormVC, animated: true)
            UIView.setAnimationTransition(UIView.AnimationTransition.flipFromRight, for: (self.navigationController?.view)!, cache: false)
        }
    }
}

 //MARK:- TableView delegate/datasource
extension EmployeeListViewController : UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let employeeArray = employeeArray else { return 0 }
        return employeeArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "employeeCell", for: indexPath) as! EmployeeCell
        let employeeViewModel = employeeArray![indexPath.row]
        cell.employeeViewModel = employeeViewModel
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedIndexPath = indexPath
        isEdit = true
        navigateToEmployeeForm()
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        let employeeViewModel = employeeArray![indexPath.row]
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "EmployeeItem")
        fetchRequest.predicate = NSPredicate(format: "employeeName = %@", employeeViewModel.employeeName)
        
        if editingStyle == .delete {
            do {
                let fetch = try managedContext.fetch(fetchRequest)
                let objectToDelete = fetch[0] as! NSManagedObject
                managedContext.delete(objectToDelete)
                
                do {
                    try managedContext.save()
                    employeeArray?.remove(at: indexPath.row)
                    tableView.deleteRows(at: [indexPath], with: .fade)
                }
                catch
                {
                    print(error)
                }
            }
            catch
            {
                print(error)
            }
        }
    }
}

