//
//  ImagePickerCell.swift
//  Ge.PartsAssist
//
//  Created by Matt Retzer on 5/24/15.
//  Copyright (c) 2015 GEHC. All rights reserved.
//

import Foundation
import MobileCoreServices
import UIKit

public class ImageSelectorCell : XLFormBaseCell, UIActionSheetDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate{
    
    
    let kFormImageSelectorCellDefaultImage:String = "defaultImage"
    let kFormImageSelectorCellImageRequest:String = "imageRequest"
    
    var _imageView:UIImageView = UIImageView()
    var _textLabel:UILabel = UILabel()
    
    var _defaultImage:UIImage?
    var _imageRequest:NSURLRequest?
    
    
    var _imageHeight:CGFloat = 100.0
    var _imageWidth:CGFloat = 100.0
    

    public required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    
    public override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
      
        
        
    }
    
    override public func configure() {
        super.configure()
        
        self._imageView.layer.masksToBounds = true
        self._imageView.contentMode = UIViewContentMode.ScaleAspectFit
    
        
        self.selectionStyle = UITableViewCellSelectionStyle.None
        self.backgroundColor = UIColor.clearColor()
        self.separatorInset = UIEdgeInsetsZero
        self.contentView.addSubview(self._imageView)
        self.contentView.addSubview(self._textLabel)
        self.layoutContraints();

        self.textLabel?.addObserver(self, forKeyPath: "text", options: NSKeyValueObservingOptions.Old|NSKeyValueObservingOptions.New, context: nil)
        
    }
    

    
    
    override public func update() {
        self.textLabel?.text = self.rowDescriptor.title
        if (self.rowDescriptor.value != nil){
            self.imageView!.image = self.rowDescriptor.value as? UIImage
        }else{
            self.imageView!.image = self._defaultImage
        }
        
        if (self._imageRequest != nil && self.rowDescriptor.value == nil){
         var cell = self.imageView
            
            var weakSelf = self;
            
            self.imageView?.setImageWithURLRequest(self._imageRequest, placeholderImage: self._defaultImage, success:{ [weak cell] (request:NSURLRequest!,response:NSHTTPURLResponse!, image:UIImage!) -> Void in
                    if (weakSelf.rowDescriptor.value == nil && image != nil){
                        weakSelf.imageView!.image = image
                    }
                
                }, failure: { [weak cell]
                    (request:NSURLRequest!,response:NSHTTPURLResponse!, error:NSError!) -> Void in
                    
                })
        }
        
        
    }
    
    
    
    
    public override static func formDescriptorCellHeightForRowDescriptor(rowDescriptor: XLFormRowDescriptor!) -> CGFloat {
        return 120.0
    }
    
    
    public override func formDescriptorCellDidSelectedWithFormController(controller: XLFormViewController!) {
        var actionSheet = UIActionSheet(title: self.rowDescriptor.selectorTitle, delegate: self, cancelButtonTitle: "Cancel", destructiveButtonTitle: nil, otherButtonTitles: "Choose Photo","Take Picture")
        actionSheet.tag = self.tag
        actionSheet.showInView(self.formViewController().view)
        
    }
    
    
    
    public func layoutContraints(){

        self._imageView.setTranslatesAutoresizingMaskIntoConstraints(false)
        self._textLabel.setTranslatesAutoresizingMaskIntoConstraints(false)
    

        var viewsDict = Dictionary <String, UIView>()
        viewsDict["image"] = self._imageView
        viewsDict["text"] = self._textLabel
        
        var metrics =   ["margin":5.0]
        
        self.contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-(margin)-[text]", options: nil, metrics: metrics, views: viewsDict))
        
        self.contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-(margin)-[text]", options: nil, metrics: metrics, views: viewsDict))
        
        
        self.contentView.addConstraint(NSLayoutConstraint(item: self.imageView!, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: self.contentView, attribute: NSLayoutAttribute.Top, multiplier: 1.0, constant: 10.0))
        
        self.contentView.addConstraint(NSLayoutConstraint(item: self.imageView!, attribute: NSLayoutAttribute.Bottom , relatedBy: NSLayoutRelation.Equal, toItem: self.contentView, attribute: NSLayoutAttribute.Bottom, multiplier: 1.0, constant: -10.0))
                
        self.contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:[image(width)]", options: nil, metrics: ["width" : _imageWidth], views: viewsDict))
        
        
        self.contentView.addConstraint(NSLayoutConstraint(item: self.imageView!, attribute: NSLayoutAttribute.CenterX, relatedBy: NSLayoutRelation.Equal, toItem: self.contentView, attribute: NSLayoutAttribute.CenterX, multiplier: 1.0, constant: 0.0))
        
        
    }
    
  
    
    override public func updateConstraints() {
        super.updateConstraints()
    }
    

    
    override public func observeValueForKeyPath(keyPath: String, ofObject object: AnyObject, change: [NSObject : AnyObject], context: UnsafeMutablePointer<Void>) {
        if (object as! NSObject == self.textLabel! && keyPath == "text"){
            //if (change[NSKeyValueChangeKindKey] == NSKeyValueChangeSetting){
                self.contentView.needsUpdateConstraints()
            //}
        }
    }
    

    

     public func actionSheet(actionSheet: UIActionSheet, clickedButtonAtIndex buttonIndex: Int) {
        var imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self;
        imagePickerController.allowsEditing = true;
        
        if (buttonIndex == 1){
            imagePickerController.sourceType = UIImagePickerControllerSourceType.PhotoLibrary;
            
            imagePickerController.mediaTypes = [kUTTypeImage];
            self.formViewController().presentViewController(imagePickerController, animated: true, completion: nil)
            
        }else if (buttonIndex == 2){
            imagePickerController.sourceType = UIImagePickerControllerSourceType.Camera;
            imagePickerController.mediaTypes = [kUTTypeImage];
            self.formViewController().presentViewController(imagePickerController, animated: true, completion: nil)
        }
    }
    


    public func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]) {
        
        var mediaType = info[UIImagePickerControllerMediaType] as! String
        var originalImage:UIImage
        var editedImage:UIImage?
        var imageToUse:UIImage
        
        
        editedImage = info[UIImagePickerControllerEditedImage] as? UIImage
        originalImage = info[UIImagePickerControllerOriginalImage] as! UIImage
        
        if (editedImage != nil){
            imageToUse = editedImage!
        }else{
            imageToUse = originalImage
        }
        
        self.rowDescriptor.value = imageToUse
        self._imageView.image = imageToUse
        
        self.formViewController().dismissViewControllerAnimated(true, completion: nil)
    }
    
   
    
    

    
}