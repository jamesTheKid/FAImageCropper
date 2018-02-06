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
  
    @IBOutlet weak var bottomToolsView: UIStackView!
  
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var nextButton: UIButton!
  
    @IBOutlet weak var cameraButton: UIButton!
    @IBOutlet weak var librayButton: UIButton!
  
  
  
    // MARK: Public Properties
  
  
    var didSetupConstraint = false
    var albumName: String!
  
    let cameraView: FACameraView = FACameraView.instance()
    let libraryView: FALibraryView = FALibraryView.instance()
    let albumView = FAPhotoPickerAlbumView.instance()
    
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
      
      albumView.delegate = self
    
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
      
      albumName = "All Photos"
      selectedAlbumButton.setTitle(albumName, for: .normal)
      let contraint = selectedAlbumButton.titleLabel?.intrinsicContentSize
      selectedAlbumButton.updateConstraint(attribute: .width, value: (contraint?.width)!)
      
      
      let downIcon = UIImage(named: "arrowDown.png", in: Bundle(for: self.classForCoder), compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)
      
      arrowImageView.image = downIcon
      albumView.frame = CGRect(x: 0, y: view.frame.height, width: view.frame.width, height: view.frame.height - 44.0)
      
      view.addSubview(self.albumView)
      
    }
  
    override func viewDidLayoutSubviews() {
      
      if didSetupConstraint == false {
        self.libraryView.frame = CGRect(origin:CGPoint.zero, size: self.globalScrollView.frame.size)
        let cameraViewFrameOrigin = CGPoint(x: self.view.frame.size.width,y: 0)
        self.cameraView.frame = CGRect(origin:cameraViewFrameOrigin , size: self.globalScrollView.frame.size)
        albumView.frame = CGRect(x: 0, y: view.frame.height, width: view.frame.width, height: view.frame.height - 44.0)
        
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
      self.nextButton.isHidden = false
      selectedAlbumButton.setTitle(albumName, for: .normal)
      globalScrollView.setContentOffset(CGPoint(x:0, y:0), animated: true)
      librayButton.setTitleColor(UIColor.white, for: .normal)
      cameraButton.setTitleColor(UIColor.lightGray, for: .normal)
    }
  
    @IBAction func cameraAction(_ sender: UIButton) {
      self.arrowImageView.isHidden = true
      self.nextButton.isHidden = true
      selectedAlbumButton.setTitle("Photo", for: .normal)
      globalScrollView.setContentOffset(CGPoint(x:self.globalScrollView.frame.width, y:0), animated: true)
      cameraButton.setTitleColor(UIColor.white, for: .normal)
      librayButton.setTitleColor(UIColor.lightGray, for: .normal)
    }
  
  
    @IBAction func showAlbums(_ sender: UIButton) {
      
       if !selectedAlbumButton.isSelected {
        selectedAlbumButton.isSelected = true
        
        
        UIView.animate(withDuration: 0.3, animations: {
          var rect = self.bottomToolsView.frame
          rect.origin.y = self.view.frame.height
          self.bottomToolsView.frame = rect
        })
        
        UIView.animate(withDuration: 1, delay: 0.3, usingSpringWithDamping: 12, initialSpringVelocity: 12, options: .layoutSubviews, animations: {
          self.albumView.frame = CGRect(x: 0, y: 44, width: self.view.frame.width, height: self.view.frame.height - 44.0)
          self.arrowImageView.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi))
          
          self.cancelButton.isHidden = true
          self.nextButton.isHidden = true
        }) { (isComplete) in
          
          
        }
      }else {
        // handle hidden album list.
        UIView.animate(withDuration: 0.3, animations: {
          self.albumView.frame = CGRect(x: 0, y: self.view.frame.height, width: self.view.frame.width, height: self.view.frame.height - 44.0)
          self.arrowImageView.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi * 2))
          self.cancelButton.isHidden = false
          self.nextButton.isHidden = false
        })
        
        selectedAlbumButton.isSelected = false
        UIView.animate(withDuration: 1, delay: 0.3, usingSpringWithDamping: 12, initialSpringVelocity: 12, options: .layoutSubviews, animations: {
          
          var rect = self.bottomToolsView.frame
          rect.origin.y = self.view.frame.height - 44.0
          self.bottomToolsView.frame = rect
        }, completion: { (isComplete) in
          
        })
        
      }
    }

}


extension FAImageCropperVC:  FACameraViewDelegate, FAPhotoPickerAlbumViewDelegate{
  
  func didShootPhoto(image: UIImage, metaData: [String : Any]) {
    
    print("didShootPhoto")
    //croppedImage = image
    //performSegue(withIdentifier: "FADetailViewSegue", sender: nil)
  }
  
  
  func didSeletctAlbum(album: AlbumModel) {
    
    albumName = album.name
    selectedAlbumButton.setTitle(albumName, for: .normal)
    
    let contentSize = selectedAlbumButton.titleLabel?.intrinsicContentSize
    
    selectedAlbumButton.updateConstraint(attribute: .width, value: (contentSize?.width)!)
    libraryView.albumSelected(fetchResult: album.assets)
    /*
    library.images = album.assets
    library.collectionView.reloadData()
    library.collectionView.selectItem(at: IndexPath.init(row: 0, section: 0), animated: false, scrollPosition: .bottom)
    album.fetchFirstImage { (image) in
      self.library.setupFirstLoadingImageAttribute(image: image)
      
    }
    */
    
    UIView.animate(withDuration: 0.3, animations: {
      self.albumView.frame = CGRect(x: 0, y: self.view.frame.height, width: self.view.frame.width, height: self.view.frame.height - 44.0)
      self.arrowImageView.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi * 2))
      self.cancelButton.isHidden = false
      self.nextButton.isHidden = false
    })
    
    selectedAlbumButton.isSelected = false
    UIView.animate(withDuration: 1, delay: 0.3, usingSpringWithDamping: 12, initialSpringVelocity: 12, options: .layoutSubviews, animations: {
      
      var rect = self.bottomToolsView.frame
      rect.origin.y = self.view.frame.height - 44.0
      self.bottomToolsView.frame = rect
    }, completion: { (isComplete) in
      
    })
    
  }
}





