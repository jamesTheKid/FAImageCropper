//
//  FAImageCropperVC.swift
//  FAImageCropper
//
//  Created by Fahid Attique on 11/02/2017.
//  Copyright © 2017 Fahid Attique. All rights reserved.
//

import UIKit

class FAImageCropperVC: UIViewController {
  
    
    // MARK: IBOutlets
    
    @IBOutlet weak var scrollContainerView: UIView!
    @IBOutlet weak var scrollView: FAScrollView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var btnZoom: UIButton!
    @IBOutlet weak var btnCrop: UIButton!
  
    @IBOutlet weak var globalScrollView: UIScrollView!
    @IBOutlet weak var selectedAlbumButton: UIButton!
    @IBOutlet weak var arrowImageView: UIImageView!
    @IBOutlet weak var cameraButton: UIButton!
    @IBOutlet weak var librayButton: UIButton!
  
    var currentAsset: PHAsset?
    var currentImageRequestID: PHImageRequestID?
    var isOnDownloadingImage: Bool = true
  
    @IBAction func zoom(_ sender: Any) {
        scrollView.zoom()
    }
    @IBAction func crop(_ sender: Any) {
        croppedImage = captureVisibleRect()
        performSegue(withIdentifier: "FADetailViewSegue", sender: nil)
    }
    
    
    
    // MARK: Public Properties
  
    let cameraView: FACameraView = FACameraView.instance()
  
    var photos:[PHAsset]!
    var imageViewToDrag: UIImageView!
    var indexPathOfImageViewToDrag: IndexPath!
    
    let cellWidth = ((UIScreen.main.bounds.size.width)/3)-1
  
    var croppedImage: UIImage? = nil
    
    // MARK: Private Properties
    
    private let imageLoader = FAImageLoader()
    //private var croppedImage: UIImage? = nil

    
    
    // MARK: LifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.\
        viewConfigurations()
        checkForPhotosPermission()
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
            detailVC?.croppedImage = croppedImage
        }
    }
    
    // MARK: Private Functions
    
    private func checkForPhotosPermission(){
        
        // Get the current authorization state.
        let status = PHPhotoLibrary.authorizationStatus()
        
        if (status == PHAuthorizationStatus.authorized) {
            // Access has been granted.
            loadPhotos()
        }
        else if (status == PHAuthorizationStatus.denied) {
            // Access has been denied.
        }
        else if (status == PHAuthorizationStatus.notDetermined) {
            
            // Access has not been determined.
            PHPhotoLibrary.requestAuthorization({ (newStatus) in
                
                if (newStatus == PHAuthorizationStatus.authorized) {
                    
                    DispatchQueue.main.async {
                        self.loadPhotos()
                    }
                }
                else {
                    // Access has been denied.
                }
            })
        }
            
        else if (status == PHAuthorizationStatus.restricted) {
            // Restricted access - normally won't happen.
        }
    }
    
    private func viewConfigurations() {
        
        //navigationBarConfigurations()
        btnCrop.layer.cornerRadius = btnCrop.frame.size.width/2
        btnZoom.layer.cornerRadius = btnZoom.frame.size.width/2
      
      
        globalScrollView.contentSize = CGSize(width: self.view.frame.size.width*2, height: self.globalScrollView.frame.height)
      
      
        let cameraViewFrameOrigin = CGPoint(x: self.view.frame.size.width,y: 0)
        self.cameraView.frame = CGRect(origin:cameraViewFrameOrigin , size: self.globalScrollView.frame.size)
      
        self.cameraView.startSession()
        self.cameraView.delegate = self
      
        self.globalScrollView.addSubview(self.cameraView)
        self.cameraView.layoutIfNeeded()
      
        scrollView.isScrollEnabled = false
      
    }
    
    private func navigationBarConfigurations() {
    
        navigationController?.navigationBar.backgroundColor = .black
        navigationController?.navigationBar.tintColor = .white
        navigationController?.navigationBar.setBackgroundImage(UIImage(color: .black), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage(color: .clear)
        navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName:UIColor.white]
    }

    
    private func loadPhotos(){

        imageLoader.loadPhotos { (assets) in
            self.configureImageCropper(assets: assets)
        }
    }
    
    private func configureImageCropper(assets:[PHAsset]){

        if assets.count != 0{
            photos = assets
            collectionView.delegate = self
            collectionView.dataSource = self
            collectionView.reloadData()
            selectDefaultImage()
        }
    }

    private func selectDefaultImage(){
        collectionView.selectItem(at: IndexPath(item: 0, section: 0), animated: true, scrollPosition: .top)
        //selectImageFromAssetAtIndex(index: 0)
      downloadSelectImageFromAssetAtIndex(index: 0)
    }
    
    
    private func captureVisibleRect() -> UIImage{
        
        var croprect = CGRect.zero
        let xOffset = (scrollView.imageToDisplay?.size.width)! / scrollView.contentSize.width;
        let yOffset = (scrollView.imageToDisplay?.size.height)! / scrollView.contentSize.height;
        
        croprect.origin.x = scrollView.contentOffset.x * xOffset;
        croprect.origin.y = scrollView.contentOffset.y * yOffset;
        
        let normalizedWidth = (scrollView?.frame.width)! / (scrollView?.contentSize.width)!
        let normalizedHeight = (scrollView?.frame.height)! / (scrollView?.contentSize.height)!
        
        croprect.size.width = scrollView.imageToDisplay!.size.width * normalizedWidth
        croprect.size.height = scrollView.imageToDisplay!.size.height * normalizedHeight
        
        let toCropImage = scrollView.imageView.image?.fixImageOrientation()
        let cr: CGImage? = toCropImage?.cgImage?.cropping(to: croprect)
        let cropped = UIImage(cgImage: cr!)
        
        return cropped

    }
  
    func reziseCameraImage(image: UIImage) -> UIImage{
      
      var croprect = CGRect.zero
      let xOffset = image.size.width / scrollView.contentSize.width;
      let yOffset = image.size.height / scrollView.contentSize.width;
      
      croprect.origin.x = scrollView.contentOffset.x * xOffset;
      croprect.origin.y = scrollView.contentOffset.y * yOffset;
      
      let normalizedWidth = (scrollView?.frame.width)! / (scrollView?.contentSize.width)!
      let normalizedHeight = (scrollView?.frame.height)! / (scrollView?.contentSize.height)!
      
      croprect.size.width = image.size.width * normalizedWidth
      croprect.size.height = image.size.height * normalizedHeight
      
      let toCropImage = image.fixImageOrientation()
      let cr: CGImage? = toCropImage.cgImage?.cropping(to: croprect)
      let cropped = UIImage(cgImage: cr!)
      
      return cropped
      
    }
  
    private func isSquareImage() -> Bool{
        let image = scrollView.imageToDisplay
        if image?.size.width == image?.size.height { return true }
        else { return false }
    }

    override  public var prefersStatusBarHidden : Bool {
      
      return true
    }
  
    // MARK: Public Functions

    func selectImageFromAssetAtIndex(index:NSInteger){
      let targetSize = CGSize(width: (currentAsset?.pixelWidth)!, height: (currentAsset?.pixelHeight)!)
      FAImageLoader.imageFrom(asset: photos[index], size: targetSize) { (image) in
            DispatchQueue.main.async {
                self.displayImageInScrollView(image: image)
            }
        }
      
    }
  
  
    func cancelDownloadInProgess(){
      
      if currentImageRequestID != nil {
        PHImageManager.default().cancelImageRequest(self.currentImageRequestID!)
      }
      
    }
  
    func downloadSelectImageFromAssetAtIndex(index:NSInteger){
      
      self.cancelDownloadInProgess()
      
      currentAsset = photos[index]
      
      let targetSize = CGSize(width: (currentAsset?.pixelWidth)!, height: (currentAsset?.pixelHeight)!)
      
      PHImageManager.default().requestImage(for: currentAsset!, targetSize: targetSize, contentMode: .aspectFill, options: nil) { (image, info) in
        //self.displayImageInScrollView(image: image!)
        
        DispatchQueue.main.async {
          if image != nil {
            self.displayImageInScrollView(image: image!)
          }
        }
      }
   
      
      //self.selectImageFromAssetAtIndex(index: index)
      
      isOnDownloadingImage = true
      
      let requestOptions = PHImageRequestOptions()
      requestOptions.isNetworkAccessAllowed = true
      requestOptions.isSynchronous = false
      requestOptions.deliveryMode = .highQualityFormat
      
      requestOptions.progressHandler = {(progress, err, pointer, info) in
        
        DispatchQueue.main.async {
          
          //if self.progressView.isHidden {
          //  self.progressView.isHidden = false
          //}
          
          //self.progressView.progress = CGFloat(progress)
          
          if progress == 1.0 {
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+0.3, execute: {
              //self.progressView.progress = 0.0
              //self.progressView.isHidden = true
            })
          }
        }
        print("progress \(progress)")
      }
      
      DispatchQueue.global(qos: DispatchQoS.QoSClass.default).async {
        
        self.currentImageRequestID = PHImageManager.default().requestImage(for: self.currentAsset!, targetSize: PHImageManagerMaximumSize, contentMode: .aspectFill, options: requestOptions) { (image, info) in
          
          
          if let isInCloud = info?[PHImageResultIsInCloudKey] as? Bool {
            self.isOnDownloadingImage = isInCloud
          }
          
          if image != nil {
            DispatchQueue.main.async {
              self.displayImageInScrollView(image: image!)
            }
          }
        }
        
        
      }
      
      
    }
    
    func displayImageInScrollView(image:UIImage){
        self.scrollView.imageToDisplay = image
        if isSquareImage() { btnZoom.isHidden = true }
        else { btnZoom.isHidden = false }
    }
    
    func replicate(_ image:UIImage) -> UIImage? {
        
        guard let cgImage = image.cgImage?.copy() else {
            return nil
        }

        return UIImage(cgImage: cgImage,
                               scale: image.scale,
                               orientation: image.imageOrientation)
    }
    

    func handleLongPressGesture(recognizer: UILongPressGestureRecognizer) {

        let location = recognizer.location(in: view)

        if recognizer.state == .began {

            let cell: FAImageCell = recognizer.view as! FAImageCell
            indexPathOfImageViewToDrag = collectionView.indexPath(for: cell)
            imageViewToDrag = UIImageView(image: replicate(cell.imageView.image!))
            imageViewToDrag.frame = CGRect(x: location.x - cellWidth/2, y: location.y - cellWidth/2, width: cellWidth, height: cellWidth)
            view.addSubview(imageViewToDrag!)
            view.bringSubview(toFront: imageViewToDrag!)
        }
        else if recognizer.state == .ended {
            
            if scrollView.frame.contains(location) {
                collectionView.selectItem(at: indexPathOfImageViewToDrag, animated: true, scrollPosition: UICollectionViewScrollPosition.centeredVertically)
              downloadSelectImageFromAssetAtIndex(index: indexPathOfImageViewToDrag.item)
            }
            
            imageViewToDrag.removeFromSuperview()
            imageViewToDrag = nil
            indexPathOfImageViewToDrag = nil
        }
        else{
            imageViewToDrag.center = location
        }
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





extension FAImageCropperVC:UICollectionViewDataSource{
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let cell:FAImageCell = collectionView.dequeueReusableCell(withReuseIdentifier: "FAImageCell", for: indexPath) as! FAImageCell
        cell.populateDataWith(asset: photos[indexPath.item])
        cell.configureGestureWithTarget(target: self, action: #selector(FAImageCropperVC.handleLongPressGesture))
        
        return cell
    }
}


extension FAImageCropperVC: UICollectionViewDelegate, FACameraViewDelegate{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photos.count
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell:FAImageCell = collectionView.cellForItem(at: indexPath) as! FAImageCell
        cell.isSelected = true
        //selectImageFromAssetAtIndex(index: indexPath.item)
        downloadSelectImageFromAssetAtIndex(index: indexPath.item)
    }

  
    func didShotPhoto(image: UIImage, metaData: [String : Any]) {
      croppedImage = image
      performSegue(withIdentifier: "FADetailViewSegue", sender: nil)
    }
  
}


extension FAImageCropperVC:UICollectionViewDelegateFlowLayout{
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: cellWidth, height: cellWidth)
    }
}
