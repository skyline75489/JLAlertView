//
//  JLAlertView.swift
//  JLAlertViewDemo
//
//  Created by skyline on 16/4/5.
//  Copyright © 2016年 skyline. All rights reserved.
//

import UIKit

public typealias ButtonActionBlock = (title:String) -> Void

var backgroundWindow:UIWindow = {
    let window = UIWindow(frame: UIScreen.mainScreen().bounds)
    window.opaque = false
    window.windowLevel = UIWindowLevelAlert
    return window
}()

var currentAlertView:JLAlertView?

public class JLAlertView: UIViewController {
    let kBakcgroundTansperancy:CGFloat = 0.3
    let kAnimationDuration:Double = 0.2
    let kAlertViewHorizontalMargin:CGFloat = 25
    let kButtonHeight:CGFloat = 45

    let kTitleFont = "Helvetica-Bold"
    let kMessageFont = "Helvetica"

    var alertTitle:String?
    var message:String?
    var oldKeyWindow:UIWindow?

    let contentView = UIView()
    let stackView = UIStackView()
    let buttonStackView = UIStackView()
    let titleLabel = UILabel()
    let messageLabel = UILabel()
    var buttons = [UIButton]()

    var buttonActionMap = [UIButton:ButtonActionBlock]()

    init(title:String?=nil, message:String?=nil) {
        super.init(nibName: nil, bundle: nil)
        self.alertTitle = title
        self.message = message

        self.view.frame = UIScreen.mainScreen().bounds
        self.view.backgroundColor = UIColor(red:0, green:0, blue:0, alpha:kBakcgroundTansperancy)
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismiss)))
        self.view.translatesAutoresizingMaskIntoConstraints = false
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupContentView() {
        view.addSubview(contentView)

        contentView.backgroundColor = UIColor.whiteColor()
        contentView.translatesAutoresizingMaskIntoConstraints = false
        
        let margin = view.layoutMarginsGuide

        contentView.centerYAnchor.constraintEqualToAnchor(margin.centerYAnchor).active = true
        contentView.centerXAnchor.constraintEqualToAnchor(margin.centerXAnchor).active = true

        contentView.widthAnchor.constraintEqualToConstant(300).active = true

        contentView.heightAnchor.constraintGreaterThanOrEqualToConstant(kButtonHeight + kAlertViewHorizontalMargin).active = true

        contentView.layer.cornerRadius = 5.0
        contentView.layer.masksToBounds = true

        contentView.addSubview(stackView)

        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        stackView.leftAnchor.constraintEqualToAnchor(contentView.leftAnchor).active = true
        stackView.topAnchor.constraintEqualToAnchor(contentView.topAnchor).active = true
        stackView.widthAnchor.constraintEqualToAnchor(contentView.widthAnchor).active = true
        stackView.heightAnchor.constraintEqualToAnchor(contentView.heightAnchor).active = true

        stackView.distribution = .FillProportionally
        stackView.axis = .Vertical
        stackView.alignment = .Fill

    }

    private func setupTitleLabel() {
        titleLabel.text = self.alertTitle ?? ""
        titleLabel.numberOfLines = 1
        titleLabel.textAlignment = .Center
        titleLabel.font = UIFont(name: kTitleFont, size:18)
        titleLabel.textColor = UIColor.blackColor()
        titleLabel.preferredMaxLayoutWidth = CGRectGetWidth(contentView.bounds) - 20
    }

    private func setupMessageLabel() {
        messageLabel.text = self.message ?? ""
        messageLabel.numberOfLines = 0
        messageLabel.textAlignment = .Center
        messageLabel.font = UIFont(name: kMessageFont, size: 15)
        messageLabel.textColor = UIColor.blackColor()
        messageLabel.preferredMaxLayoutWidth = CGRectGetWidth(contentView.bounds) - 20
    }

    private func setupButtons() {
        let buttonCount = buttons.count

        buttonStackView.distribution = .FillEqually
        buttonStackView.alignment = .Fill

        if (buttonCount <= 2) {
            buttonStackView.axis = .Horizontal
        } else {
            buttonStackView.axis = .Vertical
        }

        for button in buttons {
            buttonStackView.addArrangedSubview(button)
        }
    }

    public func addButttonWithTitle(title:String, action:ButtonActionBlock?) -> JLAlertView {
        let button = UIButton(type: .System)

        button.setTitle(title, forState: .Normal)
        button.addTarget(self, action: #selector(buttonPressed(_:)), forControlEvents: .TouchUpInside)

        button.heightAnchor.constraintEqualToConstant(kButtonHeight).active = true
        buttons.append(button)
        buttonActionMap[button] = action

        return self
    }

    func buttonPressed(sender:UIButton) {
        if let action = buttonActionMap[sender] {
            action(title: sender.currentTitle!)
        }
        hideWithAnimation()
    }

    func show() {
        oldKeyWindow = UIApplication.sharedApplication().keyWindow

        backgroundWindow.makeKeyAndVisible()
        backgroundWindow.rootViewController = self

        currentAlertView = self

        setupContentView()
        setupTitleLabel()
        setupMessageLabel()
        setupButtons()

        let hasTitle = self.alertTitle != nil
        let hasMessage = self.message != nil
        let hasButton = self.buttons.count > 0

        let buttonOnly = hasButton && (!hasTitle && !hasMessage)
        if hasTitle {
            stackView.addArrangedSubview(titleLabel)
        }
        if hasMessage {
            stackView.addArrangedSubview(messageLabel)
        }

        if hasButton {
            stackView.addArrangedSubview(buttonStackView)
        }

        if !buttonOnly {
            stackView.layoutMargins = UIEdgeInsets(top: 20, left: 0, bottom: 0, right: 0)
            stackView.layoutMarginsRelativeArrangement = true
        }

        showWithAnimation()
    }

    func dismiss() {
        hideWithAnimation()
    }

    private func showWithAnimation() {
        backgroundWindow.alpha = 0
        var scale = 1 / (1 - (2 * self.kAlertViewHorizontalMargin / UIScreen.mainScreen().bounds.width));
        scale = min(scale, 1.2)
        self.contentView.transform = CGAffineTransformMakeScale(scale, scale);

        UIView.animateWithDuration(kAnimationDuration) {
            backgroundWindow.alpha = 1
            self.contentView.transform = CGAffineTransformIdentity
        }
    }

    private func hideWithAnimation() {
        backgroundWindow.alpha = 1
        UIView.animateWithDuration(kAnimationDuration) {
            backgroundWindow.alpha = 0
        }
    }
}



