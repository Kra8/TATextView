//
//  TATextView.swift
//
//  Created by Koki Asai on 2016/04/05.
//  Copyright © 2016年 teA.AsaiKoki. All rights reserved.
//


import UIKit
public class TATextView: UITextView {
    
    //MARK: - 定数
    private let kMinimumDefault:CGFloat     = 46.0
    private let kMarginDefault:CGFloat      = 8.0
    private let kMaximumDefault:CGFloat     = 128.0
    private let kShadowHeight:CGFloat       = 0.5
    
    //MARK: - property
    //MARK: public
    
    //MARK: private
    private let screenSize:CGSize   = UIScreen.mainScreen().bounds.size
    
    private let toolbar     = UIView()
    private let returnBtn   = UIButton(type: .Custom)
    private let textView    = UITextView()

    //MARK: - init
    override init(frame: CGRect, textContainer: NSTextContainer?) {
        //*
        //init property
        
        //call super init
        super.init(frame: frame, textContainer: textContainer)
        
        //setting property
        
        // toolbar setting
        self.toolbar.frame              = CGRect(x: 0.0, y: self.screenSize.height + kShadowHeight, width: self.screenSize.width, height: kMinimumDefault)
        self.toolbar.layer.borderWidth  = 0.8
        self.toolbar.layer.borderColor  = UIColor(white: 0.89, alpha: 1.0).CGColor
        self.toolbar.backgroundColor    = UIColor.whiteColor()
        
        // returnBtn setting
        let returnBtnW:CGFloat      = (self.screenSize.width / 6.0) - kMarginDefault
        let returnBtnH:CGFloat      = kMinimumDefault - (kMarginDefault * 2.0)
        let returnBtnX:CGFloat      = self.toolbar.frame.width - (returnBtnW + kMarginDefault)
        let returnBtnY:CGFloat      = self.toolbar.frame.height - (returnBtnH + kMarginDefault)
        self.returnBtn.frame        = CGRect(x: returnBtnX, y: returnBtnY, width: returnBtnW, height: returnBtnH)
        self.returnBtn.layer.cornerRadius   = 4.0
        self.returnBtn.backgroundColor      = UIColor.blueColor()
        self.returnBtn.setTitle("完了", forState: .Normal)
        self.returnBtn.addTarget(self, action: #selector(TATextView.handleReturnButtonTapped(_:)), forControlEvents: .TouchDown)
        self.returnBtn.frame.origin = self.opposite(self.returnBtn, superview: self.toolbar, point: CGPoint(x: kMarginDefault, y: kMarginDefault))
        self.toolbar.addSubview(self.returnBtn)
        
        // textView setting
        let textViewW:CGFloat               = self.screenSize.width - (returnBtnW + (kMarginDefault * 3.0))
        let textViewH:CGFloat               = returnBtnH
        self.textView.frame                 = CGRect(x: kMarginDefault, y: kMarginDefault, width: textViewW, height: textViewH)
        self.textView.backgroundColor       = UIColor(white: 0.98, alpha: 1.0)
        self.textView.layer.cornerRadius    = 8.0
        self.textView.clipsToBounds         = true
        self.textView.delegate              = self
        self.toolbar.addSubview(self.textView)
        
        // notification of keyboard register
        let notificationCenter = NSNotificationCenter.defaultCenter()
        notificationCenter.addObserver(self, selector: #selector(TATextView.handleKeyboardWillShowNotification(_:)), name: UIKeyboardWillShowNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(TATextView.handleKeyboardWillHideNotification(_:)), name: UIKeyboardWillHideNotification, object: nil)
        
        // self property setting
        self.editable   = false
        let gesture     = UITapGestureRecognizer(target: self, action: #selector(TATextView.handleTapped(_:)))
        self.addGestureRecognizer(gesture)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - handler
    internal func handleKeyboardWillShowNotification(notification:NSNotification){
        if let userInfo = notification.userInfo{
            
            let duration        = userInfo[UIKeyboardAnimationDurationUserInfoKey] as? NSTimeInterval
            let rect            = (userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.CGRectValue()
            let animationCurve  = userInfo[UIKeyboardAnimationCurveUserInfoKey] as? UInt
            let options         = UIViewAnimationOptions(rawValue: (animationCurve! << 16))
            
            if rect == nil || duration == nil || animationCurve == nil { return }
            // animation start
            self.toolbarShowAnimation(rect!, duration: duration!, options: options)
        }

    }
    
    internal func handleKeyboardWillHideNotification(notification:NSNotification){
        if let userInfo = notification.userInfo{
            
            let duration        = userInfo[UIKeyboardAnimationDurationUserInfoKey] as? NSTimeInterval
            let rect            = (userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.CGRectValue()
            let animationCurve  = userInfo[UIKeyboardAnimationCurveUserInfoKey] as? UInt
            let options         = UIViewAnimationOptions(rawValue: (animationCurve! << 16))
            
            if rect == nil || duration == nil || animationCurve == nil { return }
            
            // animation start
            self.toolbarHideAnimation(duration!, options: options)
        }
    }
    
    internal func handleReturnButtonTapped(sender:UIButton){
        // close keyboard
        self.textView.resignFirstResponder()
        self.resignFirstResponder()
    }
    
    internal func handleTapped(sender:UIGestureRecognizer){
        // move the Caret to toolbar on textView
        self.textView.becomeFirstResponder()
    }

    //MARK: - public method
    public override func drawRect(rect: CGRect) {
        // set toolbar
        self.rootview(self).addSubview(self.toolbar)
    }
    
    
    //MARK: - private method
    private func opposite(view: UIView, superview:UIView, point:CGPoint)->CGPoint{
        let newX:CGFloat = superview.bounds.width - (view.frame.width + point.x)
        let newY:CGFloat = superview.bounds.height - (view.frame.height + point.y)
        return CGPoint(x: newX, y: newY)
    }

    private func rootview(view:UIView)->UIView{
        guard var rootview = view.superview else{
            return view
        }
        while true{
            if rootview.superview == nil { break }
            rootview = rootview.superview!
        }
        
        return rootview
    }
    
    private func toolbarShowAnimation(keyboardRect:CGRect, duration:NSTimeInterval, options:UIViewAnimationOptions){
        let movedY:CGFloat = UIScreen.mainScreen().bounds.height - (self.toolbar.frame.height + keyboardRect.height)
        UIView.animateWithDuration(
            duration,
            delay: 0.0,
            options: options,
            animations: {() -> Void in
                self.toolbar.frame.origin.y = movedY
            },
            completion: {(finished) -> Void in
            }
        )
    }
    
    private func toolbarHideAnimation(duration:NSTimeInterval, options:UIViewAnimationOptions){
        let movedY:CGFloat = UIScreen.mainScreen().bounds.height + kShadowHeight
        UIView.animateWithDuration(
            duration,
            delay: 0.0,
            options: options,
            animations: {() -> Void in
                self.toolbar.frame.origin.y = movedY
            },
            completion: {(finished) -> Void in
            }
        )
    }
}

extension TATextView:UITextViewDelegate{
    
    public func textViewDidChange(textView: UITextView) {
        self.text   = self.textView.text
        
        let afterHeight = self.textView.contentSize.height + (kMarginDefault * 2.0)
        //改行のするとtrue
        if self.toolbar.frame.height != afterHeight{
            if (afterHeight < kMinimumDefault || afterHeight > kMaximumDefault) { return }
            
            //差を計算
            let dif:CGFloat = afterHeight - self.toolbar.frame.height
            //y座標変更
            self.toolbar.frame.origin.y -= dif
            //高さを変更
            self.textView.frame.size.height  = self.textView.contentSize.height
            self.toolbar.frame.size.height   = afterHeight
            
            //ボタンの位置を調整
            self.returnBtn.frame.origin = self.opposite(self.returnBtn, superview: self.toolbar, point: CGPoint(x: kMarginDefault, y: kMarginDefault))

        }

    }
}

extension TATextView{
    public func toolbarShadowStyle(){
        self.toolbar.layer.borderWidth  = 0.0
        self.toolbar.layer.borderColor  = nil
        self.toolbar.layer.shadowOffset.height  = -kShadowHeight
        self.toolbar.layer.shadowOpacity        = 0.15
    }
}































