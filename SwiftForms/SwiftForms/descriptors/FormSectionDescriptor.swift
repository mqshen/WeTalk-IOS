//
//  FormSectionDescriptor.swift
//  SwiftForms
//
//  Created by Miguel Angel Ortuno on 20/08/14.
//  Copyright (c) 2014 Miguel Angel Ortuño. All rights reserved.
//

import UIKit

public class FormSectionDescriptor: NSObject {

    /// MARK: Properties
    
    var headerTitle: String!
    var footerTitle: String!
    
    var rows: [FormRowDescriptor] = []
    
    /// MARK: Public interface
    
    public func addRow(row: FormRowDescriptor) {
        rows.append(row)
    }
    
    public func removeRow(row: FormRowDescriptor) {
        if let index = find(rows, row) {
            rows.removeAtIndex(index)
        }
    }
}
