//
//  TrainSelectionViewController.swift
//  Shinkansen 3D Seat Booking Prototype
//
//  Created by Virakri Jinangkul on 5/14/19.
//  Copyright © 2019 Virakri Jinangkul. All rights reserved.
//

import UIKit
import Kumi

class TrainSelectionViewController: BookingViewController {
    
    var traintype = "自強號"
    
    var didFirstLoad: Bool = false
    
    var selectedIndexPath: IndexPath?
    
    var loadingActivityIndicatorView: UIActivityIndicatorView!
    
    var trainCriteria: TrainCriteria? {
        didSet {
            let now = Date()
            trainSchedules = (trainCriteria?.trainSchedules ?? []).filter {
                let component = Calendar.current.dateComponents(in: Date.JPCalendar.timeZone, from: $0.fromTime)
                let date = Date(byHourOf: component.hour, minute: component.minute, second: component.second).addingTimeInterval(dateOffset + timeOffset)
                return now < date
            }
            mainTableView.reloadData()
        }
    }
    
    private var trainSchedules: [TrainSchedule] = []
    
    var dateOffset: TimeInterval = 0
    
    var timeOffset: TimeInterval = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        //selectTraintype()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if !didFirstLoad {
            
            TrainCriteria.fetchData { [weak self] result in
                if case .success(let trainCriteria) = result {
                    DispatchQueue.main.async {
                        [weak self] in
                        self?.trainCriteria = trainCriteria
     
                        self?.mainTableView.visibleCells.enumerated().forEach { (index, cell) in
                            guard let cell = cell as? TrainScheduleTableViewCell else { return }
                            cell.preparePropertiesForAnimation()
                            cell.transform.ty = 24 * CGFloat(index)
                            var animationStyle = UIViewAnimationStyle.transitionAnimationStyle
                            animationStyle.duration = 0.05 * TimeInterval(index) + 0.5
                            UIView.animate(withStyle: animationStyle, animations: {
                                cell.setPropertiesToIdentity()
                                cell.transform.ty = 0
                            })
                        }
                        self?.didFirstLoad = true
                        self?.mainTableView.isUserInteractionEnabled = true
                        self?.loadingActivityIndicatorView.stopAnimating()
                        
                        /// Check if there is no result
                        if self?.mainTableView.visibleCells.count == 0 {
                            let label = Label()
                            label.numberOfLines = 0
                            label.text = "No train scheduled in the time range you selected"
                            label.textStyle = textStyle.caption1()
                            label.textColor = currentColorTheme.componentColor.secondaryText
                            label.textAlignment = .center
                            self?.mainTableView
                                .addSubview(label,
                                            withConstaintEquals: [.center, .trailingMargin, .leadingMargin],
                                            insetsConstant: .init(bottom: 24))
                        }
                    }
                    
                    
                    
                }
            }
            
            //selectTraintype()
        }
        
        
    }
    
    override func setupView() {
        super.setupView()
        loadingActivityIndicatorView = UIActivityIndicatorView(style: .whiteLarge)
        loadingActivityIndicatorView.color = currentColorTheme.componentColor.secondaryText
        loadingActivityIndicatorView.startAnimating()
        mainViewType = .tableView
        mainTableView.isUserInteractionEnabled = false
        mainTableView.addSubview(loadingActivityIndicatorView,
                                 withConstaintEquals: .centerSafeArea)
    }
    
    override func setupInteraction() {
        super.setupInteraction()
        
        backButton.addTarget(self,
                             action: #selector(backButtonDidTouch(_:)),
                             for: .touchUpInside)
    }
    
    private func setupTableView() {
        mainTableView.dataSource = self
        mainTableView.delegate = self
        mainTableView.register(TrainScheduleTableViewCell.self, forCellReuseIdentifier: "TrainScheduleTableViewCell")
    }
    
    var mainvc: BookingCriteriaViewController?
    @objc func backButtonDidTouch(_ sender: Button) {
        mainvc?.trainTypeContainerView.isHidden = false
        navigationController?.popViewController(animated: true)
    }
}

extension TrainSelectionViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        selectTraintype()
        return trainSchedules.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "TrainScheduleTableViewCell",
                                                       for: indexPath) as? TrainScheduleTableViewCell else { return UITableViewCell() }
         
        //selectTraintype()
        let trainSchedule = trainSchedules[indexPath.row]
        
        let granClassObject = trainSchedule.seatClasses.first(where: {
            $0.seatClass == .granClass
        })
        
        let greenObject = trainSchedule.seatClasses.first(where: {
            $0.seatClass == .green
        })
        
        let ordinaryObject = trainSchedule.seatClasses.first(where: {
            $0.seatClass == .ordinary
        })
        
        let availableObjects = [granClassObject, greenObject, ordinaryObject].compactMap({$0})
        let cheapestPrice = availableObjects.sorted(by: { (classL, classR) -> Bool in
            return classL.price < classR.price
        }).first?.price
        
        // MARK: Offset of time is only for a sake of mock data
        let fromTimeString = trainSchedule.fromTime.addingTimeInterval(timeOffset).time
        let toTimeString = trainSchedule.toTime.addingTimeInterval(timeOffset).time
        cell.setupValue(time: "\(fromTimeString) – \(toTimeString)",
            amountOfTime: trainSchedule.toTime.offset(from: trainSchedule.fromTime),
            trainNumber: trainSchedule.trainNumber,
            trainName: trainSchedule.trainName,
            showGranClassIcon: granClassObject != nil,
            isGranClassAvailable: granClassObject?.isAvailable ?? false,
            showGreenIcon: greenObject != nil,
            isGreenAvailable: greenObject?.isAvailable ?? false,
            showOrdinaryIcon: ordinaryObject != nil,
            isOrdinaryAvailable: ordinaryObject?.isAvailable ?? false,
            price: "from \((cheapestPrice ?? 50)/50 ?? 0)",
            trainImage: UIImage(named: trainSchedule.trainImageName))
        
        cell.contentView.alpha = didFirstLoad ? 1 : 0
        //self.traintype
//        let sessionId = "this is a test"
//        let index = sessionId.index(sessionId.startIndex, offsetBy: 2)
//        let prefix = sessionId.substring(to: index)
        

        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //
        selectedIndexPath = indexPath
        let trainSchedule = trainSchedules[indexPath.row]
        
        let seatClasses = trainSchedule.seatClasses
        let seatClassSelectionVC = SeatClassSelectionViewController()
        seatClassSelectionVC.seatClasses = seatClasses
        seatClassSelectionVC.trainImage = UIImage(named: trainSchedule.trainImageName)
        seatClassSelectionVC.headerInformation = headerInformation
        seatClassSelectionVC.headerInformation?.fromTime = trainSchedule.fromTime.addingTimeInterval(timeOffset).time
        seatClassSelectionVC.headerInformation?.toTime = trainSchedule.toTime.addingTimeInterval(timeOffset).time
        seatClassSelectionVC.headerInformation?.trainNumber = trainSchedule.trainNumber
        seatClassSelectionVC.headerInformation?.trainName = trainSchedule.trainName
        
        
        seatClassSelectionVC.thistrainSchedule = trainSchedule
        navigationController?.pushViewController(seatClassSelectionVC, animated: true)
        
        
        
    }
    
    
    func selectTraintype(){
        var unremovelist = [Int]()
        var buffer:[TrainSchedule] = []
        if(self.trainSchedules.count>=1){
            print("first")
            for i in 0...(self.trainSchedules.count-1){
                let x = self.trainSchedules[i].trainNumber
                     let y = self.traintype
                     let index = x.index(x.startIndex , offsetBy: 1)
                     let index2 = y.index(y.startIndex, offsetBy: 1)
                     let a = x.substring(to: index)
                     let b = y.substring(to: index2)
                  
                     if( a == b){
//                        print(x)
//                          print(y)
//                          print(a)
//                          print(b)
//                        print("equal")
                        unremovelist.append(i)
                        //print(self.trainSchedules[i].trainNumber)
                        buffer.append(self.trainSchedules[i])
                        //self.trainSchedules[i].id = -1
                         //cell.removeFromSuperview()
                     }
                 
                 }
        }
//        print(unremovelist.count)
//        print(self.trainSchedules.count)
//        print(unremovelist)
        
//        if(unremovelist.count>=1){
//            for i in 0...(unremovelist.count-1){
//                print(self.trainSchedules[i].trainNumber)
//                buffer.append(self.trainSchedules[i])
//                //print(self.trainSchedules[i])
//                //self.trainSchedules.remove(at: i)
//            }
//        }
        self.trainSchedules = buffer
  
    }
}
