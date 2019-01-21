//
//  NotebookTableViewController.swift
//  Assignment_2
//
//  Created by Alexander Vahid on 11/29/18.
//  Copyright © 2018 Alexander Vahid. All rights reserved.
//

import UIKit
import CoreData

class NotebookTableViewController: UITableViewController {
    
    //empty array of notebook objects
    var notebooks:[Notebook] = []
    
    //CoreData variables
    var context:NSManagedObjectContext!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //create/initalize the appDelegate variable and the context variable which gives access to the CoreData functions
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        self.context = appDelegate.persistentContainer.viewContext
        
        //SELECT * FROM statement
        let fetchRequest:NSFetchRequest<Notebook> = Notebook.fetchRequest()
        
        do {
            //send the "SELECT" statement to the db and store any "rows" that might come back from the db
            let results = try self.context.fetch(fetchRequest) as [Notebook]
            
            self.notebooks = results
            
        }
        catch {
            print("Error fetching data from database")
        }
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func addNotebookPressed(_ sender: Any) {
        
        // create the alert box
        let popup = UIAlertController(title: "Add a Notebook", message: "Give your book a title", preferredStyle: .alert)
        popup.addTextField()
        
        //cancel button
        let cancelButton = UIAlertAction(title: "Cancel", style: .default, handler: nil)
        
        //save button
        let saveButton = UIAlertAction(title: "Save", style: .default, handler: {
            
            action in
            
            //save the notebook to the database
            let book = Notebook(context: self.context)
            
            book.title = popup.textFields?[0].text     // get what user wrote in the text box
            book.date = NSDate() as Date               //get the current date
            book.numberOfPages = 0                     //default number of pages is 0
            
            do  {
                //save the user data into db
                try self.context.save()
                
                //update ui
                self.notebooks.append(book)
                self.tableView.reloadData();
                
            }
            catch {
                print("Error while saving to the database")
            }
            
            
        })
        
        // add both the buttons to the popup box
        popup.addAction(saveButton)
        popup.addAction(cancelButton)
        
        //show alert box
        present(popup, animated:true)
    }
    

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return notebooks.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "myCell", for: indexPath)

        // Configure the cell...
        cell.textLabel?.text = notebooks[indexPath.row].title
        cell.detailTextLabel?.text = "\(notebooks[indexPath.row].numberOfPages) pages"

        print(notebooks[indexPath.row])
        
        return cell
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("COMING TO THIS FUNCITON!")
        // refresh the notebook row data
        self.tableView.reloadData()
    }
    
    
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        //edit button
        let editAction = UITableViewRowAction(style: .normal, title: "Edit", handler: { (action, indexPath) in
            let alert = UIAlertController(title: "", message: "Edit Notebook Title", preferredStyle: .alert)
            
            //textbox for user input of new notebook title
            alert.addTextField(configurationHandler: { (textField) in
                
            })
            
            //
            alert.addAction(UIAlertAction(title: "Update", style: .default, handler: { (updateAction) in
                
                // UPDATE query statement
                self.notebooks[indexPath.row].title = alert.textFields!.first!.text!
                
                do {
                    //send save query to the db
                    try self.context.save()
                }
                catch {
                    print("Error while saving to database")
                }
                
                self.tableView.reloadRows(at: [indexPath], with: .fade)
            }))
            
            //cancel button within edit alert
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            self.present(alert, animated: false)
        })
        
        //delete button
        let deleteAction = UITableViewRowAction(style: .default, title: "Delete", handler: { (action, indexPath) in
            //self.list.remove(at: indexPath.row)
            //tableView.reloadData()
            
            //get the row the user clicked on and the corresponding object from the array
            let deletedPage = self.notebooks[indexPath.row]
            
            //remove from db
            self.context.delete(deletedPage)
            
            do {
                //send delete query to the db
                try self.context.save()
                print("Deleted!")
            }
            catch {
                print("Error while performing delete")
            }
            
            // Delete the row from the data source (UI)
            self.notebooks.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        })
        
        return [deleteAction, editAction]
    }

    
    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source (UI)
            tableView.deleteRows(at: [indexPath], with: .fade)
            
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */
    

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        //create instance object of the second screen
        let screen2 = segue.destination as! PageTableViewController
        
        //set the variables that will be passed to the second screen
        let i = (self.tableView.indexPathForSelectedRow?.row)!
       
        screen2.notebook = notebooks[i]
        
        
    }
    

}
