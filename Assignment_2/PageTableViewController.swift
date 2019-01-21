//
//  PageTableViewController.swift
//  Assignment_2
//
//  Created by Alexander Vahid on 11/29/18.
//  Copyright © 2018 Alexander Vahid. All rights reserved.
//

import UIKit
import CoreData

class PageTableViewController: UITableViewController {
    
    var notebook:Notebook!      //create variable for passing data (stores the notebook from the previous screen)
    var pages:[Page] = []       //empty array of page objects
    
    @IBOutlet weak var navBar: UINavigationItem!
    
    //CoreData variables
    var context:NSManagedObjectContext!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        //update title of the navigation bar to corresponding notebook title
        self.navBar.title = self.notebook.title!
        
        //create/initalize the appDelegate variable and the context variable which gives access to the CoreData functions
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        context = appDelegate.persistentContainer.viewContext

        //translates to SELECT * FROM Page WHERE notebook = ...
        let fetchRequest:NSFetchRequest<Page> = Page.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "notebook == %@", self.notebook)

        do {
            //send the query to the db and store any "rows" that might come back from the db
            let results = try self.context.fetch(fetchRequest) as [Page]
            self.pages = results
            
            // Loop through the database results and output each "row" to the screen
            //print("Number of items in database: \(results.count)")
            
            
            // DEBUG CODE
            //for x in results {
            //print("Stuff in db: \(x.title!)")
            
            //}
            
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

    
    @IBAction func addPagePressed(_ sender: Any) {
        
        //alert box
        let popup = UIAlertController(title: "Add a Page", message: "Give your page a title", preferredStyle: .alert)
        popup.addTextField()
        
        //cancel button
        let cancelButton = UIAlertAction(title: "Cancel", style: .default, handler: nil)
        
        //save button
        let saveButton = UIAlertAction(title: "Save", style: .default, handler: {
            
            action in
            
            // code for what should happen when you click the button
            //let data = popup.textFields?[0].text
            
            //save page to the database
            let page = Page(context: self.context)
            
            page.title = popup.textFields?[0].text                        //store what user wrote in the textbox
            page.date = NSDate() as Date                                  //store the current date
            page.notebook = self.notebook                                 //store the current notebook
            
            //@JENELLE: update the total number of pages.
            page.notebook?.numberOfPages = (page.notebook?.numberOfPages)! + 1
            
            //self.notebook.numberOfPages = Int32(self.pages.count) + 1
            
            do  {
                //save to the db
                try self.context.save()
                
                // update the ui
                self.pages.append(page)
                self.tableView.reloadData();
                
            }
            catch {
                print("Error while saving to the database")
            }
            
            print("total number of pages: \(page.notebook?.numberOfPages)")
            print("bye!")
            
            
        })
        
        //add both the buttons to the popup box
        popup.addAction(saveButton)
        popup.addAction(cancelButton)
        
        //show alert box!
        present(popup, animated:true)
    }
    
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return pages.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "myCell2", for: indexPath)

        // Configure the cell...
        cell.textLabel?.text = pages[indexPath.row].title
        cell.detailTextLabel?.text = "\(pages[indexPath.row].date!)"
        
        return cell
    }
    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            
            //get the row the user clicked on and the corresponding object from the array
            let deletedPage = pages[indexPath.row]
            
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
            pages.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    

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
        
        //create an instance object of the second screen
        let screen3 = segue.destination as! ViewController
        
        //set your variables that you wanna pass to the third screen
        let i = (self.tableView.indexPathForSelectedRow?.row)!
        screen3.page = pages[i]
    }
    

}
