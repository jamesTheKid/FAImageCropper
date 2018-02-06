//
//  FAImageCropperVC.swift
//  FAImageCropper
//
//  Created by Fahid Attique on 11/02/2017.
//  Copyright © 2017 Fahid Attique. All rights reserved.
//

import UIKit
import Photos

class FAImageCropperVC: UIViewController {
  
    
    // MARK: IBOutlets
  
    @IBOutlet weak var globalScrollView: UIScrollView!
    @IBOutlet weak var selectedAlbumButton: UIButton!
    @IBOutlet weak var arrowImageView: UIImageView!
  
    @IBOutlet weak var cameraButton: UIButton!
    @IBOutlet weak var librayButton: UIButton!
  
    var didSetupConstraint = false
  
    // MARK: Public Properties
  
    let cameraView: FACameraView = FACameraView.instance()
    let libraryView: FALibraryView = FALibraryView.instance()
  
    
    // MARK: LifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.\
      
      
        checkForPhotosPermission{ (auth) in
          if !auth {
            print("User can not acess library.")
            return
          }
        }
      
        viewConfigurations()
        self.setNeedsStatusBarAppearanceUpdate()
      
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        print("did receive memory warning")
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "FADetailViewSegue" {
            
            let detailVC = segue.destination as? FADetailVC
            //detailVC?.croppedImage = croppedImage
        }
    }
    
    // MARK: Private Functions
    
    private func checkForPhotosPermission(authorized: @escaping (Bool) -> Void){
        
        // Get the current authorization state.
        let status = PHPhotoLibrary.authorizationStatus()
        
        if (status == PHAuthorizationStatus.authorized) {
            // Access has been granted.
            //loadPhotos()
            authorized(true)
        }
        else if (status == PHAuthorizationStatus.denied) {
            authorized(false)
        }
        else if (status == PHAuthorizationStatus.notDetermined) {
            
            // Access has not been determined.
            PHPhotoLibrary.requestAuthorization({ (newStatus) in
                
                if (newStatus == PHAuthorizationStatus.authorized) {
                    /*
                    DispatchQueue.main.async {
                        self.loadPhotos()
                    }
                    */
                  authorized(true)
                }
                else {
                    authorized(false)
                }
            })
        }
            
        else if (status == PHAuthorizationStatus.restricted) {
            // Restricted access - normally won't happen.
        }
      
    }
    
    private func viewConfigurations() {
    
      globalScrollView.contentSize = CGSize(width: self.view.frame.size.width*2, height: self.globalScrollView.frame.height)
    
      self.libraryView.frame = CGRect(origin:CGPoint.zero, size: self.globalScrollView.frame.size)
      let cameraViewFrameOrigin = CGPoint(x: self.view.frame.size.width,y: 0)
      self.cameraView.frame = CGRect(origin:cameraViewFrameOrigin , size: self.globalScrollView.frame.size)
    
      self.cameraView.delegate = self
    
      self.libraryView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
      self.cameraView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
      self.globalScrollView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
      
      self.globalScrollView.addSubview(self.libraryView)
      self.globalScrollView.addSubview(self.cameraView)
      
      self.globalScrollView.autoresizesSubviews = true
      
      self.libraryView.layoutIfNeeded()
      self.cameraView.layoutIfNeeded()
      
      globalScrollView.isScrollEnabled = false
      
      //navigationBarConfigurations()
      
    }
  
  
  
  override func viewDidLayoutSubviews() {
    
    
    if didSetupConstraint == false {
      self.libraryView.frame = CGRect(origin:CGPoint.zero, size: self.globalScrollView.frame.size)
      let cameraViewFrameOrigin = CGPoint(x: self.view.frame.size.width,y: 0)
      self.cameraView.frame = CGRect(origin:cameraViewFrameOrigin , size: self.globalScrollView.frame.size)
      self.cameraView.startSession()
      didSetupConstraint = true
    }
    
    
  }
    
    private func navigationBarConfigurations() {
    
        navigationController?.navigationBar.backgroundColor = .black
        navigationController?.navigationBar.tintColor = .white
        navigationController?.navigationBar.setBackgroundImage(UIImage(color: .black), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage(color: .clear)
        navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName:UIColor.white]
    }

  
    override  public var prefersStatusBarHidden : Bool {
      
      return true
    }
  
  
    // MARK: IBActions
    @IBAction func librayAction(_ sender: UIButton) {
      self.arrowImageView.isHidden = false
      //self.nextButton.isHidden = false
      //selectAlbumButton.setTitle(albumName, for: .normal)
      globalScrollView.setContentOffset(CGPoint(x:0, y:0), animated: true)
      librayButton.setTitleColor(UIColor.white, for: .normal)
      cameraButton.setTitleColor(UIColor.lightGray, for: .normal)
    }
  
    @IBAction func cameraAction(_ sender: UIButton) {
      self.arrowImageView.isHidden = true
      //self.nextButton.isHidden = true
      //selectAlbumButton.setTitle("Photo", for: .normal)
      globalScrollView.setContentOffset(CGPoint(x:self.globalScrollView.frame.width, y:0), animated: true)
      cameraButton.setTitleColor(UIColor.white, for: .normal)
      librayButton.setTitleColor(UIColor.lightGray, for: .normal)
    }

}


extension FAImageCropperVC:  FACameraViewDelegate{
  
  func didShootPhoto(image: UIImage, metaData: [String : Any]) {
    
    print("didShootPhoto")
    //croppedImage = image
    //performSegue(withIdentifier: "FADetailViewSegue", sender: nil)
  }
  
}



