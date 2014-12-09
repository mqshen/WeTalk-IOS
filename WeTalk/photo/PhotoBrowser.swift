//
//  PhotoBrowser.swift
//  WeTalk
//
//  Created by GoldRatio on 12/9/14.
//  Copyright (c) 2014 GoldRatio. All rights reserved.
//

import Foundation
import UIKit
import SWWebImage

protocol PhotoBrowserDelegate {
    
    func photoBrowserDidChanged(photoBrowser: PhotoBrowser, index:Int)
    
}

class PhotoBrowser: UIViewController, UIScrollViewDelegate, PhotoViewDelegate {
    
    struct Singleton {
        static let kPadding: CGFloat = 10
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init() {
        super.init()
    }
    
    override init(nibName nibNameOrNil: String!, bundle nibBundleOrNil: NSBundle!) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    var delegate: PhotoBrowserDelegate?
    
    var photos: [Photo] = []
    
//    var photos: [Photo] {
//        get {
//            return _photos
//        }
//        set {
//            _photos = newValue
//            
//            for i in 0..<_photos.count {
//                let *photo = _photos[i];
//                photo.index = i;
//                photo.firstShow = i == _currentPhotoIndex;
//            }
//        }
//    }
    
    var currentPhotoIndex: Int = 0
    
    private var visiblePhotoViews: NSMutableSet = NSMutableSet()
    private var reusablePhotoViews: NSMutableSet = NSMutableSet()
    
    private var statusBarHiddenInited: Bool = false
    private var photoScrollView: UIScrollView?
    
    
    override func loadView() {
        self.statusBarHiddenInited = UIApplication.sharedApplication().statusBarHidden
        // 隐藏状态栏
        UIApplication.sharedApplication().setStatusBarHidden(true, withAnimation: UIStatusBarAnimation.Fade)
        self.view = UIView()
        self.view.frame = UIScreen.mainScreen().bounds
        self.view.backgroundColor = UIColor.blackColor()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.createScrollView()
    }
    
    func show() {
        if let window = UIApplication.sharedApplication().keyWindow? {
            window.addSubview(self.view)
            window.rootViewController?.addChildViewController(self)
            
            if (self.currentPhotoIndex == 0) {
                self.showPhotos()
            }
        }
    }
    
    func dequeueReusablePhotoView() -> PhotoView? {
        if let photoView: AnyObject = self.reusablePhotoViews.anyObject()? {
            self.reusablePhotoViews.removeObject(photoView)
            return photoView as? PhotoView
        }
        else {
            return nil
        }
    }
    
    func showPhotoViewAtIndex(index: Int) {
        var photoView = self.dequeueReusablePhotoView()
        if (photoView == nil) { // 添加新的图片view
            photoView = PhotoView()
            photoView?.photoViewDelegate = self
        }
        
        // 调整当期页的frame
        let bounds = self.photoScrollView!.bounds
        var photoViewFrame = bounds
        photoViewFrame.size.width -= (2 * Singleton.kPadding)
        photoViewFrame.origin.x = (bounds.size.width * CGFloat(index)) + Singleton.kPadding
        photoView?.index = index
        
        let photo = self.photos[index];
        photoView?.frame = photoViewFrame
        photoView?.photo = photo
        
        self.visiblePhotoViews.addObject(photoView!)
        //photoView?.backgroundColor = UIColor.redColor()
        self.photoScrollView?.addSubview(photoView!)
        
        self.loadImageNearIndex(index)
    }
    
    
    func loadImageNearIndex(index: Int) {
        if (index > 0) {
            let photo = self.photos[index - 1];
            SWWebImageManager.downloadWithURL(photo.url)
        }
        if (index < self.photos.count - 1) {
            let photo = self.photos[index + 1];
            SWWebImageManager.downloadWithURL(photo.url)
        }
    }
    
    func showPhotos() {
        if (self.photos.count == 1) {
            self.showPhotoViewAtIndex(0)
            return
        }
        
        let visibleBounds = self.photoScrollView!.bounds;
        var firstIndex: Int = Int((CGRectGetMinX(visibleBounds) + Singleton.kPadding * 2) / CGRectGetWidth(visibleBounds))
        var lastIndex: Int  = Int((CGRectGetMaxX(visibleBounds) - Singleton.kPadding * 2 - 1) / CGRectGetWidth(visibleBounds))
        
        if (firstIndex < 0) {
            firstIndex = 0
        }
        if (firstIndex >= self.photos.count) {
            firstIndex = self.photos.count - 1
        }
        if (lastIndex < 0) {
            lastIndex = 0
        }
        if (lastIndex >= self.photos.count) {
            lastIndex = self.photos.count - 1
        }
        
        // 回收不再显示的ImageView
        var photoViewIndex = 0
        for view in self.visiblePhotoViews {
            if let photoView = view as? PhotoView {
                photoViewIndex = photoView.index
                if (photoViewIndex < firstIndex || photoViewIndex > lastIndex) {
                    self.reusablePhotoViews.addObject(photoView)
                    photoView.removeFromSuperview()
                }
            }
        }
        
        self.visiblePhotoViews.minusSet(self.reusablePhotoViews)
        //[_visiblePhotoViews minusSet:_reusablePhotoViews];
        while (self.reusablePhotoViews.count > 2) {
            self.reusablePhotoViews.removeObject(self.reusablePhotoViews.anyObject()!)
        }
        
        for index in firstIndex...lastIndex {
            if (!self.isShowingPhotoViewAtIndex(index)) {
                self.showPhotoViewAtIndex(index)
            }
        }
    }
    
    func isShowingPhotoViewAtIndex(index: Int) -> Bool {
        for view in self.visiblePhotoViews {
            if let photoView = view as? PhotoView {
                if (photoView.index == index) {
                    return true
                }
            }
        }
        return false
    }
    
    func createScrollView() {
        
        var frame = self.view.bounds
        frame.origin.x -= Singleton.kPadding
        frame.size.width += (2 * Singleton.kPadding)
        
        photoScrollView = UIScrollView(frame: frame)
        photoScrollView?.autoresizingMask = (.FlexibleWidth | .FlexibleHeight)
        photoScrollView?.pagingEnabled = true
        photoScrollView?.delegate = self
        //photoScrollView?.showsHorizontalScrollIndicator = false
        //photoScrollView?.showsVerticalScrollIndicator = false
        photoScrollView?.backgroundColor = UIColor.clearColor()
        photoScrollView?.contentSize = CGSizeMake(frame.size.width * CGFloat(self.photos.count), 0)
        self.view.addSubview(photoScrollView!)
        photoScrollView?.contentOffset = CGPointMake(CGFloat(self.currentPhotoIndex) * frame.size.width, 0)
    }
    
    
    func photoViewImageFinishLoad(photoView: PhotoView) {
        
    }
    
    func photoViewSingleTap(photoView: PhotoView) {
        UIApplication.sharedApplication().statusBarHidden = self.statusBarHiddenInited
        self.view.backgroundColor = UIColor.clearColor()
    }
    
    func photoViewDidEndZoom(photoView: PhotoView) {
        self.view.removeFromSuperview()
        self.removeFromParentViewController()
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        self.showPhotos()
    }
}