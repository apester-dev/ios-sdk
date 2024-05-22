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

class mainViewController: UIViewController, APEUnitViewDelegate {
    func unitView(_ unitView: ApesterKit.APEUnitView, didUpdateHeight height: CGFloat) {
        
    }
    func unitView(_ unitView: ApesterKit.APEUnitView, didCompleteAdsForUnit unitId: String) {
        
    }
    func unitView(_ unitView: APEUnitView, didFinishLoadingUnit unitId: String) {
        print("unit finished loading")
    }
    func unitView(_ unitView: APEUnitView, didFailLoadingUnit unitId: String) {
        print("unit failed to load ")
    }
    
    

    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var story_container: UIView!

    @IBOutlet weak var isPlaylistSwitchOutlet: UISwitch!
    @IBOutlet weak var input: UITextField!
    @IBAction func onSubmit(_ sender: Any) {
        setNewUnit()
    }
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


    
    private var unitView: APEUnitView?
    private var mediaId: String?
    private var channelToken: String?
    private var selectedEnvironment: Environment = .PROD
    private var baseUrl: String {
        switch (selectedEnvironment){
        case .PROD: return "https://renderer.apester.com/v2/static/in-app-unit-detached.html?__APESTER_DEBUG__=true"
        case .STAGE: return "https://renderer.stg.apester.dev/v2/static/in-app-unit-detached.html?__APESTER_DEBUG__=true"
        case .DEV: return "https://renderer.georgi.apester.dev/v2/static/in-app-unit-detached.html?__APESTER_DEBUG__=true"
        }
    }
    private var UnitConfig: APEUnitConfiguration?


    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.hidesBackButton = false
        setupGestures()
        setPlaceholderColor()
    }
    private func setPlaceholderColor() {
           let placeholderText = "enter unitId or channelToken/playlist"
           input.attributedPlaceholder = NSAttributedString(string: placeholderText, attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray])
       }
    
    override class func awakeFromNib() { 
        super.awakeFromNib()
    }
    func setupGestures(){
        settingsImage.isUserInteractionEnabled = true

               // Set up tap gesture recognizer
        let tapGestureRecognizerSettings = UITapGestureRecognizer(target: self, action: #selector(showActionSheet))
        settingsImage.addGestureRecognizer(tapGestureRecognizerSettings)
        setupSheet()
    }
    
    func setupSheet(){
        self.alertController = UIAlertController(title: "Choose Environment", message: nil, preferredStyle: .actionSheet)

        alertController?.addAction(UIAlertAction(title: Environment.PROD.rawValue, style: .default, handler: { [self] action in
            selectedEnvironment = Environment(rawValue: action.title!)!
        }))

        alertController?.addAction(UIAlertAction(title: Environment.STAGE.rawValue, style: .default, handler: { [self] action in
            selectedEnvironment = Environment(rawValue: action.title!)!
        }))

        alertController?.addAction(UIAlertAction(title: Environment.DEV.rawValue, style: .default, handler: { [self] action in
            selectedEnvironment = Environment(rawValue: action.title!)!
        }))
    }

    func setNewUnit() {
        guard let input = input.text else {
            return
        }
        if(!isPlaylistSwitchOutlet.isOn){
            let unitParams = APEUnitParams.unit(mediaId: input)
            let unitConfig = APEUnitConfiguration.init(unitParams: unitParams, bundle: .main, baseUrl: baseUrl)
            unitConfig.setFullscreen(true)
            self.unitView = APEUnitView(configuration: unitConfig)
            self.unitView?.delegate = self
            self.unitView?.display(in: containerView, containerViewController: self)
        }else {
            let playlistParams = APEUnitParams.playlist(tags: [], channelToken: input, context: true, fallback: true)
            let playlistConfig = APEUnitConfiguration(unitParams: playlistParams, bundle: .main, baseUrl: baseUrl)
            self.unitView = APEUnitView(configuration: playlistConfig)
            UnitConfig?.setFullscreen(true)
            self.unitView?.delegate = self
            self.unitView?.display(in: containerView, containerViewController: self)
            
        }
    }

}

