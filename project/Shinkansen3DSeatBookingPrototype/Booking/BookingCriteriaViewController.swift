//
//  BookingCriteriaViewController.swift
//  Shinkansen 3D Seat Booking Prototype
//
//  Created by Virakri Jinangkul on 5/14/19.
//  Copyright © 2019 Virakri Jinangkul. All rights reserved.
//

import UIKit

class BookingCriteriaViewController: BookingViewController,DateTimePickerDelegate,UITextFieldDelegate {
    
    var fromStation = "台北"
    
    var destinationStation = "台南"
    
    let traintypes = ["普悠瑪號","太魯閣號","自強號","莒光號","區間車"]
    
    var stackView: UIStackView!
    
    var headerStackView: UIStackView!
    
    var inputStackView: UIStackView!
    
    var headlineLabel: Label!
    
    var logoImageView: UIImageView!
    
    var horizontalStationStackView: UIStackView!
    
    var fromStationContainerView: HeadlineWithContainerView!
    
    var fromStationCardControl: StationCardControl!
    
    var destinationStationContainerView: HeadlineWithContainerView!
    
    var destinationStationCardControl: StationCardControl!
    
    var arrowImageView: UIImageView!
    
    var dateSegmentedContainerView: HeadlineWithContainerView!
    
    var timeSegmentedContainerView: HeadlineWithContainerView!
    
    var trainTypeContainerView: HeadlineWithContainerView!
    
    var dateSegmentedControl : SegmentedControl!
    
    var timeSegmentedControl: SegmentedControl!
    
    var trainTypeControl: SegmentedControl!
    
    static let errorGeneratorFeedback = UINotificationFeedbackGenerator()
    
    private var logoImageAlignmentConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        //trainTypeContainerView.isHidden = false
        super.viewDidLoad()
        setupStaticContent()
    }
    
    override func setupView() {
        super.setupView()
        dateLabel.isHidden = true
        headerRouteInformationView.isHidden = true
        mainStackView.isHidden = true
        backButton.isHidden = true
        
        //
        
        headlineLabel = Label()
        headlineLabel.numberOfLines = 0
        
        logoImageView = UIImageView()
        logoImageView.setContentHuggingPriority(.required, for: .horizontal)
        let logoImageContainerView = UIView(containingView: logoImageView, withConstaintEquals: [.leading, .trailing])
        
        headerStackView = UIStackView([headlineLabel, logoImageContainerView],
                                      axis: .horizontal,
                                      distribution: .fill,
                                      alignment: .top)
        headerStackView.isHidden=true
        logoImageAlignmentConstraint = logoImageView.topAnchor.constraint(equalTo: headlineLabel.firstBaselineAnchor)
        logoImageAlignmentConstraint.isActive = true
        
        fromStationCardControl = StationCardControl()
        
        destinationStationCardControl = StationCardControl()
        
        fromStationContainerView = HeadlineWithContainerView(containingView: fromStationCardControl)
        
        destinationStationContainerView = HeadlineWithContainerView(containingView: destinationStationCardControl)
        
        arrowImageView = UIImageView()
        
        arrowImageView.setContentHuggingPriority(.required, for: .horizontal)
        
        let arrowImageContainerView = UIView(containingView: arrowImageView, withConstaintEquals: [.leading, .trailing])
        
        horizontalStationStackView = UIStackView([fromStationContainerView,
                                        arrowImageContainerView,
                                        destinationStationContainerView],
                                       axis: .horizontal,
                                       distribution: .fill,
                                       alignment: .fill,
                                       spacing: 12)
        
        arrowImageView.centerYAnchor.constraint(equalTo: fromStationContainerView.view.centerYAnchor).isActive = true
        
        fromStationContainerView.widthAnchor.constraint(equalTo: destinationStationContainerView.widthAnchor).isActive = true
        
        dateSegmentedControl = SegmentedControl()
        dateSegmentedContainerView = HeadlineWithContainerView(containingView: dateSegmentedControl)
        
        timeSegmentedControl = SegmentedControl()
        timeSegmentedContainerView = HeadlineWithContainerView(containingView: timeSegmentedControl)
        
        trainTypeControl = SegmentedControl()
        trainTypeContainerView = HeadlineWithContainerView(containingView: trainTypeControl)
        
        
        inputStackView = UIStackView([horizontalStationStackView,
                                      dateSegmentedContainerView,
                                      timeSegmentedContainerView,
                                      trainTypeContainerView],
                                     axis: .vertical,
                                     distribution: .fill,
                                     alignment: .fill,
                                     spacing: 24)
        
        stackView = UIStackView([headerStackView,
                                 inputStackView],
                                axis: .vertical,
                                distribution: .fill,
                                alignment: .fill, spacing: DesignSystem.isNarrowScreen ? 24 : 48)
        
        view.addSubview(stackView,
                        withConstaintEquals: [.topSafeArea, .centerHorizontal],
                        insetsConstant: .init(top: 24))
        view.addConstraints(toView: stackView, withConstaintGreaterThanOrEquals: [.leadingMargin, .trailingMargin])
        
        let stackViewWidthConstraint = stackView.widthAnchor.constraint(equalToConstant: DesignSystem.layout.maximumWidth)
        stackViewWidthConstraint.priority = .init(999)
        stackViewWidthConstraint.isActive = true
        
        

        
        
        
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        // 結束編輯 把鍵盤隱藏起來
        self.view.endEditing(true)

        return true
    }
    
    override func setupTheme() {
        super.setupTheme()
        
        headlineLabel.textStyle = textStyle.largeTitle()
        headlineLabel.textColor = currentColorTheme.componentColor.callToAction
        //headlineLabel.isHidden=true
        logoImageAlignmentConstraint.constant = -textStyle.largeTitle().font.capHeight
        
        fromStationContainerView.setupTheme()
        destinationStationContainerView.setupTheme()
        dateSegmentedContainerView.setupTheme()
        timeSegmentedContainerView.setupTheme()
        trainTypeContainerView.setupTheme()
        
        fromStationCardControl.setupTheme()
        destinationStationCardControl.setupTheme()
        dateSegmentedControl.setupTheme()
        timeSegmentedControl.setupTheme()
        
        
    }
    
    override func setupInteraction() {
        super.setupInteraction()
        
        //MARK:車站選擇button函式
        fromStationCardControl
            .addTarget(self,
                       action: #selector(stationCardControlDidTouch),
                       for: .touchUpInside)
        
        destinationStationCardControl
            .addTarget(self,
                       action: #selector(stationCardControlDidTouch2),
                       for: .touchUpInside)
        
        
        dateSegmentedControl
            .addTarget(self,
                       action: #selector(reloadTimeSegemtnedControl),
                       for: .valueChanged)
        
        mainCallToActionButton
            .addTarget(self,
                       action: #selector(mainCallToActionButtonDidTouch(_:)),
                       for: .touchUpInside)
    }
    

    func setupStaticContent() {
        //MARK:標題文字
        headlineLabel.text = "Reserve \nShinkansen \nTickets"
        
        logoImageView.image = #imageLiteral(resourceName: "Logo JR East")
        
        arrowImageView.image = #imageLiteral(resourceName: "Icon Arrow Right")
        
        fromStationContainerView.setTitle(title: "From")
        
        destinationStationContainerView.setTitle(title: "Destination")
        
        //MARK:車站選擇
    
        
        fromStationCardControl.setupValue(stationNameJP: fromStation, stationName: fromStation)
        destinationStationCardControl.setupValue(stationNameJP: destinationStation, stationName: destinationStation)
        
        dateSegmentedContainerView.setTitle(title: "Date")
        
        let today = Date()
        let tomorrow = today.addingTimeInterval(60 * 60 * 24)
        let formatter = FullDateFormatter()
        
        //MARK: 日期片段
        dateSegmentedControl.items = [(title: "Today", subtitle: formatter.string(from: today), true),
                                      (title: "Tomorrow", subtitle: formatter.string(from: tomorrow), true),
                                      (title: "Pick a Date", subtitle: " ", true)]
        dateSegmentedControl
        .addTarget(self,
                   action: #selector(dateSelect),
                   for: .touchUpInside)
        timeSegmentedContainerView.setTitle(title: "Time")
        trainTypeContainerView.setTitle(title: "Train")
        reloadTimeSegemtnedControl()
        reloadtrainTypeControl()
        mainCallToActionButton.setTitle("Search for Tickets")
    }
    
 
    @objc private func stationCardControlDidTouch() {
        let view = StationSelectTableViewController()
        view.type = 0
        view.mainvc = self
        self.present(view, animated: true, completion: nil)

    }
    
    @objc private func stationCardControlDidTouch2() {
        let view = StationSelectTableViewController()
        view.type = 1
        view.mainvc = self
        self.present(view, animated: true, completion: nil)

    }
    
    @objc private func dateSelect(){
        
        let min = Date().addingTimeInterval(-60 * 60 * 24 * 4)
        let max = Date().addingTimeInterval(60 * 60 * 24 * 4)
        let picker = DateTimePicker.create(minimumDate: min, maximumDate: max)
        
        // customize your picker
        //        picker.timeInterval = DateTimePicker.MinuteInterval.thirty
        //        picker.locale = Locale(identifier: "en_GB")
        //
        //        picker.todayButtonTitle = "Today"
        //        picker.is12HourFormat = true
        //        picker.dateFormat = "hh:mm aa dd/MM/YYYY"
        //        picker.isTimePickerOnly = true
        picker.includeMonth = true // if true the month shows at bottom of date cell
        picker.highlightColor = UIColor(red: 255.0/255.0, green: 138.0/255.0, blue: 138.0/255.0, alpha: 1)
        picker.darkColor = UIColor.darkGray
        picker.doneButtonTitle = "SELECT"
        picker.doneBackgroundColor = UIColor(red: 255.0/255.0, green: 138.0/255.0, blue: 138.0/255.0, alpha: 1)
        picker.completionHandler = { date in
            let formatter = DateFormatter()
            //formatter.dateFormat = "hh:mm aa dd/MM/YYYY"
            formatter.dateFormat = "E, d MMM yyyy HH:mm:ss Z"
            //self.title = formatter.string(from: date)
            //self.CreateTime = formatter.string(from: date)
        }
        
        picker.delegate = self
        
        // add picker to your view
        // don't try to make customize width and height of the picker,
        // you'll end up with corrupted looking UI
        //        picker.frame = CGRect(x: 0, y: 100, width: picker.frame.size.width, height: picker.frame.size.height)
        // set a dismissHandler if necessary
        //        picker.dismissHandler = {
        //            picker.removeFromSuperview()
        //        }
        //        self.view.addSubview(picker)
        
        // or show it like a modal
        if(dateSegmentedControl.selectedIndex==2){
            picker.show()
        }
        
    }
    func dateTimePicker(_ picker: DateTimePicker, didSelectDate: Date) {
        //dateSegmentedControl.items[2] = [(title: "Pick a Date", subtitle: "\(picker.selectedDateString) ", true)]
//        dateSegmentedControl.items = [(title: "Today", subtitle: formatter.string(from: today), true),
//                                      (title: "Tomorrow", subtitle: formatter.string(from: tomorrow), true),
//                                      (title: "Pick a Date", subtitle: "\(picker.selectedDateString) ", true)]
        let today = Date()
        let tomorrow = today.addingTimeInterval(60 * 60 * 24)
        let formatter = FullDateFormatter()
        
        print(picker.selectedDateString)
        dateSegmentedControl.items = [(title: "Today", subtitle: formatter.string(from: today), true),
                                      (title: "Tomorrow", subtitle: formatter.string(from: tomorrow), true),
                                      (title: "Pick a Date", subtitle: "\(picker.selectedDateString)", true)]
    }
    @objc private func reloadTimeSegemtnedControl() {
        
        let timeInterval: TimeInterval
        switch dateSegmentedControl.selectedIndex {
        case 0:
            timeInterval = 0
        case 1:
            timeInterval = 60 * 60 * 24
        default:
            
            timeInterval = 60 * 60 * 24
//            BookingCriteriaViewController
//                .errorGeneratorFeedback
//                .notificationOccurred(.error)
//            showErrorMessage("Oops! Picking a particular date feature doesn't work as this prototype doesn't have it implemented yet.")
        }
        
        let morning = (Date(byHourOf: 6)...Date(byHourOf: 12)).addingTimeInterval(timeInterval)
        let afternoon = (Date(byHourOf: 12)...Date(byHourOf: 18)).addingTimeInterval(timeInterval)
        let evening = (Date(byHourOf: 18)...Date(byHourOf: 24)).addingTimeInterval(timeInterval)
        let now = Date()
        
        //MARK:時間選擇
        timeSegmentedControl.items = [(title: "Morning",
                                       subtitle: morning.toString(),
                                       isEnabled: now < morning.upperBound),
                                      (title: "Afternoon",
                                       subtitle: afternoon.toString(),
                                       isEnabled: now < afternoon.upperBound),
                                      (title: "Evening",
                                       subtitle: evening.toString(),
                                       isEnabled: now < evening.upperBound)]
    }
    @objc private func reloadtrainTypeControl() {
        //普悠瑪號/太魯閣號/自強號/莒光號/區間車
        _ = ["普悠瑪號","太魯閣號","自強號","莒光號","區間車"]
        trainTypeControl.items = [(title: "普悠瑪",
                                        subtitle: "",
                                        isEnabled: true),
                                       (title: "太魯閣",
                                        subtitle: "",
                                        isEnabled: true),
                                       (title: "自強號",
                                        subtitle: "",
                                        isEnabled: true),
                                       (title: "莒光號",
                                       subtitle: "",
                                       isEnabled: true),
                                       (title: "區間車",
                                       subtitle: "",
                                       isEnabled: true)]
                                                        
        
    }
    @objc func mainCallToActionButtonDidTouch(_ sender: Button) {
        
        trainTypeContainerView.isHidden = true
        
        let dateOffset: TimeInterval
        switch dateSegmentedControl.selectedIndex {
        case 0:
            dateOffset = 0
        case 1:
            dateOffset = 60 * 60 * 24
        default:
            dateOffset = 60 * 60 * 24 * 2
        }
        
        let selectedDate = Date(timeIntervalSinceNow: dateOffset)
        
        let timeOffset: TimeInterval
        switch timeSegmentedControl.selectedIndex {
        case 0:
            timeOffset = 0
        case 1:
            timeOffset = TimeInterval(60 * 60 * 6)
        default:
            timeOffset = TimeInterval(60 * 60 * 12)
        }
        let trainSelectionVC = TrainSelectionViewController()
        
        let formatter = FullDateFormatter()
        let dayOfWeek = Calendar.current.weekdaySymbols[Calendar.current.component(.weekday, from: selectedDate) - 1]
        let date = formatter.string(from: selectedDate)
        let fromStation = self.fromStation
        let toStation = self.destinationStation
        //let head = HeadInfo(dayOfWeek:dayOfWeek,date:date,fromStation:fromStation,toStation:toStation)
     
        
        trainSelectionVC.headerInformation =
            HeaderInformation(dayOfWeek: dayOfWeek,
                              date: date,
                              fromStation: fromStation,
                              toStation: toStation)
        trainSelectionVC.dateOffset = dateOffset
        trainSelectionVC.timeOffset = timeOffset
        trainSelectionVC.traintype = traintypes[trainTypeControl.selectedIndex]
        trainSelectionVC.mainvc = self
        navigationController?.pushViewController(trainSelectionVC, animated: true)
    }
}

extension ClosedRange where Bound == Date {
    func toString() -> String {
        return "\(lowerBound.timeHour) - \(upperBound.timeHour)"
    }
    
    func addingTimeInterval(_ timeInterval: TimeInterval) -> ClosedRange {
        return lowerBound.addingTimeInterval(timeInterval)...upperBound.addingTimeInterval(timeInterval)
    }
}
