//
//  ViewController.swift
//  Assignment_2
//
//  Created by Alexander Vahid on 11/29/18.
//  Copyright © 2018 Alexander Vahid. All rights reserved.
//

import UIKit
import CoreData

class ViewController: UIViewController {
    
    //page from the previous screen
    var page:Page!
    
    @IBOutlet weak var contentNavBar: UINavigationItem!
    @IBOutlet weak var contentTextBox: UITextView!
    
    //CoreData variables
    var context:NSManagedObjectContext!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        //setup the appDelegate variable and the context variable which gives access to the CoreData functions
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        context = appDelegate.persistentContainer.viewContext
        
        if self.page.content == nil  {
            self.contentTextBox.text = ""
        }
        else {
            self.contentTextBox.text = page.content
        }
        
        //update the navigation bar title
        self.contentNavBar.title = self.page.title!
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func saveButtonPressed(_ sender: Any) {
        
        //get what user entered in the box
        let contents = contentTextBox.text!
        
        //set page contents property equal to the user input
        self.page.content = contents
        
        // 3. Save to the databse
        do {
            try self.context.save();
        }
        catch {
            print("Error while saving notes to database")
        }
    }
    
}

