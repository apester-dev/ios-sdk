//
//  FeedViewController.swift
//  ApesterDemo
//
//  Created by Asaf Baibekov on 22/11/2022.
//
import Foundation
import UIKit
import ApesterKit
///
///
///
public protocol FeedViewControllerDelegate : AnyObject
{
    func navigateBack()
}
///
///
///
class FeedViewController : UIViewController , Nibable , ViewModelable
{
    
    // MARK: - Properties
    var viewModel : FeedViewModel!
    weak var delegate: FeedViewControllerDelegate?
    
    // MARK: - @IBOutlet
    @IBOutlet private weak var collectionView: UICollectionView! {
        didSet {
            collectionView.showsHorizontalScrollIndicator = false
            collectionView.showsVerticalScrollIndicator = false
        }
    }
    @IBOutlet weak var collectionLayout: DynamicHightLayout! {
        didSet {
            
        }
    }
    
    // MARK: - @IBAction
    @objc
    @IBAction func refreshButtonClick()
    {    
        let service = APEViewService.shared
        viewModel.environmentData.unitIdentifiers.forEach { identifier in
            service.unitView(for: identifier)?.reload()
        }
    }
    
    // MARK: - Selector activations
    @objc func navigateBack()
    {
        delegate?.navigateBack()
    }
    
    
    // MARK: - LifeCycle

    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        title = "News Feed"
        
        setupApesterViews()
        setupNavigationViews()
        setupCollectionViews()
    }
    
    deinit {
        // Moved to waiting screen
        // APEViewService.shared.unloadUnitViews(with: viewModel.environmentData.unitIdentifiers)
    }
    
    override func viewDidAppear(_ animated: Bool)
    {
        super.viewDidAppear(animated)
        
        let service = APEViewService.shared
        viewModel.environmentData.unitIdentifiers.forEach { identifier in
            service.unitView(for: identifier)?.resume()
        }
    }
    
    override func viewDidDisappear(_ animated: Bool)
    {
        super.viewDidDisappear(animated)
        
        let service = APEViewService.shared
        viewModel.environmentData.unitIdentifiers.forEach { identifier in
            service.unitView(for: identifier)?.stop()
        }
    }
    
    // MARK: - Helper methods
    func setupApesterViews()
    {
        let service = APEViewService.shared
        
        viewModel.environmentData.unitConfigurations.forEach { configuration in
            
            if service.unitView(for: configuration.unitParams.id) == nil {
                
                // not preload!
                service.preloadUnitViews(with: [configuration])
            }
            service.unitView(for: configuration.unitParams.id)?.delegate = self
        }
    }
    func setupCollectionViews()
    {
        // collectionLayout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
        collectionLayout.minimumInteritemSpacing = 10
        collectionLayout.minimumLineSpacing = 10
        
        // collectionView.collectionViewLayout = collectionLayout
        collectionView.contentInsetAdjustmentBehavior = .always
        collectionView.register(FeedArticleCell.nib, forCellWithReuseIdentifier: FeedArticleCell.reuseIdentifier)
        collectionView.register(FeedApesterCell.nib, forCellWithReuseIdentifier: FeedApesterCell.reuseIdentifier)
        collectionView.delegate   = self
        collectionView.dataSource = self
    }
    func setupNavigationViews()
    {
        let backSelector = #selector(navigateBack)
        // Use custom back button to pass through coordinator.
        let backButton = UIBarButtonItem(title: "Back", style: .plain, target: self, action: backSelector)
        navigationItem.leftBarButtonItem = backButton
        
        let refreshSelector = #selector(refreshButtonClick)
        let refreshButton = UIBarButtonItem(title: "Refresh", style: .plain, target: self, action: refreshSelector)
        navigationItem.rightBarButtonItem = refreshButton
    }
}
///
///
///
extension FeedViewController : FeedViewModelDelegate
{
    func didUpdateInformation()
    {
        collectionView.reloadData()
    }
}
///
///
///
extension FeedViewController : APEUnitViewDelegate
{
    func unitView(_ unitView: APEUnitView, didFailLoadingUnit unitId: String)
    {
        logger.debug("unitId: \(unitId)")
        
        DispatchQueue.main.async {
            
            APEViewService.shared.unloadUnitViews(with: [unitId])
            self.collectionView.reloadData()
        }
    }
    
    func unitView(_ unitView: APEUnitView, didFinishLoadingUnit unitId: String)
    {
        logger.debug("unitId: \(unitId)")
    }
    
    func unitView(_ unitView: APEUnitView, didCompleteAdsForUnit unitId: String)
    {
        logger.debug("unitId: \(unitId)")
    }
    
    func unitView(_ unitView: APEUnitView, didUpdateHeight height: CGFloat)
    {
        logger.debug("unitId: \(unitView.configuration.unitParams.id), ### height: \(height)")
        
        collectionView.reloadData()
    }
}
///
///
///
extension FeedViewController : UICollectionViewDataSource
{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        return viewModel.itemsCount
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        guard let feedItem = viewModel.item(at: indexPath.item) else { return UICollectionViewCell() }
        
        let identifier : String
        switch feedItem.type {
        case .ad     : identifier = FeedApesterCell.reuseIdentifier
        case .article: identifier = FeedArticleCell.reuseIdentifier
        }
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath)
        
        switch feedItem.type {
        case .ad:
            if let unit = viewModel.environmentData.unitParameters.first
            {
                let unitView = APEViewService.shared.unitView(for: unit.id)
                (cell as? FeedApesterCell)?.show(unitView: unitView, containerViewController: self)
                // unitView?.setGdprString(viewModel.environmentData.gdprToken)
            }
        case .article:
            (cell as? FeedArticleCell)?.setupView(with: feedItem)
        }
        return cell
    }
}
///
///
///
extension FeedViewController : UICollectionViewDelegate
{
}
///
///
///
extension FeedViewController : UICollectionViewDelegateFlowLayout
{
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize
    {
        switch viewModel.item(at: indexPath.item)?.type {
        case .ad     :
            if let unit = viewModel.environmentData.unitParameters.first
            {
                let unitView = APEViewService.shared.unitView(for: unit.id)
                return CGSize(width: collectionView.bounds.width, height: unitView?.height ?? CGFloat(10.0))
            }
            fallthrough
            
        case .article: fallthrough
        case .none:
            return collectionView.bounds.size
        }
    }
}
// =====================================================================================================================
//{
//    "type": "ad",
//    "object": {
//        "link": "https://cocacola.co.il/",
//        "title": "Coca Cola",
//        "image_link": "https://datantify.com/knowledge/wp-content/uploads/2019/07/coca-cola_the_pause_that_refreshes_1931-610x697.jpg"
//    }
//},
// =====================================================================================================================
//{
//    "data": [
//        {
//            "type": "ad",
//            "object": {
//                "link": "https://cocacola.co.il/",
//                "title": "Coca Cola",
//                "image_link": "https://datantify.com/knowledge/wp-content/uploads/2019/07/coca-cola_the_pause_that_refreshes_1931-610x697.jpg"
//            }
//        },
//        {
//            "type": "article",
//            "object": {
//                "link": "https://www.bbc.com/news/world-us-canada-63643912",
//                "title": "Canada: Why the country wants to bring in 1.5m immigrants by 2025",
//                "subtitle": "Some Canadians are concerned the country's aggressive immigration targets are too high.",
//                "image_link": "https://ichef.bbci.co.uk/news/976/cpsprodpb/183A5/production/_127673299_14f94b50-aadb-4254-90f7-612906c8c00b.jpg"
//            }
//        },
//        {
//            "type": "article",
//            "object": {
//                "link": "https://cocacola.co.il/",
//                "title": "Coca Cola",
//                "subtitle": "The move comes after several countries had their votes cancelled at this year's contest.",
//                "image_link": "https://datantify.com/knowledge/wp-content/uploads/2019/07/coca-cola_the_pause_that_refreshes_1931-610x697.jpg"
//            }
//        },
//        {
//            "type": "article",
//            "object": {
//                "link": "https://www.bbc.com/news/entertainment-arts-63716398",
//                "title": "Eurovision scraps jury voting in semi-finals - BBC News",
//                "subtitle": "The move comes after several countries had their votes cancelled at this year's contest.",
//                "image_link": "https://ichef.bbci.co.uk/news/976/cpsprodpb/172A3/production/_127738849_hi079361089.jpg"
//            }
//        },
//        {
//            "type": "article",
//            "object": {
//                "link": "https://www.kicker.de/nicht-akzeptabel-rewe-beendet-kooperation-mit-dem-dfb-926740/artikel",
//                "title": "\"Nicht akzeptabel\": \"Rewe\" beendet Kooperation mit dem DFB",
//                "subtitle": "Wegen Verhalten der FIFA - VW bleibt im Boot",
//                "image_link": "https://ichef.bbci.co.uk/news/976/cpsprodpb/183A5/production/_127673299_14f94b50-aadb-4254-90f7-612906c8c00b.jpg"
//            }
//        },
//
//        {
//            "type": "article",
//            "object": {
//                "link": "https://www.kicker.de/furioses-jahr-endet-mit-niederlage-dbb-team-verliert-in-slowenien-925813/artikel",
//                "title": "Furioses Jahr endet mit Niederlage: DBB-Team verliert in Slowenien",
//                "subtitle": "WM-Qualifikation, 10. Spieltag: Terminkollisionen sorgen für Personalmangel",
//                "image_link": "https://ichef.bbci.co.uk/news/976/cpsprodpb/172A3/production/_127738849_hi079361089.jpg"
//            }
//        }
//    ]
//}
//
