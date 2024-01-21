//
//  ViewController.swift
//  ApesterTestApp
//
//  Created by Michael Krotorio on 11/26/23.
//

import UIKit
import ApesterKit

class ViewController: UIViewController {

    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var story_container: UIView!
    
    @IBAction func openLinkToApesterWeb(_ sender: Any) {
        if let url = URL(string: "https://content.apester.com") {
                    if UIApplication.shared.canOpenURL(url) {
                        UIApplication.shared.open(url, options: [:], completionHandler: nil)
                    }
                }
    }
    @IBOutlet weak var settingsImage: UIImageView!
    var alertController: UIAlertController?
    
    @objc func showActionSheet() {
        guard let alertController = alertController else {
            return
        }
        present(alertController, animated: true, completion: nil)
    }
    

    @IBOutlet weak var titleOutlet: UILabel!
    @IBOutlet weak var articleOutlet: UILabel!
    @IBOutlet weak var bottomArticleOutlet: UILabel!
    private var unitView: APEUnitView?
    private var mediaId: String?
    private var tags: [String]?
    private var channelToken: String?
    private var UnitConfig: APEUnitConfiguration?
    private var selectedCategory: Category = Category.lifestyle
    var selctedType: UnitType {
        switch(unitTypesOutlet.selectedSegmentIndex){
        case 0: return UnitType.Poll
        case 1: return UnitType.Story
        case 2: return UnitType.Quiz
        default:
            return UnitType.Playlist
        }
    }
    
    
    
    private var unitTypes:[[Category: ScreenContent]] {
        return fillTheArray(unitTypes: UnitConfigurationsFactory.unitsParams)
    }
    
    @IBOutlet weak var unitTypesOutlet: UISegmentedControl!
    @IBAction func UnitTypeSegment(_ sender: Any) {
        self.unitView?.hide()
        self.setUnitView( unitTypesOutlet.selectedSegmentIndex)
        self.unitView?.reload()
        view.layoutIfNeeded()
        self.scrollView.scrollToTop(animated: false)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        settingsImage.isUserInteractionEnabled = true

               // Set up tap gesture recognizer
               let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(showActionSheet))
               settingsImage.addGestureRecognizer(tapGestureRecognizer)
        
        // Add actions to the alertController
        self.alertController = UIAlertController(title: "Choose category", message: nil, preferredStyle: .actionSheet)

        alertController?.addAction(UIAlertAction(title: Category.lifestyle.rawValue, style: .default, handler: { [self] action in
            
            setCategory(category: Category(rawValue: title ?? Category.lifestyle.rawValue)!, type: unitTypeBySelctedIndex(unitTypesOutlet.selectedSegmentIndex))
            
        }))

        alertController?.addAction(UIAlertAction(title: Category.news.rawValue, style: .default, handler: { [self] action in
            setCategory(category: Category(rawValue: title ?? Category.news.rawValue)! , type: unitTypeBySelctedIndex(unitTypesOutlet.selectedSegmentIndex))

        }))

        alertController?.addAction(UIAlertAction(title: Category.sports.rawValue, style: .default, handler: { [self] action in
            // Handle Gaming action
            setCategory(category: Category(rawValue: title ?? Category.sports.rawValue)!, type: unitTypeBySelctedIndex(unitTypesOutlet.selectedSegmentIndex))
        }))

        self.setUnitView( unitTypesOutlet.selectedSegmentIndex)

    
    }
    
    override class func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func setUnitView(_ segmentIndex: Int){
        var currentUnit = self.unitTypes[getIndexFofrCategoryAndType(category: selectedCategory, unitType: unitTypeBySelctedIndex(unitTypesOutlet.selectedSegmentIndex))][selectedCategory]
        self.unitView = APEViewService.shared.unitView(for: currentUnit!.mediaId)
        self.unitView?.display(in: 
//                                unitTypeBySelctedIndex(unitTypesOutlet.selectedSegmentIndex) == UnitType.Story ? self.story_container :
                                self.containerView, containerViewController: self)
        self.titleOutlet.text = currentUnit!.article.title
        self.articleOutlet.text = currentUnit!.article.topArticle
        self.bottomArticleOutlet.text = currentUnit!.article.bottomArticle
        
    }
    func setCategory(category: Category, type: UnitType){
        selectedCategory = category
        setUnitView(getIndexFofrCategoryAndType(category: selectedCategory, unitType: type))
        self.scrollView.scrollToTop(animated: false)
    }
    
    func unitTypeBySelctedIndex(_ index: Int) -> UnitType {
        return index == 0 ? UnitType.Quiz : index == 1 ? UnitType.Story : UnitType.Poll
    }
       
    
    
   
    

}

