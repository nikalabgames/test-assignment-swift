//
//  ViewController.swift
//  TA1Swift
//
//  Created by Ivan Manov on 29.03.2021.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        let sampleDataSource = SampleDataSource()
        sampleDataSource.loadMessages { (messages) in
            print("Show me \(messages)")
        }
    }


}

