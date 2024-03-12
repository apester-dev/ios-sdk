//
//  mainViewController.swift
//  ApesterKit_Example
//
//  Created by Michael Krotorio on 1/27/24.
//  Copyright © 2024 CocoaPods. All rights reserved.
//

import UIKit
import ApesterKit
import FirebaseAuth

class mainViewController: UIViewController {

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
    @IBOutlet weak var favoritesImage: UIImageView!
    @IBOutlet weak var likeButtonOutlet: UIImageView!
    
    var alertController: UIAlertController?
    
    @objc func showActionSheet() {
        guard let alertController = alertController else {
            return
        }
        present(alertController, animated: true, completion: nil)
     }
    
    @objc func showFavorites(){
        performSegue(withIdentifier: "showFavorites", sender: self)
//        let storyboard = UIStoryboard(name: "Main", bundle: nil)
//            if let newViewController = storyboard.instantiateViewController(withIdentifier: "favoritesViewController") as? APEUnitViewController {
//                self.navigationController?.pushViewController(newViewController, animated: true)
//            }else {
//                print("no view controller matches criteria ")
//            }
    }
    
    @objc func likeAction() {
            if !isLiked {
                // Logic to handle when the unit is liked (e.g., save to favorites)
                saveFavorite(userName: UserInfo.shared.userEmail ?? "default@mail.com", favorite: currentUnit?.mediaId ?? "")
            } else {
                // Logic to handle when the unit is unliked (e.g., remove from favorites)
                removeFavorite(userName: UserInfo.shared.userEmail ?? "default@mail.com")
            }
        self.updateLikeImage()
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
    private var currentUnit: ScreenContent? {
        didSet {
            updateLikeImage()
        }
    }
    
    var selctedType: UnitType {
        switch(unitTypesOutlet.selectedSegmentIndex){
        case 0: return UnitType.Poll
        case 1: return UnitType.Story
        case 2: return UnitType.Quiz
        default:
            return UnitType.Playlist
        }
    }
    
    private var _isLiked: Bool = false

    // Computed property for isLiked
    var isLiked: Bool {
        get {
            return _isLiked
        }
        set {
            _isLiked = newValue
            updateLikeImage()
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
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setUnitView(0, currentId: UserInfo.shared.favoriteId)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.hidesBackButton = false
        AppTrackingHelper.requestTrackingPermission(permissionCallback: {
            
        }, viewController: self)
//        setupCustomBackButton()
        updateLikeImage()
        setupGestures()
        
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
    func setupGestures(){
        settingsImage.isUserInteractionEnabled = true
        favoritesImage.isUserInteractionEnabled = true
        likeButtonOutlet.isUserInteractionEnabled = true

               // Set up tap gesture recognizer
        let tapGestureRecognizerSettings = UITapGestureRecognizer(target: self, action: #selector(showActionSheet))
        let tapGestureRecognizerFavorites = UITapGestureRecognizer(target: self, action: #selector(showFavorites))
        let tapGestureRecognizerlike = UITapGestureRecognizer(target: self, action: #selector(likeAction))
        settingsImage.addGestureRecognizer(tapGestureRecognizerSettings)
        favoritesImage.addGestureRecognizer(tapGestureRecognizerFavorites)
        likeButtonOutlet.addGestureRecognizer(tapGestureRecognizerlike)
    }
    
    func setUnitView(_ segmentIndex: Int, currentId: String? = nil){
        self.currentUnit = self.unitTypes[getIndexFofrCategoryAndType(category: selectedCategory, unitType: unitTypeBySelctedIndex(unitTypesOutlet.selectedSegmentIndex))][selectedCategory]
        if let mediaId = currentId {
            self.unitView = APEViewService.shared.unitView(for: currentUnit!.mediaId)
        } else {
            self.unitView = APEViewService.shared.unitView(for: currentUnit!.mediaId)
        }
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
    
    func updateLikeImage() {
        let usersFavId = UserInfo.shared.favoriteId
        let imageName = usersFavId == self.currentUnit?.mediaId ? "heart.fill" : "heart"
        likeButtonOutlet.image = UIImage(systemName: imageName)
    }


}

