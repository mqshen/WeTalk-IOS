//
//  PhotoView.swift
//  WeTalk
//
//  Created by GoldRatio on 12/9/14.
//  Copyright (c) 2014 GoldRatio. All rights reserved.
//

import Foundation
import UIKit
import SWWebImage

protocol PhotoViewDelegate
{
    func photoViewImageFinishLoad(photoView: PhotoView)
    func photoViewSingleTap(photoView: PhotoView)
    func photoViewDidEndZoom(photoView: PhotoView)
}

class PhotoView : UIScrollView, UIScrollViewDelegate {
    let imageView = SWWebImageView()
    
    var photoViewDelegate: PhotoViewDelegate?
    var index: Int = 0
    private var _photo: Photo?
    
    var photo: Photo? {
        get {
            return _photo
        }
        set {
            _photo = newValue
            self.showImage()
        }
    }

    var doubleTap: Bool = false

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.clipsToBounds = true
        // 图片
        self.imageView.contentMode = .ScaleAspectFit
        self.addSubview(imageView)
        
        // 进度条
        //_photoLoadingView = [[MJPhotoLoadingView alloc] init];
        
        // 属性
        self.backgroundColor = UIColor.clearColor()
        self.delegate = self
        self.showsHorizontalScrollIndicator = false
        self.showsVerticalScrollIndicator = false
        self.decelerationRate = UIScrollViewDecelerationRateFast;
        self.autoresizingMask = (.FlexibleWidth | .FlexibleHeight)
        
        // 监听点击
        let singleTap = UITapGestureRecognizer(target: self, action: "handleSingleTap:")
        singleTap.delaysTouchesBegan = true
        singleTap.numberOfTapsRequired = 1
        self.addGestureRecognizer(singleTap)
        
        let doubleTap = UITapGestureRecognizer(target: self, action: "handleDoubleTap:")
        doubleTap.numberOfTapsRequired = 2;
        self.addGestureRecognizer(doubleTap)
    }
    
    override init() {
        super.init()
    }
    
    func handleSingleTap(tap: UITapGestureRecognizer) {
        self.doubleTap = false
        var time = dispatch_time(DISPATCH_TIME_NOW, Int64(0.2))
        dispatch_after(time, dispatch_get_main_queue()) { () -> Void in
            self.hide() // call your method.
        }
    }
    
    func handleDoubleTap(tap: UITapGestureRecognizer) {
        self.doubleTap = true
        
        let touchPoint = tap.locationInView(self)
        if (self.zoomScale == self.maximumZoomScale) {
            self.setZoomScale(self.minimumZoomScale, animated: true)
        }
        else {
            self.zoomToRect(CGRectMake(touchPoint.x, touchPoint.y, 1, 1), animated:true)
        }
    }
    
    func hide() {
        
        UIView.animateWithDuration(0.25, animations: { () -> Void in
            
            if let srcImageView = self.photo!.srcImageView? {
                self.imageView.frame = srcImageView.convertRect(srcImageView.bounds, toView:nil)
            }
            else {
                self.imageView.frame = CGRectZero
            }
            
            if let photoViewDelegate = self.photoViewDelegate? {
                photoViewDelegate.photoViewSingleTap(self)
            }
            }) { (Bool) -> Void in
                self.photo?.srcImageView?.image = self.photo!.placeholder;
                
                if let photoViewDelegate = self.photoViewDelegate? {
                    photoViewDelegate.photoViewDidEndZoom(self)
                }
        }
    }
    
    func showImage() {
        if (self.photo!.firstShow) { // 首次显示
            self.imageView.image = self.photo!.placeholder; // 占位图片
            self.photo!.srcImageView?.image = nil;
            
            // 不是gif，就马上开始下载
            let photo = self.photo!
            
            imageView.setImage(self.photo!.url,
                placeholderImage: self.photo!.placeholder,
                options: SWWebImageOptions.LowPriority,
                progress: nil,
                completeHandler: { (image: UIImage?, error: NSError?, cacheType: SWImageCacheType) -> Void in
                photo.image = image!
            })
           
        }
        else {
            self.photoStartLoad()
        }
    
        
        self.adjustFrame()
    }
    
    func photoStartLoad() {
        if (self.photo!.image != nil) {
            self.scrollEnabled = true
            self.imageView.image = self.photo!.image
        }
        else {
            self.scrollEnabled = false
            // 直接显示进度条
            //[_photoLoadingView showLoading];
            //[self addSubview:_photoLoadingView];
            
            let photo = self.photo!
            imageView.setImage(self.photo!.url,
                placeholderImage: self.photo!.placeholder,
                options: SWWebImageOptions.LowPriority,
                progress: nil,
                completeHandler: { (image: UIImage?, error: NSError?, cacheType: SWImageCacheType) -> Void in
                    photo.image = image!
            })
        }
    }
    
    func adjustFrame() {
        if (self.imageView.image == nil) {
            return
        }
        
        // 基本尺寸参数
        let boundsSize = self.bounds.size
        let boundsWidth = boundsSize.width
        let boundsHeight = boundsSize.height
        
        let imageSize = self.imageView.image!.size
        let imageWidth = imageSize.width
        let imageHeight = imageSize.height
        
        // 设置伸缩比例
        var minScale = boundsWidth / imageWidth;
        if (minScale > 1) {
            minScale = 1.0;
        }
        var maxScale: CGFloat = 2.0;
//        if ([UIScreen instancesRespondToSelector:@selector(scale)]) {
//            maxScale = maxScale / [[UIScreen mainScreen] scale];
//        }
        self.maximumZoomScale = maxScale;
        self.minimumZoomScale = minScale;
        self.zoomScale = minScale;
        
        var imageFrame = CGRectMake(0, 0, boundsWidth, imageHeight * boundsWidth / imageWidth);
        // 内容尺寸
        self.contentSize = CGSizeMake(0, imageFrame.size.height);
        
        // y值
        if (imageFrame.size.height < boundsHeight) {
            imageFrame.origin.y = (boundsHeight - imageFrame.size.height) / 2.0
        }
        else {
            imageFrame.origin.y = 0;
        }
        
        if (self.photo!.firstShow) { // 第一次显示的图片
            self.photo!.firstShow = false
            if let srcImageView = self.photo!.srcImageView? {
                
                self.imageView.frame = srcImageView.convertRect(srcImageView.bounds, toView:nil)
                
                UIView.animateWithDuration(0.3, animations: { () -> Void in
                    self.imageView.frame = imageFrame
                    }) { (Bool) -> Void in
                        srcImageView.image = self.photo!.placeholder
                        self.photoStartLoad()
                }
            }
        }
        else {
            self.imageView.frame = imageFrame
        }
    }
}