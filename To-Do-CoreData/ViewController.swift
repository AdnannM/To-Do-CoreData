//
//  ViewController.swift
//  To-Do-CoreData
//
//  Created by Adnann Muratovic on 06/07/2020.
//  Copyright © 2020 Adnann Muratovic. All rights reserved.
//

import UIKit
import CoreData

class ViewController: UITableViewController {

	var items: [NSManagedObject] = []
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(true)
		guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
		let managedContext = appDelegate.persistentContainer.viewContext
		let fetchReques = NSFetchRequest<NSManagedObject>(entityName: "Task")
		
		do {
			items = try managedContext.fetch(fetchReques)
		} catch let err as NSError {
			print("Failed to fetch items", err)
		}
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view, typically from a nib.
		
		view.backgroundColor = .white
		navigationController?.navigationBar.barTintColor = UIColor(red: 0/255, green: 122/255, blue: 255/255, alpha: 1)
		navigationController?.navigationBar.tintColor = .white
		navigationController?.navigationBar.prefersLargeTitles = true
		navigationController?.navigationBar.topItem!.title = "To-Do List"
		navigationController?.navigationBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
		
		
		// Add button
		navigationItem.rightBarButtonItem = UIBarButtonItem(title: "New Item", style: .plain, target: self, action: #selector(addItem))
		
	}
	
	// MARK: - Add Items

	@objc func addItem() {
		let ac = UIAlertController(title: "Add New Item", message: "Please fill in the text box", preferredStyle: .alert)
		
		ac.addTextField { (taskItem) in
			taskItem.text = ""
			taskItem.placeholder = "Task Name"
		}
		
		ac.addTextField(configurationHandler: {(taskDesc) in
			taskDesc.text = ""
			taskDesc.placeholder = "Description"
		})
		
		let saveAction = UIAlertAction(title: "Save", style: .default) { [unowned self] action in
			let txtTask = ac.textFields![0]
			let txtDesc = ac.textFields![1]
			let taskStr = txtTask.text
			let descStr = txtDesc.text
			
			// Pass the value to save method
			self.save(task: taskStr!, description: descStr!)
			self.tableView.reloadData()
		}
		
		let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
		ac.addAction(saveAction)
		ac.addAction(cancelAction)
		present(ac,animated: true,completion: nil)
		
		
	}
	
	// MARK: - Save Items
	func save(task: String, description: String) {
		guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
		let managedContext = appDelegate.persistentContainer.viewContext
		let entity = NSEntityDescription.entity(forEntityName: "Task", in: managedContext)
		let item = NSManagedObject(entity: entity!, insertInto: managedContext)
		item.setValue(task, forKey: "taskName")
		item.setValue(description, forKey: "taskDesc")
		
		do { // do-catch to try and save item
			try managedContext.save()
			items.append(item)
		} catch let err as NSError {
			print("Failed to save an item", err)
		}
	}
	
	// MARK: - Table View Delegate
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return items.count
	}
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		var cell = tableView.dequeueReusableCell(withIdentifier: "cellID")
		
		if cell == nil {
			cell = UITableViewCell(style: .subtitle, reuseIdentifier: "cellID")
		}
		
		let item = items[indexPath.row]
		// Add task and description to cell label
		cell!.textLabel?.text = item.value(forKeyPath: "taskName") as? String
		cell!.detailTextLabel?.text = item.value(forKeyPath: "taskDesc") as? String
		return cell!
	}
	
	// MARK: - Delete Items
	override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
		if editingStyle == .delete {
			items.remove(at: indexPath.row)
			tableView.deleteRows(at: [indexPath], with: .fade)
		}
	}
}

