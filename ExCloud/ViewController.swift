//
//  ViewController.swift
//  ExCloud
//
//  Created by 김종권 on 2021/12/20.
//

import UIKit
import CloudKit

class ViewController: UIViewController {
  
  private let tableView = TasksTableViewController()
  private let manager = CloudManager()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.title = "Tasks"
    
    layoutUI()
    fetchRecords()
    configureAddButton()
  }
  
  private func layoutUI() {
    view.addSubview(tableView.view)
    
    NSLayoutConstraint.activate([
      tableView.view.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
      tableView.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
      tableView.view.centerXAnchor.constraint(equalTo: view.centerXAnchor),
      tableView.view.widthAnchor.constraint(equalTo: view.widthAnchor)
    ])
  }
  
  private func configureAddButton() {
    let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addTask))
    navigationItem.rightBarButtonItems = [addButton]
  }
  
  @objc private func addTask() {
    let controller = AddTaskController()
    controller.delegate = self
    present(controller, animated: true)
  }
  
  private func fetchRecords() {
    manager.fetchTasks(completion: { (records, error) in
      guard error == .none, let records = records else {
        print(error)
        return
      }
      
      DispatchQueue.main.async {
        self.tableView.set(tasks: records)
      }
    })
  }
}

extension ViewController: TasksDelegate {
  func addedTask(_ task: CKRecord?, error: FetchError) {
    guard error == .none, let task = task else {
      print(error)
      return
    }
    DispatchQueue.main.async {
      self.tableView.add(task: task)
    }
  }
}

