//
//  JLAlertView.swift
//  JLAlertViewDemo
//
//  Created by skyline on 16/4/5.
//  Copyright © 2016年 skyline. All rights reserved.
//

import UIKit

public typealias ButtonActionBlock = (title:String, alert:JLAlertView) -> Void
public typealias TextFieldConfigurationBlock = (textField:UITextField) -> Void

public enum JLAlertActionStyle {
    case Default
    case Cancel
    case Destructive
}

var backgroundWindow:UIWindow = {
    let window = UIWindow(frame: UIScreen.mainScreen().bounds)
    window.opaque = false
    window.windowLevel = UIWindowLevelAlert
    return window
}()

var currentAlertView:JLAlertView?

public class JLAlertView: UIViewController {
    private let kBakcgroundTansperancy:CGFloat = 0.3
    private let kAnimationDuration:Double = 0.2
    private let kAlertViewHorizontalMargin:CGFloat = 25
    private let kButtonHeight:CGFloat = 45
    private let kTextFieldWidth:CGFloat = 280

    private let kTitleFontName = "Helvetica-Bold"
    private let kTitleFontSize:CGFloat = 18
    private let kMessageFontName = "Helvetica"
    private let kMessageFontSize:CGFloat = 15

    var alertTitle:String?
    var message:String?
    var image:UIImage?

    private var oldKeyWindow:UIWindow?

    private let contentView = UIView()
    private let stackView = UIStackView()
    private let titleLabel = UILabel()
    private let messageLabel = UILabel()

    private let textFieldStackView = UIStackView()
    private let buttonStackView = UIStackView()
    private let imageView = UIImageView()

    var buttons = [UIButton]()
    var textFields = [UITextField]()

    private var buttonActionMap = [UIButton:ButtonActionBlock]()

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
        guard self.alertTitle != nil else {
            return
        }
        titleLabel.text = self.alertTitle
        titleLabel.numberOfLines = 1
        titleLabel.textAlignment = .Center
        titleLabel.font = UIFont(name: kTitleFontName, size:kTitleFontSize)
        titleLabel.textColor = UIColor.blackColor()
        titleLabel.preferredMaxLayoutWidth = CGRectGetWidth(contentView.bounds) - 20
    }

    private func setupMessageLabel() {
        guard self.message != nil else {
            return
        }
        messageLabel.text = self.message
        messageLabel.numberOfLines = 0
        messageLabel.textAlignment = .Center
        messageLabel.font = UIFont(name: kMessageFontName, size: kMessageFontSize)
        messageLabel.textColor = UIColor.blackColor()
        messageLabel.preferredMaxLayoutWidth = CGRectGetWidth(contentView.bounds) - 20
    }

    private func setupImage() {
        guard self.image != nil else {
            return
        }
        imageView.image = image
        imageView.clipsToBounds = true
        imageView.contentMode = .ScaleAspectFit
    }

    private func setupTextField() {
        let textFieldCount = textFields.count
        guard textFieldCount > 0 else {
            return
        }

        textFieldStackView.axis = .Vertical
        textFieldStackView.distribution = .FillEqually
        textFieldStackView.alignment = .Fill

        textFieldStackView.spacing = 2
        textFieldStackView.translatesAutoresizingMaskIntoConstraints = false
        textFieldStackView.layoutMargins = UIEdgeInsets(top: 7, left: 0, bottom: 7, right: 0)
        textFieldStackView.layoutMarginsRelativeArrangement = true

        for textField in textFields {
            textFieldStackView.addArrangedSubview(textField)
        }
    }

    private func setupButtons() {
        let buttonCount = buttons.count

        guard buttonCount > 0 else {
            return
        }
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

    public func addButttonWithTitle(title:String, style:JLAlertActionStyle = .Default, action:ButtonActionBlock?) -> JLAlertView {
        let button = UIButton(type: .System)

        button.setTitle(title, forState: .Normal)
        button.addTarget(self, action: #selector(buttonPressed(_:)), forControlEvents: .TouchUpInside)

        switch style {
        case .Default:
            button.titleLabel?.font = UIFont(name: kTitleFontName, size: kMessageFontSize)
        case .Cancel: break
        case .Destructive:
            button.titleLabel?.font = UIFont(name: kTitleFontName, size: kMessageFontSize)
            button.setTitleColor(UIColor.redColor(), forState: .Normal)
        }
        button.heightAnchor.constraintEqualToConstant(kButtonHeight).active = true
        buttons.append(button)
        buttonActionMap[button] = action

        return self
    }

    public func addTextFieldWithConfigurationHandler(handler:TextFieldConfigurationBlock) -> JLAlertView {
        let textField = UITextField()
        handler(textField: textField)
        textFields.append(textField)

        return self
    }

    func buttonPressed(sender:UIButton) {
        if let action = buttonActionMap[sender] {
            action(title: sender.currentTitle!, alert: self)
        }
        hideWithAnimation()
    }

    public func addImage(image:UIImage) -> JLAlertView {
        self.image = image
        return self
    }

    func show() {
        oldKeyWindow = UIApplication.sharedApplication().keyWindow

        backgroundWindow.makeKeyAndVisible()
        backgroundWindow.rootViewController = self

        currentAlertView = self

        setupContentView()
        setupTitleLabel()
        setupMessageLabel()
        setupImage()
        setupTextField()
        setupButtons()

        let hasTitle = self.alertTitle != nil
        let hasMessage = self.message != nil
        let hasImage = self.image != nil
        let hasTextField = self.textFields.count > 0
        let hasButton = self.buttons.count > 0

        if hasTitle {
            stackView.addArrangedSubview(titleLabel)
        }
        if hasMessage {
            stackView.addArrangedSubview(messageLabel)
        }
        if hasImage {
            stackView.addArrangedSubview(imageView)
        }
        if hasTextField {
            stackView.addArrangedSubview(textFieldStackView)
        }
        if hasButton {
            stackView.addArrangedSubview(buttonStackView)
        }

        if hasTitle || hasMessage {
            stackView.layoutMargins = UIEdgeInsets(top: 20, left: 10, bottom: 0, right: 10)
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



