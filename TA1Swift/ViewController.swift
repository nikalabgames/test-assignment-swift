//
//  ViewController.swift
//  TA1Swift
//
//  Created by Ivan Manov on 29.03.2021.
//

import UIKit

class ViewController: UIViewController {

	let collectionView = CollectionView(adapter: MessageViewAdapter())
	
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
		self.view.backgroundColor = .systemBackground
		
		self.collectionView.contentInsetAdjustmentBehavior = .always
		
		self.view.addSubview(collectionView)
		self.collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
		self.collectionView.frame = self.view.bounds
		
        let sampleDataSource = SampleDataSource()
        sampleDataSource.loadMessages { [weak self] (messages) in
            print("Show me \(messages)")
			
			self?.collectionView.adapter.items = messages.map{ MessageViewModel(message: $0) }
			self?.collectionView.reloadData()
        }		
    }
	
	override func viewWillAppear(_ animated: Bool) {
		
		super.viewWillAppear(animated)
		self.overrideUserInterfaceStyle = UIScreen.main.traitCollection.userInterfaceStyle
	}
	
	override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
		
		super.viewWillTransition(to: size, with: coordinator)
		collectionView.reloadItems(at: collectionView.indexPathsForVisibleItems)
	}
	
	override func viewSafeAreaInsetsDidChange() {
		
		super.viewSafeAreaInsetsDidChange()
		collectionView.reloadItems(at: collectionView.indexPathsForVisibleItems)
	}
}

