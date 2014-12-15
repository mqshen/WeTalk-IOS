//
//  ViewController.swift
//  WeTalk
//
//  Created by GoldRatio on 11/25/14.
//  Copyright (c) 2014 GoldRatio. All rights reserved.
//

import UIKit
import SwiftForms

class ViewController: FormViewController, FormViewControllerDelegate {
    var deleage: MainViewController?

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.loadForm()
    }
    
    required init() {
        super.init(style: UITableViewStyle.Grouped)
        self.loadForm()
    }
    
    override init(nibName nibNameOrNil: String!, bundle nibBundleOrNil: NSBundle!) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        self.loadForm()
    }
    
    func loadForm() {
        self.delegate = self
        let form = FormDescriptor()
        form.title = "Example form"
        
        form.headHeight = 180.0
        
        
        // Define first section
        let section1 = FormSectionDescriptor()
        
        var row: FormRowDescriptor! = FormRowDescriptor(tag: "name", rowType: .Email, title: "Email")
        section1.addRow(row)
        
        row = FormRowDescriptor(tag: "pass", rowType: .Password, title: "Password")
        section1.addRow(row)
        
        // Define second section
        let section2 = FormSectionDescriptor()
        
        row = FormRowDescriptor(tag: "button", rowType: .Button, title: "Submit")
        section2.addRow(row)
        
        form.sections = [section1, section2]
        
        self.form = form
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "doLogin", name: LoginNotification, object: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func formViewController(controller: FormViewController, didSelectRowDescriptor: FormRowDescriptor) {
        if (didSelectRowDescriptor.rowType == .Button) {
            let session = Session.sharedInstance
            //session.login("goldratio87@gmail.com", password: "f2720188fc444312d7dec4c3bb82f438")
            session.login("mqshen@126.com", password: "f2720188fc444312d7dec4c3bb82f438")
        }
    }

    func handler(response: NSDictionary) {
    }
    
    func doLogin() {
        let vc = MainViewController(nibName: nil, bundle: nil)
        self.presentViewController(vc, animated: true, completion: nil)
    }
}

