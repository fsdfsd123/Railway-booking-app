//
//  StationPairView.swift
//  Shinkansen 3D Seat Booking Prototype
//
//  Created by Virakri Jinangkul on 5/30/19.
//  Copyright © 2019 Virakri Jinangkul. All rights reserved.
//

import UIKit
import Kumi

class StationPairView: UIStackView {
    
    var fromStationHeadlineView: HeadlineLabelSetView
    
    var toStationHeadlineView: HeadlineLabelSetView
    
    var toLabel: Label
    
    init(fromStation: String, fromTime: String? = nil,
         toStation: String, toTime: String? = nil) {
        fromStationHeadlineView = HeadlineLabelSetView(title: fromStation, subtitle: fromTime, textAlignment: .left)
        toStationHeadlineView = HeadlineLabelSetView(title: toStation, subtitle: toTime, textAlignment: .right)
        toLabel = Label()
        super.init(frame: .zero)
        setupView()
        setupTheme()
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        alignment = .firstBaseline
        distribution = .equalSpacing
        addArrangedSubview(fromStationHeadlineView)
        addArrangedSubview(toLabel)
        addArrangedSubview(toStationHeadlineView)
        
        toLabel.text = "to"
        toLabel.textAlignment = .center
    }
    
    public func setupTheme() {
        fromStationHeadlineView.setupTheme()
        toStationHeadlineView.setupTheme()
        toLabel.textColor = currentColorTheme.componentColor.secondaryText
        toLabel.textStyle = textStyle.subheadline()
    }
    
    public func setupValue(fromStation: String, fromTime: String? = nil,
                          toStation: String, toTime: String? = nil) {
        fromStationHeadlineView.setupValue(title: fromStation, subtitle: fromTime)
        toStationHeadlineView.setupValue(title: toStation, subtitle: toTime)
        
        fromStationHeadlineView.subtitleLabel.isHidden = fromTime == nil && toTime == nil
        toStationHeadlineView.subtitleLabel.isHidden = fromTime == nil && toTime == nil
        
    }
}
