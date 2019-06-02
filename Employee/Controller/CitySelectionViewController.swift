//
//  CitySelectionViewController.swift
//  Employee
//
//  Created by Niraj Jha on 02/06/19.
//  Copyright © 2019 Niraj Jha. All rights reserved.
//

import UIKit

protocol CityDelegate: class {
    func setSelectedValue(selectedCity: String)
}

struct ScreenSize {
    static let SCREEN_WIDTH         = UIScreen.main.bounds.size.width
    static let SCREEN_HEIGHT        = UIScreen.main.bounds.size.height
    static let SCREEN_MAX_LENGTH    = max(ScreenSize.SCREEN_WIDTH, ScreenSize.SCREEN_HEIGHT)
    static let SCREEN_MIN_LENGTH    = min(ScreenSize.SCREEN_WIDTH, ScreenSize.SCREEN_HEIGHT)
}

class CitySelectionViewController: UIViewController {
    
    public weak var delegate: CityDelegate?
    var searchController = UISearchController()
    var cityListTableView: UITableView?
    var searchResultsArray: [String]?
    var dataSource: [String]?
    let headerColor =  UIColor(red: 249.0/255.0, green: 249.0/255.0, blue: 249.0/255.0, alpha: 1.0)
    let headerTitle = "Select Country"
    
    //Mark:- Self methods..
    override func viewDidLoad() {
        super.viewDidLoad()
        prepareDataSourceArray()
        self.setUI()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.view.endEditing(true)
    }
    
    //Mark:- Private
    func setUI() {
        view.backgroundColor = .white
        title = headerTitle
        cityListTableView = UITableView(frame:CGRect(x: 0, y: 64, width: ScreenSize.SCREEN_WIDTH, height: ScreenSize.SCREEN_HEIGHT - 74))
        cityListTableView?.delegate   = self
        cityListTableView?.dataSource = self
        cityListTableView?.separatorInset = UIEdgeInsets.zero
        cityListTableView?.showsVerticalScrollIndicator = false
        cityListTableView?.separatorColor = .clear
        cityListTableView?.tableFooterView = UIView(frame: CGRect.zero)
        cityListTableView?.backgroundColor = .clear
        view.addSubview(cityListTableView!)
        
        searchController = UISearchController(searchResultsController: nil)
        searchController.searchBar.delegate = self
        self.searchController.searchResultsUpdater = self;
        searchController.searchBar.sizeToFit()
        searchController.dimsBackgroundDuringPresentation = false
        definesPresentationContext = true
        cityListTableView?.tableHeaderView = searchController.searchBar
    }
    
    func prepareDataSourceArray() {
        dataSource = ["Delhi", "Bengaluru", "Hyderabad", "Mumbai", "Pune", "Kolkata"]
    }
}

 //MARK:- TableView delegate
extension CitySelectionViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let name = searchController.isActive ? searchResultsArray![indexPath.row] : dataSource![indexPath.row]
        
        self.delegate?.setSelectedValue(selectedCity: name)
        
        UIView.animate(withDuration: 0.75) {
            UIView.setAnimationCurve(UIView.AnimationCurve.easeInOut)
            self.navigationController?.popViewController(animated: true)
            UIView.setAnimationTransition(UIView.AnimationTransition.flipFromLeft, for: (self.navigationController?.view)!, cache: false)
            
        }
    }
}

 //MARK:- TableView datasource
extension CitySelectionViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.searchController.isActive {
            return searchResultsArray!.count
        } else {
            return (dataSource?.count)!
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style:.default, reuseIdentifier: "CityCell")
        cell.selectionStyle = .none
        cell.backgroundColor = .clear
        let subViews = cell.contentView.subviews
        for subview in subViews {
            subview.removeFromSuperview()
        }
        
        let viewbg = UIView()
        viewbg.frame = CGRect(x: 0, y: 0, width:ScreenSize.SCREEN_WIDTH, height: 44)
        viewbg.backgroundColor = .clear
        viewbg.isUserInteractionEnabled = true
        
        let nameLabel = UILabel()
        nameLabel.frame = CGRect(x: 55, y: 2, width:ScreenSize.SCREEN_WIDTH - 60, height: 40)
        nameLabel.backgroundColor = UIColor.clear
        
        nameLabel.font = UIFont(name: "helvetica", size: 16.0)
        nameLabel.textColor = .black
        nameLabel.textAlignment = .left
        viewbg.addSubview(nameLabel)
        
        if searchController.isActive {
            let name  = searchResultsArray![indexPath.row]
            nameLabel.text = name
        } else {
            let name  = dataSource![indexPath.row]
            nameLabel.text = name
        }
        
        let lineView = UIView()
        lineView.frame=CGRect(x:50,y:viewbg.frame.size.height-1.0,width:viewbg.frame.size.width-50,height:1.0);
        lineView.backgroundColor = UIColor.lightGray
        viewbg.addSubview(lineView)
        cell.contentView.addSubview(viewbg)
        return cell
    }
}

extension CitySelectionViewController: UISearchBarDelegate,UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        if let searchString = searchController.searchBar.text {
            if let temp = dataSource?.filter({
                $0.contains(searchString)}) {
                searchResultsArray?.removeAll()
                searchResultsArray = temp
                cityListTableView?.reloadData()
            }
        }
    }
    
    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        self.updateSearchResults(for: searchController)
    }
}

