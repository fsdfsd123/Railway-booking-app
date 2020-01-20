//
//  BookingSummaryViewController.swift
//  Shinkansen 3D Seat Booking Prototype
//
//  Created by Virakri Jinangkul on 5/14/19.
//  Copyright © 2019 Virakri Jinangkul. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
class RecordDetailViewController: BookingViewController {
    
    var Index = 0
    
    var thistrainSchedule:TrainSchedule?
    
    var seatClassEntity: SeatClassEntity?
    
    var summaryPreviewView: SummaryPreviewView!
    
    var mainCardView: CardControl!
    
    var dateLabelContainerView: UIView!
    
    var seatClassType: SeatClassType?
    
    var mainvc: MyticketViewcontroller?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupStaticContent()
        //mainCardView.isHidden = true
    }
    
    override func setupView() {
        super.setupView()
        mainViewType = .view
        
        dateLabelContainerView = UIView(containingView: dateLabel,
                                        withConstaintEquals: [.centerHorizontal, .top, .bottom],
                                        insetsConstant: .init(top: 4, leading: 0, bottom: 0, trailing: 0))
        
        let placeholderView = UIView()
        
        mainStackView.removeArrangedSubview(datePlaceholderLabel)
        mainStackView.removeArrangedSubview(mainContentView)
        mainStackView.insertArrangedSubview(mainContentView, at: 0)
        mainStackView.insertArrangedSubview(dateLabelContainerView, at: 1)
        mainStackView.addArrangedSubview(UIView())
        mainStackView.addArrangedSubview(placeholderView)
        
        view.addSubview(datePlaceholderLabel, withConstaintEquals: [.topSafeArea, .centerHorizontal])
        view.addConstraints(toView: datePlaceholderLabel, withConstaintGreaterThanOrEquals: [.leadingMargin, .trailingMargin])
        
        let datePlaceholderLabelWidthConstraint = datePlaceholderLabel.widthAnchor.constraint(equalToConstant: DesignSystem.layout.maximumWidth)
        datePlaceholderLabelWidthConstraint.priority = .defaultHigh
        datePlaceholderLabelWidthConstraint.isActive = true
        
        mainCardView = CardControl(type: .large)
        mainContentView.addSubview(mainCardView,
                                   withConstaintEquals: .edges,
                                   insetsConstant: .init(top: -mainCardView.layer.cornerRadius))
        mainContentView.heightAnchor.constraint(lessThanOrEqualTo:  mainContentView.widthAnchor, multiplier: 1).isActive = true
        
        summaryPreviewView = SummaryPreviewView()
        summaryPreviewView.setupContent(withSeatClassType: seatClassType)
        
        // Setup Main Card View
        mainCardView.contentView
            .addSubview(summaryPreviewView,
                        withConstaintEquals: .edges)
        mainCardView.contentView
            .isUserInteractionEnabled = true
        
        placeholderView.translatesAutoresizingMaskIntoConstraints = false
        placeholderView.topAnchor.constraint(equalTo: mainCallToActionButton.topAnchor).isActive = true
        
        setHeaderInformationValue(headerInformation)
        view.bringSubviewToFront(backButton)
    }
    
    override func setupTheme() {
        super.setupTheme()
    }
    
    override func setupInteraction() {
        super.setupInteraction()
        
        mainCallToActionButton.addTarget(self,
                                         action: #selector(mainCallToActionButtonDidTouch(_:)),
                                         for: .touchUpInside)
        
        backButton.addTarget(self,
                             action: #selector(backButtonDidTouch(_:)),
                             for: .touchUpInside)
    }
    
    override func setHeaderInformationValue(_ headerInformation: HeaderInformation?) {
        super.setHeaderInformationValue(headerInformation)
    }
    
    private func setupStaticContent() {
        mainCallToActionButton.setTitle("Cancel this Ticket")
    }
    
    @objc func mainCallToActionButtonDidTouch(_ sender: Button) {
        
        Myticket.remove(at: Index)
        TotalTicketlist.ticketlist.remove(at: Index)
        var ref: DatabaseReference! = Database.database().reference()
        let userID = Auth.auth().currentUser?.uid
        ref.child("users").child(userID!).child("tickets").setValue(TotalTicketlist.convertToDict())
        //mainvc?.mainTableView.reloadData()
        //navigationController?.popViewController(animated: true)
        navigationController?.popToRootViewController(animated: true)
    }
    
    @objc func backButtonDidTouch(_ sender: Button) {
        navigationController?.popViewController(animated: true)
    }
}
