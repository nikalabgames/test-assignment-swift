//
//  CollectionView.swift
//  TA1Swift
//
//  Created by Andrew on 20.06.2024.
//

import Foundation
import UIKit

class CollectionView : UICollectionView {
	
	lazy var adapter: CollectionViewAdapterProtocol = CollectionViewAdapter() {
		
		didSet {
			
			if let adapter = self.adapter as? CollectionViewAdapter {
				
				adapter.configure(for: self)
			}
		}
	}
	
	var flowLayout: UICollectionViewFlowLayout {
		
		if (self.collectionViewLayout as? UICollectionViewFlowLayout) == nil {
			
			self.collectionViewLayout = UICollectionViewFlowLayout()
		}
		
		return self.collectionViewLayout as! UICollectionViewFlowLayout
	}
	
	init(frame: CGRect = CGRect.zero, adapter: CollectionViewAdapterProtocol) {
		
		super.init(frame: frame, collectionViewLayout: UICollectionViewFlowLayout())
		self.adapter = adapter
		self.initialize()
	}
	
	required init?(coder: NSCoder) {
		
		super.init(coder: coder)
		self.initialize()
	}
	
	func initialize() {
		
		
	}
	
	override func reloadData() {
		
		self.reloadData(withLayout: true)
	}
	
	func reloadData(withLayout: Bool) {
		
		if let adapter = self.adapter as? CollectionViewAdapter {
			
			adapter.configure(for: self)
			
			if self.delegate === adapter {
				
				adapter.flowLayoutBlock?(self, self.flowLayout)
			}
		}
		
		super.reloadData()
		
		if withLayout {
			
			self.reloadLayout()
		}
	}
	
	func reloadLayout() {
		
		let oldLayout = self.flowLayout
		let newLayout = UICollectionViewFlowLayout()
		newLayout.estimatedItemSize = oldLayout.estimatedItemSize
		newLayout.footerReferenceSize = oldLayout.footerReferenceSize
		newLayout.headerReferenceSize = oldLayout.headerReferenceSize
		newLayout.itemSize = oldLayout.itemSize
		newLayout.minimumInteritemSpacing = oldLayout.minimumInteritemSpacing
		newLayout.minimumLineSpacing = oldLayout.minimumLineSpacing
		newLayout.scrollDirection = oldLayout.scrollDirection
		newLayout.sectionFootersPinToVisibleBounds = oldLayout.sectionFootersPinToVisibleBounds
		newLayout.sectionHeadersPinToVisibleBounds = oldLayout.sectionHeadersPinToVisibleBounds
		newLayout.sectionInset = oldLayout.sectionInset
		newLayout.sectionInsetReference = oldLayout.sectionInsetReference
		self.setCollectionViewLayout(newLayout, animated: false)
	}
}

extension UICollectionViewCell {
	
	var customView: ViewModelProtocol? {
		
		return self.contentView.subviews.first as? ViewModelProtocol
	}
}

protocol CollectionViewAdapterProtocol : ScrollViewAdapterProtocol, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
	
	typealias CollectionViewAdapterFeederBlock = (UICollectionView) -> [Any]
	typealias CollectionViewAdapterFlowLayoutBlock = (UICollectionView, UICollectionViewFlowLayout) -> Void
	typealias CollectionViewAdapterSectionsBlock = (UICollectionView) -> Int
	typealias CollectionViewAdapterSectionInsetBlock = (UICollectionView, Int) -> UIEdgeInsets
	typealias CollectionViewAdapterItemsBlock = (UICollectionView, Int) -> Int
	typealias CollectionViewAdapterSizeBlock = (UICollectionView, IndexPath) -> CGSize
	typealias CollectionViewAdapterCellBlock = (UICollectionView, IndexPath, UICollectionViewCell) -> UICollectionViewCell
	typealias CollectionViewAdapterClickBlock = (UICollectionView, IndexPath) -> Void
	typealias CollectionViewAdapterSupplementarySizeBlock = (UICollectionView, Int) -> CGSize
	typealias CollectionViewAdapterSupplementaryViewBlock = (UICollectionView, IndexPath, UICollectionReusableView) -> UICollectionReusableView?
	
	var viewClass: AnyClass? { get set }
	var items: [Any] { get set }
	var cellIdentifier: String { get set }
	
	@discardableResult
	func withViewClass(_ viewClass: AnyClass) -> Self
	
	@discardableResult
	func feeder(_ block: @escaping CollectionViewAdapterFeederBlock) -> Self
	
	@discardableResult
	func flowLayout(_ block: @escaping CollectionViewAdapterFlowLayoutBlock) -> Self
	
	@discardableResult
	func numberOfSections(_ block: @escaping CollectionViewAdapterSectionsBlock) -> Self
	
	@discardableResult
	func insetForSection(_ block: @escaping CollectionViewAdapterSectionInsetBlock) -> Self
	
	@discardableResult
	func numberOfItems(_ block: @escaping CollectionViewAdapterItemsBlock) -> Self
	
	@discardableResult
	func sizeForItem(_ block: @escaping CollectionViewAdapterSizeBlock) -> Self
	
	@discardableResult
	func cellForItem(_ block: @escaping CollectionViewAdapterCellBlock) -> Self
	
	@discardableResult
	func willDisplayCellForItem(_ block: @escaping CollectionViewAdapterCellBlock) -> Self
	
	@discardableResult
	func didSelectItem(_ block: @escaping CollectionViewAdapterClickBlock) -> Self
	
	@discardableResult
	func sizeForHeader(_ block: @escaping CollectionViewAdapterSupplementarySizeBlock) -> Self
	
	@discardableResult
	func viewForHeader(_ block: @escaping CollectionViewAdapterSupplementaryViewBlock) -> Self
	
	@discardableResult
	func sizeForFooter(_ block: @escaping CollectionViewAdapterSupplementarySizeBlock) -> Self
	
	@discardableResult
	func viewForFooter(_ block: @escaping CollectionViewAdapterSupplementaryViewBlock) -> Self
}

class CollectionViewAdapter : ScrollViewAdapter, CollectionViewAdapterProtocol {
			
	var viewClass: AnyClass?
	
	var _items: [Any] = []
	var items: [Any] {
		
		set { _items = newValue }
		
		get {
			
			if _items.count == 0 && self.feederBlock != nil && self.collectionView != nil {
				
				return self.feederBlock!(self.collectionView!)
			}
			
			return _items
		}
	}
	
	private var _cellIdentifier: String?
	var cellIdentifier: String {
		
		set { _cellIdentifier = newValue }
		
		get {
			
			if _cellIdentifier == nil || _cellIdentifier!.isEmpty {
				
				_cellIdentifier = "\(String(describing: viewClass))CellIdentifier"
			}
			
			return _cellIdentifier!
		}
	}
	
	private weak var collectionView: CollectionView?
	private var cellClassRegistration = Once()
	private var headerClassRegistration = Once()
	private var footerClassRegistration = Once()
	
	init(reuseIdentifier: String = "") {
		
		super.init()
		self.cellIdentifier = reuseIdentifier
	}
	
	func configure(for collectionView: CollectionView) {
		
		if self.collectionView != collectionView {
			
			self.collectionView = collectionView
			self.cellClassRegistration.already = false
			self.headerClassRegistration.already = false
			self.footerClassRegistration.already = false
			
			if collectionView.delegate == nil {

				collectionView.delegate = self
			}

			if collectionView.dataSource == nil {

				collectionView.dataSource = self
			}
			
			if collectionView.dataSource === self {
				
				collectionView.backgroundColor = .clear
				collectionView.contentInsetAdjustmentBehavior = .never
				collectionView.automaticallyAdjustsScrollIndicatorInsets = false
				self.registerDefaultCellClass(for: collectionView)
			}
		}
	}
	
	@discardableResult
	func withViewClass(_ viewClass: AnyClass) -> Self {
		
		self.viewClass = viewClass
		return self
	}
	
	override func responds(to aSelector: Selector!) -> Bool {

		if aSelector == #selector(collectionView(_:layout:referenceSizeForHeaderInSection:)) {

			return self.sizeForHeaderBlock != nil
		}
		else if aSelector == #selector(collectionView(_:layout:referenceSizeForFooterInSection:)) {

			return self.sizeForFooterBlock != nil
		}
		else if aSelector == #selector(collectionView(_:viewForSupplementaryElementOfKind:at:)) {

			return self.viewForHeaderBlock != nil || self.viewForFooterBlock != nil
		}

		return super.responds(to: aSelector)
	}
	
	//MARK: feeder
	
	private var feederBlock: CollectionViewAdapterFeederBlock?
	
	@discardableResult
	func feeder(_ block: @escaping CollectionViewAdapterFeederBlock) -> Self {
		
		self.feederBlock = block
		return self
	}
	
	//MARK: flowLayout
		
	fileprivate var flowLayoutBlock: CollectionViewAdapterFlowLayoutBlock?
	
	@discardableResult
	func flowLayout(_ block: @escaping CollectionViewAdapterFlowLayoutBlock) -> Self {
		
		self.flowLayoutBlock = block
		return self
	}
	
	//MARK: sections
	
	private var sectionsBlock: CollectionViewAdapterSectionsBlock?
	
	@discardableResult
	func numberOfSections(_ block: @escaping CollectionViewAdapterSectionsBlock) -> Self {
		
		self.sectionsBlock = block
		return self
	}
	
	func numberOfSections(in collectionView: UICollectionView) -> Int {
		
		return self.sectionsBlock?(collectionView) ?? 1
	}
	
	//MARK: section inset
	
	private var insetBlock: CollectionViewAdapterSectionInsetBlock?
	
	@discardableResult
	func insetForSection(_ block: @escaping CollectionViewAdapterSectionInsetBlock) -> Self {
		
		self.insetBlock = block
		return self
	}
	
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
		
		let inset = (collectionViewLayout as? UICollectionViewFlowLayout)?.sectionInset ?? UIEdgeInsets.zero
		return self.insetBlock?(collectionView, section) ?? inset
	}
	
	//MARK: items
	
	private var itemsBlock: CollectionViewAdapterItemsBlock?
	
	@discardableResult
	func numberOfItems(_ block: @escaping CollectionViewAdapterItemsBlock) -> Self {
		
		self.itemsBlock = block
		return self
	}
	
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		
		if self.itemsBlock != nil {
			
			return self.itemsBlock!(collectionView, section)
		}
		
		if let feeder = self.feederBlock {
			
			return feeder(collectionView).count
		}
		
		return items.count
	}
	
	//MARK: size
	
	private var sizeBlock: CollectionViewAdapterSizeBlock?
	
	@discardableResult
	func sizeForItem(_ block: @escaping CollectionViewAdapterSizeBlock) -> Self {
		
		self.sizeBlock = block
		return self
	}
	
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
		
		let size = (collectionViewLayout as? UICollectionViewFlowLayout)?.itemSize ?? CGSize.zero
		return self.sizeBlock?(collectionView, indexPath) ?? size
	}

//	@available(iOS 6.0, *)
//	optional func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat
//
//	@available(iOS 6.0, *)
//	optional func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat
	
	//MARK: cell
	
	private var cellBlock: CollectionViewAdapterCellBlock?
	
	@discardableResult
	func cellForItem(_ block: @escaping CollectionViewAdapterCellBlock) -> Self {
		
		self.cellBlock = block
		return self
	}
	
	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		
		let cell = collectionView.dequeueReusableCell(withReuseIdentifier: self.cellIdentifier, for: indexPath )
		cell.contentView.backgroundColor = collectionView.backgroundColor
		cell.backgroundColor = collectionView.backgroundColor
		
		if cell.contentView.subviews.isEmpty, let viewClass = self.viewClass as? ViewProtocol.Type {
			
			let view = viewClass.view()
			cell.contentView.addSubview(view)
			view.frame = cell.bounds
			view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
		}
		
		var model: Any?
		
		if let feederBlock = self.feederBlock {
			
			model = feederBlock(collectionView)[indexPath.row]
		}
		else if indexPath.row < items.count {
			
			model = items[indexPath.row]
		}
		
		if let model = model as? Model,
		   let view = cell.contentView.subviews.first as? ViewModelProtocol {
			
			view.model = model
		}
	
		guard let block = self.cellBlock else { return cell }
		return block(collectionView, indexPath, cell)
	}
	
	//MARK: willDisplay
	
	private var willDisplayBlock: CollectionViewAdapterCellBlock?
	
	@discardableResult
	func willDisplayCellForItem(_ block: @escaping CollectionViewAdapterCellBlock) -> Self {
		
		self.willDisplayBlock = block
		return self
	}
	
	func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
		
		_ = self.willDisplayBlock?(collectionView, indexPath, cell)
	}
	
	//MARK: didSelect
	
	private var didSelectBlock: CollectionViewAdapterClickBlock?
	
	@discardableResult
	func didSelectItem(_ block: @escaping CollectionViewAdapterClickBlock) -> Self {
		
		self.didSelectBlock = block
		return self
	}
	
	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		
		self.didSelectBlock?(collectionView, indexPath)
	}
	
	//MARK: sizeForHeader
	
	fileprivate var sizeForHeaderBlock: CollectionViewAdapterSupplementarySizeBlock?
	
	@discardableResult
	func sizeForHeader(_ block: @escaping CollectionViewAdapterSupplementarySizeBlock) -> Self {
		
		self.sizeForHeaderBlock = block
		return self
	}
	
	@objc func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
		
		self.registerDefaultHeaderClass(for: collectionView)
		return self.sizeForHeaderBlock?(collectionView, section) ?? CGSize.zero
	}
	
	//MARK: sizeForFooter
	
	fileprivate var sizeForFooterBlock: CollectionViewAdapterSupplementarySizeBlock?
	
	@discardableResult
	func sizeForFooter(_ block: @escaping CollectionViewAdapterSupplementarySizeBlock) -> Self {
		
		self.sizeForFooterBlock = block
		return self
	}
	
	@objc func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
	
		self.registerDefaultFooterClass(for: collectionView)
		return self.sizeForFooterBlock?(collectionView, section) ?? CGSize.zero
	}
	
	//MARK: viewForHeader / viewForFooter
	
	fileprivate var viewForHeaderBlock: CollectionViewAdapterSupplementaryViewBlock?
	
	@discardableResult
	func viewForHeader(_ block: @escaping CollectionViewAdapterSupplementaryViewBlock) -> Self {
		
		self.viewForHeaderBlock = block
		return self
	}
	
	fileprivate var viewForFooterBlock: CollectionViewAdapterSupplementaryViewBlock?
	
	@discardableResult
	func viewForFooter(_ block: @escaping CollectionViewAdapterSupplementaryViewBlock) -> Self {
		
		self.viewForFooterBlock = block
		return self
	}
	
	func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
		
		if kind == UICollectionView.elementKindSectionHeader {
			
			self.registerDefaultHeaderClass(for: collectionView)
		}
		else if kind == UICollectionView.elementKindSectionFooter {
			
			self.registerDefaultFooterClass(for: collectionView)
		}
		
		let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: self.cellIdentifier, for: indexPath)
		
		if kind == UICollectionView.elementKindSectionHeader {
			
			return self.viewForHeaderBlock?(collectionView, indexPath, view) ?? view
		}
		else if kind == UICollectionView.elementKindSectionFooter {
			
			return self.viewForFooterBlock?(collectionView, indexPath, view) ?? view
		}
		
		return view
	}
	
	//MARK: default class registration
	
	func registerDefaultCellClass(for collectionView: UICollectionView) {
		
		self.cellClassRegistration.run { [weak collectionView] in
			
			collectionView?.register(UICollectionViewCell.self, forCellWithReuseIdentifier: self.cellIdentifier)
		}
	}
	
	func registerDefaultHeaderClass(for collectionView: UICollectionView) {
		
		self.headerClassRegistration.run { [weak collectionView] in
			
			collectionView?.register(UICollectionReusableView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: self.cellIdentifier)
		}
	}
	
	func registerDefaultFooterClass(for collectionView: UICollectionView) {
		
		self.footerClassRegistration.run { [weak collectionView] in
			
			collectionView?.register(UICollectionReusableView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: self.cellIdentifier)
		}
	}
}



protocol ScrollViewAdapterProtocol : UIScrollViewDelegate {
	
	typealias ScrollViewAdapterDidScrollBlock = (UIScrollView) -> Void
	
	@discardableResult
	func didScroll(_ block: @escaping ScrollViewAdapterDidScrollBlock) -> Self
}

class ScrollViewAdapter : NSObject, ScrollViewAdapterProtocol {
		
	private var didScrollBlock: ScrollViewAdapterDidScrollBlock?
	
	@discardableResult
	func didScroll(_ block: @escaping ScrollViewAdapterDidScrollBlock) -> Self {
		
		self.didScrollBlock = block
		return self
	}
	
	func scrollViewDidScroll(_ scrollView: UIScrollView) {
		
		self.didScrollBlock?(scrollView)
	}
}
