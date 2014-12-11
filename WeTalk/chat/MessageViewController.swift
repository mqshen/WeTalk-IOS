//
//  MessageViewController.swift
//  WeTalk
//
//  Created by GoldRatio on 11/29/14.
//  Copyright (c) 2014 GoldRatio. All rights reserved.
//

import Foundation
import UIKit


let IncomingMessage = "IncomingMessage"
let OutgoingMessage = "OutgoingMessage"
let IncomingImageMessage = "IncomingImageMessage"
let OutgoingImageMessage = "OutgoingImageMessage"
let TOOLBAR_HEIGHT: CGFloat = 44
let kMessagesKeyValueObservingContext = UnsafeMutablePointer<Void>.alloc(1)

class MessageViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UICollectionViewDelegateFlowLayout, UIImagePickerControllerDelegate, UINavigationControllerDelegate, MessageInputViewDelegate, MessagesKeyboardControllerDelegate, MessageCellDelegate
{
    struct Static {
        static let timeInterval: Int64 = 2 * 60 * 1000
    }
    var collectionView: UITableView?
    var inputToolbar: MessagesInputToolbar?
    var toolbarBottomLayoutGuide: NSLayoutConstraint?
    var toolbarHeightConstraint: NSLayoutConstraint?
    var keyboardController: MessageKeyboardController?
    var messages = [Message]()
    
    var processInputBar = false
    var mediaView: UIView?
    
    var preTimestamp:Int64 = 0
    
    var user: Chatable?
    
//    var toUser: User? {
//        get {
//            return user
//        }
//        set {
//            user = newValue
//            if let u = user? {
//                PersistenceProcessor.sharedInstance.addFriend(u)
//            }
//        }
//    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //self.navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        
        if let u = user? {
            self.title = u.nick
        }
        //let layout = UICollectionViewFlowLayout()
        let frame = self.view.bounds
        
        let collectionFrame = CGRectMake(frame.origin.x, 0 , frame.size.width, frame.size.height)
        //self.view.backgroundColor = UIColor.redColor()
        
        //self.automaticallyAdjustsScrollViewInsets = false
        self.collectionView = UITableView(frame: collectionFrame)//(frame: collectionFrame, collectionViewLayout: layout)
        
        self.collectionView?.delegate = self
        self.collectionView?.dataSource = self
        self.collectionView?.backgroundColor = UIColorFromRGB(0xE5E5E5)
        //self.collectionView?.backgroundColor = UIColor.redColor()
        self.collectionView?.separatorColor = UIColor.clearColor()
        self.view.addSubview(self.collectionView!)
        
        let left = NSLayoutConstraint(item: self.collectionView!,
            attribute: NSLayoutAttribute.Leading,
            relatedBy: NSLayoutRelation.Equal,
            toItem: self.view,
            attribute: NSLayoutAttribute.Leading,
            multiplier: 1,
            constant: 0)
        self.view.addConstraint(left)
        
        let right = NSLayoutConstraint(item: self.collectionView!,
            attribute: NSLayoutAttribute.Trailing,
            relatedBy: NSLayoutRelation.Equal,
            toItem: self.view,
            attribute: NSLayoutAttribute.Trailing,
            multiplier: 1,
            constant: 0)
        self.view.addConstraint(right)
        
        
        let top = NSLayoutConstraint(item: self.collectionView!,
            attribute: NSLayoutAttribute.Top,
            relatedBy: NSLayoutRelation.Equal,
            toItem: self.view,
            attribute: NSLayoutAttribute.Top,
            multiplier: 1,
            constant: 0)
        self.view.addConstraint(top)
        
        
        let bottom = NSLayoutConstraint(item: self.collectionView!,
            attribute: NSLayoutAttribute.Bottom,
            relatedBy: NSLayoutRelation.Equal,
            toItem: self.view,
            attribute: NSLayoutAttribute.Bottom,
            multiplier: 1,
            constant: 0)
        self.view.addConstraint(bottom)
        
        
        self.collectionView?.setTranslatesAutoresizingMaskIntoConstraints(false)
        
        
        
        let height = frame.size.height - TOOLBAR_HEIGHT
        self.inputToolbar = MessagesInputToolbar(frame: CGRectMake(0, height, frame.size.width, TOOLBAR_HEIGHT))
        self.inputToolbar?.delegate = self
        self.view.addSubview(self.inputToolbar!)
        
        
        self.toolbarBottomLayoutGuide = NSLayoutConstraint(item: self.view,
            attribute: NSLayoutAttribute.Bottom,
            relatedBy: NSLayoutRelation.Equal,
            toItem: self.inputToolbar,
            attribute: NSLayoutAttribute.Bottom,
            multiplier: 1,
            constant: 0)
        
        self.view.addConstraint(self.toolbarBottomLayoutGuide!)
        
        
        let panGestureRecognizer = self.collectionView!.panGestureRecognizer
        let contentView = self.inputToolbar!.contentView
        self.keyboardController = MessageKeyboardController(textView: contentView,
            contextView: self.view,
            panGestureRecognizer: panGestureRecognizer,
            delegate: self)
        
        
        let toolbarLeft = NSLayoutConstraint(item: self.inputToolbar!,
            attribute: NSLayoutAttribute.Leading,
            relatedBy: NSLayoutRelation.Equal,
            toItem: self.view,
            attribute: NSLayoutAttribute.Leading,
            multiplier: 1,
            constant: 0)
        self.view.addConstraint(toolbarLeft)
        
        
        let toolbarRight = NSLayoutConstraint(item: self.inputToolbar!,
            attribute: NSLayoutAttribute.Trailing,
            relatedBy: NSLayoutRelation.Equal,
            toItem: self.view,
            attribute: NSLayoutAttribute.Trailing,
            multiplier: 1,
            constant: 0)
        self.view.addConstraint(toolbarRight)
        
        self.toolbarHeightConstraint = NSLayoutConstraint(item: self.inputToolbar!,
            attribute: NSLayoutAttribute.Height,
            relatedBy: NSLayoutRelation.Equal,
            toItem: nil,
            attribute: NSLayoutAttribute.NotAnAttribute,
            multiplier: 1,
            constant: TOOLBAR_HEIGHT)
        
        self.inputToolbar?.addConstraint(self.toolbarHeightConstraint!)
        
        self.setToolbarBottomLayoutGuideConstant(0)
        self.scrollToBottomAnimated(false)
        
        
        self.getHistory()
        //PersistenceProcessor.sharedInstance.readAllMessage(self.toUser!.cliendId)
    }
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
        
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        var height:CGFloat = 20
        let message = self.messages[indexPath.row]
        
        
        if(message.messageType == .Image) {
            if let image = message.image? {
                return height + image.size.height
            }
            else {
                return height
            }
        }
        else {
            let attributes = [NSFontAttributeName: UIFont.systemFontOfSize(14)]
            let maximumSize = CGSizeMake(220, CGFloat.max)
            
            // Need to cast stringValue to an NSString in order to call boundingRectWithSize(_:options:attributes:).
            let boundingSize = message.content.boundingRectWithSize(maximumSize,
                options: NSStringDrawingOptions.UsesLineFragmentOrigin,
                attributes: attributes,
                context: nil)
            
            return height + boundingSize.size.height + 1
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let session = Session.sharedInstance
        let message = self.messages[indexPath.row]
        let clientId = message.from
        var cellIdentify = IncomingMessage
        
        
        if(message.status == .Send ) {
            if(message.messageType == .Image) {
                cellIdentify = OutgoingImageMessage
            }
            else {
                cellIdentify = OutgoingMessage
            }
        }
        else {
            if(message.messageType == .Image) {
                cellIdentify = IncomingImageMessage
            }
            else {
                cellIdentify = IncomingMessage
            }
        }
        
        var cell: MessageCell? = tableView.dequeueReusableCellWithIdentifier( cellIdentify ) as? MessageCell
        if (cell == nil) {
            if(cellIdentify == OutgoingImageMessage) {
                cell = OutgoingImageMessageCell(style: UITableViewCellStyle.Default, reuseIdentifier: OutgoingImageMessage)
            }
            else if(cellIdentify == IncomingImageMessage){
                cell = IncomingImageMessageCell(style: UITableViewCellStyle.Default, reuseIdentifier: IncomingImageMessage)
            }
            else if(cellIdentify == OutgoingMessage) {
                cell = OutgoingMessageCell(style: UITableViewCellStyle.Default, reuseIdentifier: OutgoingMessage)
            }
            else {
                cell = IncomingMessageCell(style: UITableViewCellStyle.Default, reuseIdentifier: IncomingMessage)
            }
            cell?.selectionStyle = UITableViewCellSelectionStyle.None
        }
        
        cell?.delegate = self
        cell!.message = self.messages[indexPath.row]
        return cell!
    }
    
    override func viewWillAppear(animated: Bool) {
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.keyboardController?.beginListeningForKeyboard()
        self.addContentSizeObserver()
    }
    
    override func viewWillDisappear(animated: Bool) {
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        self.removeContentSizeObserver()
        self.keyboardController?.endListeningForKeyboard()
    }
    
    
    //layout
    
    func addContentSizeObserver() {
        //self.removeContentSizeObserver()
        self.inputToolbar?.contentView.addObserver(self,
            forKeyPath: "contentSize",
            options: NSKeyValueObservingOptions.Old | NSKeyValueObservingOptions.New,
            context: kMessagesKeyValueObservingContext)
    }
    
    func removeContentSizeObserver() {
        self.inputToolbar?.contentView.removeObserver(self, forKeyPath: "contentSize", context: kMessagesKeyValueObservingContext)
    }
    
    override func observeValueForKeyPath(keyPath: String, ofObject object: AnyObject, change: [NSObject : AnyObject], context: UnsafeMutablePointer<Void>) {
        if context == kMessagesKeyValueObservingContext {
            if object as? MessagesComposerTextView == self.inputToolbar?.contentView && keyPath == "contentSize" {
                let oldContentSize = change[NSKeyValueChangeOldKey]?.CGSizeValue()
                let newContentSize = change[NSKeyValueChangeNewKey]?.CGSizeValue()
                let dy = newContentSize!.height - oldContentSize!.height
                self.adjustInputToolbarForComposerTextViewContentSizeChange(dy)
                self.updateCollectionViewInsets()
                self.scrollToBottomAnimated(false)
            }
        }
    }
    
    func updateCollectionViewInsets() {
        let collectionViewFrame = self.collectionView!.frame
        let frame = self.inputToolbar!.frame
        let height = CGRectGetMinY(frame)
        self.setCollectionViewInsets(0, bottom: CGRectGetHeight(collectionViewFrame) - height)
    }
    
    func scrollToBottomAnimated(animated: Bool) {
        if self.collectionView!.numberOfSections() == 0 {
            return
        }
        let size = self.collectionView!.numberOfRowsInSection(0)
        if size > 0 {
            let contentSize = self.collectionView!.contentSize
            let insetSize = self.collectionView!.contentInset
            let frame = self.collectionView?.frame
            let fr = CGRectMake(0, contentSize.height - 10 , 320, 10)
            self.collectionView?.scrollRectToVisible(fr, animated: animated)
            //            self.collectionView?.scrollToItemAtIndexPath(NSIndexPath(forItem: size - 1, inSection: 0),
            //                atScrollPosition: UICollectionViewScrollPosition.Top,
            //                animated: animated)
        }
    }
    
    func setCollectionViewInsets(top: CGFloat, bottom: CGFloat) {
        let insets = UIEdgeInsetsMake(top, 0.0, bottom, 0.0)
        self.collectionView!.contentInset = insets
        self.collectionView!.scrollIndicatorInsets = insets
    }
    
    func adjustInputToolbarForComposerTextViewContentSizeChange(dy: CGFloat) {
        var contentSizeIsIncreasing = dy > 0
        if self.inputToolbarHasReachedMaximumHeight() {
            let contentOffsetIsPositive = self.inputToolbar!.contentView.contentOffset.y > 0
            if contentSizeIsIncreasing || contentOffsetIsPositive {
                self.scrollComposerTextViewToBottomAnimated(true)
                return
            }
        }
        let toolbarOriginY = CGRectGetMinY(self.inputToolbar!.frame)
        let newToolbarOriginY = toolbarOriginY - dy
        
        var interval = dy
        //  attempted to increase origin.Y above topLayoutGuide
        if (newToolbarOriginY <= self.topLayoutGuide.length) {
            interval = toolbarOriginY - self.topLayoutGuide.length
            self.scrollComposerTextViewToBottomAnimated(true)
        }
        
        self.adjustInputToolbarHeightConstraintByDelta(interval)
        
        self.updateKeyboardTriggerPoint()
        
        if (interval < 0) {
            self.scrollComposerTextViewToBottomAnimated(false)
        }
        
    }
    
    func updateKeyboardTriggerPoint() {
        
    }
    
    func inputToolbarHasReachedMaximumHeight() -> Bool {
        return CGRectGetMinY(self.inputToolbar!.frame) == self.topLayoutGuide.length
    }
    
    func adjustInputToolbarHeightConstraintByDelta(dy: CGFloat) {
        self.toolbarHeightConstraint!.constant += dy
        if (self.toolbarHeightConstraint!.constant < TOOLBAR_HEIGHT) {
            self.toolbarHeightConstraint!.constant = TOOLBAR_HEIGHT
        }
        
        self.view.setNeedsUpdateConstraints()
        self.view.layoutIfNeeded()
    }
    
    func scrollComposerTextViewToBottomAnimated(animated: Bool) {
        let textView = self.inputToolbar!.contentView
        let contentOffsetToShowLastLine = CGPointMake(0.0, textView.contentSize.height - CGRectGetHeight(textView.bounds))
        if (!animated) {
            textView.contentOffset = contentOffsetToShowLastLine
            return
        }
        
        UIView.animateWithDuration(0.01,
            delay: 0.01,
            options: UIViewAnimationOptions.CurveLinear,
            animations: { () -> Void in
                textView.contentOffset = contentOffsetToShowLastLine
            },
            completion: nil)
    }
    
    //keyboard
    func keyboardDidChangeFrame(keyboardFrame: CGRect){
        if (processInputBar) {
            return
        }
        let collectFrame = self.collectionView!.frame
        let heightFromBottom = CGRectGetHeight(collectFrame) - CGRectGetMinY(keyboardFrame)
        
        self.setToolbarBottomLayoutGuideConstant(heightFromBottom)
        self.scrollToBottomAnimated(false)
    }
    
    func setToolbarBottomLayoutGuideConstant(constant: CGFloat) {
        self.toolbarBottomLayoutGuide!.constant = constant
        self.view.setNeedsUpdateConstraints()
        self.view.layoutIfNeeded()
        self.updateCollectionViewInsets()
    }
    
    
    //message
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            let content:String = textView.text
            if countElements(content) == 0 {
                return false
            }
            let session = Session.sharedInstance
            let now = NSDate()
            
            
            let message = Message(seqNo: Session.sharedInstance.messageId,
                from: session.user!.id,
                to: user!.id,
                content: content,
                attach: nil,
                timestamp: Int64(now.timeIntervalSince1970 * 1000),
                status: .Send)
//            
//            let message = Message(fromUserName: session.user!.name,
//                toUserName: user!.name,
//                type: 0,
//                content: content,
//                clientMsgId: Int64(10),
//                createTime: )
            
            session.sendMessage(message)
            
            PersistenceProcessor.sharedInstance.sendMessage(message)
            
            self.messages.append(message)
            textView.text = ""
            self.finishSendingOrReceivingMessage()
            return false
        }
        return true
    }
    
    
    func addTimestamp(message: Message) {
        
    }
    
   
    
    func receiveMessage(message: Message) {
        self.messages.append(message)
        self.finishSendingOrReceivingMessage()
    }
    
    func didSelectedMultipleMediaAction(change: Bool) {
        self.processInputBar = true
        self.genMediaView()
        
        self.inputToolbar?.contentView.resignFirstResponder()
        
        self.setToolbarBottomLayoutGuideConstant(self.mediaView!.frame.size.height)
        
        self.mediaView?.frame = CGRectMake(0.0,
            CGRectGetHeight(self.view.frame) - CGRectGetHeight(self.mediaView!.frame),
            CGRectGetWidth(self.view.frame),
            CGRectGetHeight(self.mediaView!.frame))
    }
    
    
    func genMediaView() {
        if(self.mediaView == nil) {
            self.mediaView = UIView(frame: CGRectMake(0, 110, 320, 220))
            self.mediaView?.backgroundColor = UIColor.whiteColor()
            let bottomBorder = CALayer()
            bottomBorder.frame = CGRectMake(0, 0, 320, 1)
            //bottomBorder.backgroundColor = UIColor.grayColor.CGColor
            self.mediaView?.layer.addSublayer(bottomBorder)
            
            let photoButton = UIButton(frame: CGRectMake(26, 30, 50, 50))
            photoButton.setImage(UIImage(named: "photo.png"), forState: UIControlState.Normal)
            photoButton.addTarget(self, action: "showPhoto", forControlEvents: UIControlEvents.TouchUpInside)
            self.mediaView?.addSubview(photoButton)
            
            let cameraButton = UIButton(frame: CGRectMake(98, 30, 50, 50))
            cameraButton.setImage(UIImage(named: "camera.png"), forState: UIControlState.Normal)
            cameraButton.addTarget(self, action: "showCamera", forControlEvents: UIControlEvents.TouchUpInside)
            self.mediaView?.addSubview(cameraButton)
        }
        self.view.addSubview(self.mediaView!)
    }
    
    
    func showPhoto() {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.allowsEditing = false
        imagePickerController.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
        self.presentViewController(imagePickerController, animated: true, completion: nil)
    }
    
    func showCamera() {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.allowsEditing = false
        imagePickerController.sourceType = UIImagePickerControllerSourceType.Camera
        self.presentViewController(imagePickerController, animated: true, completion: nil)
    }
    
    func textViewDidBeginEditing(textView: UITextView) {
        processInputBar = false
        textView.becomeFirstResponder()
        self.scrollToBottomAnimated(true)
    }
    
    func finishSendingOrReceivingMessage(_ animation: Bool = true) {
        dispatch_async(dispatch_get_main_queue(), {
            self.collectionView?.reloadData()
            self.scrollToBottomAnimated(animation)
        })
        
        //        self.collectionView?.performBatchUpdates({ () -> Void in
        //        }, completion: { (Bool) -> Void in
        //            self.scrollToBottomAnimated(true)
        //        })
    }
    
    func didSelectedVoice(change: Bool) {
        
    }
    
    func getHistory() {
        let session = Session.sharedInstance
        
        let messages = PersistenceProcessor.sharedInstance.getRecentMessages(self.user!.id, page: 0)
        
        for message in messages {
            self.messages.append(message)
        }
        
        self.finishSendingOrReceivingMessage(false)
    }
    
    func messageSent(messageId: String!) {
        
    }
    
    func imagePickerController(picker: UIImagePickerController!, didFinishPickingImage image: UIImage!, editingInfo: [NSObject : AnyObject]!) {
        
        picker.dismissViewControllerAnimated(true, completion: nil)
        
        let imageData = UIImageJPEGRepresentation(image, 0)
        
        let session = Session.sharedInstance
        
        let now = NSDate()
        
        let perfix = session.user!.id
        
        let fileName = "\(perfix)-\(now.timeIntervalSince1970).png"
        
        let thumbImage = image.thumbnailWithImageWithoutScale(CGSizeMake(90, 120))
        //let thumbImageData = UIImageJPEGRepresentation(thumbImage, 1.0);
        let encodedString = thumbImage.base64String()
        
        let message = Message(seqNo: Session.sharedInstance.messageId,
            from: session.user!.id,
            to: user!.id,
            content: fileName,
            attach: encodedString,
            timestamp: Int64(now.timeIntervalSince1970 * 1000),
            messageType: .Image,
            status: .Send)
        
        PersistenceProcessor.sharedInstance.sendMessage(message)
        
        self.messages.append(message)
        self.finishSendingOrReceivingMessage()
        
        func completeHandler(AnyObject?, NSError?) -> Void {
            session.sendMessage(message)
        }
        
        let cellPath = NSIndexPath(forItem: (self.messages.count - 1), inSection: 0)
        
        func progressHandler(progress: Int64, total: Int64) -> Void {
            println("cell index:\(cellPath.row) progress: \(progress) total: \(total)")
            let text = self.collectionView!.cellForRowAtIndexPath(cellPath)
            if let cell = text as? MessageCell {
                dispatch_async(dispatch_get_main_queue(), {
                    cell.setProgress(Double(progress) / Double(total))
                })
            }
        }
        
        QNUploadManager.postData(imageData, fileName: fileName, completeHandler: completeHandler, progressHandler:progressHandler)
    }
    
    func calculateNeedDisplay() {
        
    }
    
    //    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    //        let messageData = self.messages[indexPath.row]
    //        let messageId = messageData.msgId
    //        let user = messageData.customData
    //        if (messageData.type.value == AnIMBinaryMessage.value) {
    //            var images = [UIImage]()
    //            var index:UInt = 0
    //            for message in messages {
    //                if (message.type.value == AnIMBinaryMessage.value) {
    //                    if (message.msgId == messageId) {
    //                        index = UInt(images.count)
    //                    }
    //                    if let image = UIImage(data: message.content)? {
    //                        images.append(image)
    //                    }
    //                }
    //            }
    //
    //            let viewController = YJImageViewController(imagePaths: images, initialImageIndex: index, imageData: true)
    //            self.navigationController?.pushViewController(viewController, animated: true)
    //        }
    //    }
    
    
    func containerRow(rows: [AnyObject], index: Int) -> Bool {
        if(rows.count > 0) {
            let first = rows[0] as NSIndexPath
            let second = rows.last as NSIndexPath
            if (first.row <= index && second.row >= index ) {
                return true
            }
        }
        return false
    }
    
    func didSelectContent(cell: MessageCell) {
        if let indexPath = self.collectionView!.indexPathForCell(cell)? {
            let messageData = self.messages[indexPath.row]
            if (messageData.messageType == .Image) {
                
                var images = [Photo]()
    
                var index:Int = 0
                
                for (i, message) in enumerate(messages) {
                    if message.messageType == .Image {
                        if (indexPath.row == i) {
                            index = images.count
                        }
                        if let image = message.image? {
                            let url = "http://mqshen.qiniudn.com/\(message.content)"
                            let cellPath = NSIndexPath(forItem: i, inSection: 0)
                            if let cell = self.collectionView!.cellForRowAtIndexPath(cellPath) as? MessageCell {
                                let photo = Photo(content: url, image: nil, srcImageView: cell.messageImageView, placeholder: image, capture: image)
                                images.append(photo)
                                photo.firstShow = i == indexPath.row
                            }
                            else {
                                let photo = Photo(content: url, image: nil, srcImageView: nil, placeholder: image, capture: image)
                                images.append(photo)
                                photo.firstShow = i == indexPath.row
                            }
                        }
                    }
                }
                
                let browser = PhotoBrowser()
                browser.currentPhotoIndex = index
                browser.photos = images
                browser.show()
            }
        }
    }
    
    func didSelectAvatar(cell: MessageCell) {
        
    }
    
    func hideInput() {
        self.inputToolbar?.contentView.resignFirstResponder()
        self.setToolbarBottomLayoutGuideConstant(0)
        self.mediaView?.removeFromSuperview()
    }
    //    func receiveMessage(message: AnIMMessage) {
    //        print("receive")
    //    }
}