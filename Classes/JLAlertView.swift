//
//  JLAlertView.swift
//  JLAlertViewDemo
//
//  Created by skyline on 16/4/5.
//  Copyright © 2016年 skyline. All rights reserved.
//

import UIKit

public typealias ButtonActionBlock = (_ title:String, _ alert:JLAlertView) -> Void
public typealias TextFieldConfigurationBlock = (_ textField:UITextField) -> Void

public enum JLAlertActionStyle {
    case `default`
    case cancel
    case destructive
}

var backgroundWindow:UIWindow = {
    let window = UIWindow(frame: UIScreen.main.bounds)
    window.isOpaque = false
    window.windowLevel = UIWindowLevelAlert
    return window
}()

var currentAlertView:JLAlertView?

open class JLAlertView: UIViewController {
    fileprivate let kBakcgroundTansperancy:CGFloat = 0.3
    fileprivate let kAnimationDuration:Double = 0.2
    fileprivate let kAlertViewHorizontalMargin:CGFloat = 25
    fileprivate let kButtonHeight:CGFloat = 45
    fileprivate let kTextFieldWidth:CGFloat = 280
    fileprivate let kBorderCornerRadius:CGFloat = 5

    fileprivate let kTitleFontName = "Helvetica-Bold"
    fileprivate let kTitleFontSize:CGFloat = 18
    fileprivate let kMessageFontName = "Helvetica"
    fileprivate let kMessageFontSize:CGFloat = 15

    var alertTitle:String?
    var message:String?
    var image:UIImage?

    fileprivate var oldKeyWindow:UIWindow?

    fileprivate let contentView = UIView()
    fileprivate let stackView = UIStackView()
    fileprivate let titleLabel = UILabel()
    fileprivate let messageLabel = UILabel()

    fileprivate let textFieldStackView = UIStackView()
    fileprivate let buttonStackView = UIStackView()
    fileprivate let imageView = UIImageView()

    fileprivate let visualEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .light))
    fileprivate var visualEffectBackgroundLayer = CAShapeLayer()

    var buttons = [UIButton]()
    var textFields = [UITextField]()

    fileprivate var buttonActionMap = [UIButton:ButtonActionBlock]()

    init(title:String?=nil, message:String?=nil) {
        super.init(nibName: nil, bundle: nil)
        self.alertTitle = title
        self.message = message

        self.view.frame = UIScreen.main.bounds
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismissThis)))
        self.view.translatesAutoresizingMaskIntoConstraints = false
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    fileprivate func setupContentView() {
        view.addSubview(contentView)

        contentView.backgroundColor = UIColor.white.withAlphaComponent(0.8)
        contentView.translatesAutoresizingMaskIntoConstraints = false
        
        let margin = view.layoutMarginsGuide

        contentView.centerYAnchor.constraint(equalTo: margin.centerYAnchor).isActive = true
        contentView.centerXAnchor.constraint(equalTo: margin.centerXAnchor).isActive = true

        contentView.widthAnchor.constraint(equalToConstant: 300).isActive = true

        contentView.heightAnchor.constraint(greaterThanOrEqualToConstant: kButtonHeight + kAlertViewHorizontalMargin).isActive = true

        contentView.layer.cornerRadius = kBorderCornerRadius
        contentView.layer.masksToBounds = true

        contentView.addSubview(stackView)

        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        stackView.leftAnchor.constraint(equalTo: contentView.leftAnchor).isActive = true
        stackView.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
        stackView.widthAnchor.constraint(equalTo: contentView.widthAnchor).isActive = true
        stackView.heightAnchor.constraint(equalTo: contentView.heightAnchor).isActive = true

        stackView.distribution = .fillProportionally
        stackView.axis = .vertical
        stackView.alignment = .fill
    }

    fileprivate func setupTitleLabel() {
        guard alertTitle != nil else {
            return
        }
        titleLabel.text = alertTitle
        titleLabel.numberOfLines = 1
        titleLabel.textAlignment = .center
        titleLabel.font = UIFont(name: kTitleFontName, size:kTitleFontSize)
        titleLabel.textColor = UIColor.black
        titleLabel.preferredMaxLayoutWidth = contentView.bounds.width - 20
    }

    fileprivate func setupMessageLabel() {
        guard message != nil else {
            return
        }
        messageLabel.text = message
        messageLabel.numberOfLines = 0
        messageLabel.textAlignment = .center
        messageLabel.font = UIFont(name: kMessageFontName, size: kMessageFontSize)
        messageLabel.textColor = UIColor.black
        messageLabel.preferredMaxLayoutWidth = contentView.bounds.width - 20
    }

    fileprivate func setupImage() {
        guard image != nil else {
            return
        }
        imageView.image = image
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFit
    }

    fileprivate func setupTextField() {
        let textFieldCount = textFields.count
        guard textFieldCount > 0 else {
            return
        }

        textFieldStackView.axis = .vertical
        textFieldStackView.distribution = .fillEqually
        textFieldStackView.alignment = .fill

        textFieldStackView.spacing = 2
        textFieldStackView.translatesAutoresizingMaskIntoConstraints = false
        textFieldStackView.layoutMargins = UIEdgeInsets(top: 7, left: 0, bottom: 7, right: 0)
        textFieldStackView.isLayoutMarginsRelativeArrangement = true

        for textField in textFields {
            textFieldStackView.addArrangedSubview(textField)
        }
    }

    fileprivate func setupButtons() {
        let buttonCount = buttons.count

        guard buttonCount > 0 else {
            return
        }
        buttonStackView.distribution = .fillEqually
        buttonStackView.alignment = .fill

        if (buttonCount <= 2) {
            buttonStackView.axis = .horizontal
        } else {
            buttonStackView.axis = .vertical
        }

        for button in buttons {
            buttonStackView.addArrangedSubview(button)
        }
    }

    open func addButttonWithTitle(_ title:String, style:JLAlertActionStyle = .default, action:ButtonActionBlock?) -> JLAlertView {
        let button = UIButton(type: .system)

        button.setTitle(title, for: UIControlState())
        button.addTarget(self, action: #selector(buttonPressed(_:)), for: .touchUpInside)

        switch style {
        case .default:
            button.titleLabel?.font = UIFont(name: kTitleFontName, size: kMessageFontSize)
        case .cancel: break
        case .destructive:
            button.titleLabel?.font = UIFont(name: kTitleFontName, size: kMessageFontSize)
            button.setTitleColor(UIColor.red, for: UIControlState())
        }
        button.heightAnchor.constraint(equalToConstant: kButtonHeight).isActive = true
        buttons.append(button)
        buttonActionMap[button] = action

        return self
    }

    open func addTextFieldWithConfigurationHandler(_ handler:TextFieldConfigurationBlock) -> JLAlertView {
        let textField = UITextField()
        handler(textField)
        textFields.append(textField)

        return self
    }

    func buttonPressed(_ sender:UIButton) {
        if let action = buttonActionMap[sender] {
            action(sender.currentTitle!, self)
        }
        hideWithAnimation()
    }

    open func addImage(_ image:UIImage) -> JLAlertView {
        self.image = image
        return self
    }

    func show() {
        oldKeyWindow = UIApplication.shared.keyWindow

        backgroundWindow.makeKeyAndVisible()
        backgroundWindow.rootViewController = self

        currentAlertView = self

        setupContentView()
        setupTitleLabel()
        setupMessageLabel()
        setupImage()
        setupTextField()
        setupButtons()

        let hasTitle = alertTitle != nil
        let hasMessage = message != nil
        let hasImage = image != nil
        let hasTextField = textFields.count > 0
        let hasButton = buttons.count > 0

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
            stackView.isLayoutMarginsRelativeArrangement = true
        }

        showWithAnimation()
    }

    func dismissThis() {
        hideWithAnimation()
    }

    fileprivate func showWithAnimation() {
        backgroundWindow.alpha = 0
        var scale = 1 / (1 - (2 * kAlertViewHorizontalMargin / UIScreen.main.bounds.width));
        scale = min(scale, 1.2)
        contentView.transform = CGAffineTransform(scaleX: scale, y: scale);
        visualEffectView.removeFromSuperview()
        visualEffectBackgroundLayer.removeFromSuperlayer()

        view.backgroundColor = UIColor(red:0, green:0, blue:0, alpha:self.kBakcgroundTansperancy)

        UIView.animate(withDuration: kAnimationDuration, animations: {
            backgroundWindow.alpha = 1
            self.contentView.transform = CGAffineTransform.identity
            }, completion: { (complete) in

                let wholePath = UIBezierPath(rect: self.view.bounds)
                let transparentPath = UIBezierPath(roundedRect: self.contentView.frame, cornerRadius: self.kBorderCornerRadius)
                wholePath.append(transparentPath)
                wholePath.usesEvenOddFillRule = true

                self.visualEffectBackgroundLayer = CAShapeLayer()
                self.visualEffectBackgroundLayer.path = wholePath.cgPath
                self.visualEffectBackgroundLayer.fillRule = kCAFillRuleEvenOdd
                self.visualEffectBackgroundLayer.fillColor = UIColor(red:0, green:0, blue:0, alpha:self.kBakcgroundTansperancy).cgColor
                self.view.layer.insertSublayer(self.visualEffectBackgroundLayer, at: 0)

                self.view.insertSubview(self.visualEffectView, at: 0)

                self.visualEffectView.translatesAutoresizingMaskIntoConstraints = false
                self.visualEffectView.topAnchor.constraint(equalTo: self.contentView.topAnchor).isActive = true
                self.visualEffectView.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor).isActive = true
                self.self.visualEffectView.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor).isActive = true
                self.visualEffectView.trailingAnchor.constraint(equalTo: self.self.contentView.trailingAnchor).isActive = true

                self.visualEffectView.layer.cornerRadius = self.kBorderCornerRadius
                self.visualEffectView.clipsToBounds = true

                self.view.backgroundColor = nil
        }) 
    }


    fileprivate func hideWithAnimation() {
        backgroundWindow.alpha = 1
        UIView.animate(withDuration: kAnimationDuration, animations: {
            backgroundWindow.alpha = 0
        }) 
    }
}
