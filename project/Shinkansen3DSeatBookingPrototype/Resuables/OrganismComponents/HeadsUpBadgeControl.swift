//
//  HeadsUpBadgeControl.swift
//  Shinkansen 3D Seat Booking Prototype
//
//  Created by Virakri Jinangkul on 6/19/19.
//  Copyright © 2019 Virakri Jinangkul. All rights reserved.
//

import UIKit
import Kumi

class HeadsUpBadgeControl: CardControl {
    
    private var label: Label
    
//    private var initialYOffset: CGFloat = -CGFloat(32).systemSizeMuliplier() * 1.5
    
     init() {
        label = Label()
        super.init(type: .regularAlternative)
        setupView()
        setupTheme()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        contentView.addSubview(label, withConstaintEquals: .marginEdges)
        contentView.directionalLayoutMargins = .init(vertical: 12, horizontal: 16)
    }
    
    public override func setupTheme() {
        super.setupTheme()
        label.textStyle = textStyle.caption1()
        label.textColor = currentColorTheme.componentColor.secondaryText
        
    }
    
    public func setupContent(message: String,
                             animated: Bool = true,
                             delay: TimeInterval = 0,
                             completion: ((Bool)->())? = nil) {
        label.text = message
        isHidden = false
        if animated {
            alpha = 0
            layoutIfNeeded()
            transform.ty = -bounds.height * 1.5
            UIView.animate(withStyle: .halfTransitionAnimationStyle,
                           delay: delay,
                           animations: {
                            self.alpha = 1
                            self.transform.ty = 0
            },
                           completion: completion)
        }
    }
    
    public func dismiss(animated: Bool = true,
                        delay: TimeInterval = 0,
                        removeWhenComplete: Bool = true,
                        completion: ((Bool)->())? = nil) {
        isHidden = false
        if animated {
            layer.removeAllAnimations()
            alpha = 1
            transform.ty = 0
            UIView
                .animate(withStyle: .transitionAnimationStyle,
                         delay: delay,
                         animations: {
                            [weak self] in
                            self?.alpha = 0
                            self?.transform.ty = -(self?.bounds.height ?? 0) * 1.5
                }, completion: {
                    finished in
                    if removeWhenComplete { self.removeFromSuperview() }
                    if let completion = completion {
                        completion(finished)
                    }
                })
        } else {
            if removeWhenComplete { self.removeFromSuperview() }
            if let completion = completion {
                completion(true)
            }
        }
    }
}
