//
//  SeatClassSelectionViewController.swift
//  Shinkansen 3D Seat Booking Prototype
//
//  Created by Virakri Jinangkul on 5/14/19.
//  Copyright © 2019 Virakri Jinangkul. All rights reserved.
//

import UIKit

class SeatClassSelectionViewController: BookingViewController {
    
    var thistrainSchedule:TrainSchedule?
    
    var trainImage: UIImage?
    
    var trainImageView: UIImageView!
    
    var selectedIndexPath: IndexPath?
    
    var seatClasses: [SeatClass] = []
    
    var seatMap: SeatMap?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        setupStaticContent()
        obtainData()
    }
    
    override func setupView() {
        super.setupView()
        mainViewType = .tableView
        
        headerRouteInformationView
            .descriptionSetView.addArrangedSubview(UIView())
        
        trainImageView = UIImageView()
        
        headerRouteInformationView
            .descriptionSetView
            .addSubview(trainImageView)
        
        trainImageView
            .translatesAutoresizingMaskIntoConstraints = false
        
        trainImageView
            .leadingAnchor
            .constraint(
                greaterThanOrEqualTo:
                headerRouteInformationView
                    .descriptionSetView
                    .trainNumberSetView
                    .trailingAnchor,
                constant: 48)
            .isActive = true
        
        let trainImageViewTrailingConstraint =
        trainImageView
            .trailingAnchor
            .constraint(
                equalTo:
                headerRouteInformationView.trailingAnchor)
        
        trainImageViewTrailingConstraint.priority = .defaultLow
        trainImageViewTrailingConstraint.isActive = true
        
        trainImageView
            .topAnchor
            .constraint(
                equalTo: headerRouteInformationView
                    .stationPairView
                    .bottomAnchor,
                constant: 12)
            .isActive = true
        
        headerRouteInformationView
            .descriptionSetView
            .bottomAnchor
            .constraint(
                equalTo: trainImageView.bottomAnchor)
            .isActive = true
        
        trainImageView.widthAnchor.constraint(equalTo: trainImageView.heightAnchor, multiplier: 6).isActive = true
        trainImageView
            .setContentCompressionResistancePriority(
                .init(rawValue: 249), for: .vertical)
        trainImageView
            .setContentCompressionResistancePriority(
                .init(rawValue: 249), for: .horizontal)
        
    }
    
    weak var seatMapSelectionVC: SeatMapSelectionViewController?
    
    func obtainData() {
        SeatMap.fetchData { [weak self] result in
            if case .success(let seatMap) = result {
                DispatchQueue.main.async {
                    self?.seatMap = seatMap
                    if let vc = self?.seatMapSelectionVC,
                        let indexPath = self?.mainTableView?.indexPathForSelectedRow,
                        let seatClass = self?.seatClasses[indexPath.row],
                        let selectedEntity = seatMap.seatClassEntities.first(where: {
                            $0.seatClass == seatClass.seatClass
                        }){
                        vc.seatClass = seatClass
                        vc.seatClassEntity = selectedEntity
                        vc.seatMap = seatMap
                    }
                }
            }
        }
        
        
        let decoder = JSONDecoder()
        if let data = NSDataAsset(name: "ModelData")?.data,
            let modelData = try? decoder.decode([ModelData].self, from: data) {
                NodeFactory.shared =
                    NodeFactory(modelData: modelData)
        }else{
            fatalError("There is some errors of trying to phrase JSON, so please check ModelData.json in Assets.xcassets")
        }
    }

    func setupStaticContent() {
        trainImageView.image = trainImage
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
        mainTableView.register(SeatClassTableViewCell.self, forCellReuseIdentifier: "SeatClassTableViewCell")
    }
    
    
    @objc func backButtonDidTouch(_ sender: Button) {
        
        //trainTypeContainerView.isHidden = false
        navigationController?.popViewController(animated: true)
    }
}

extension SeatClassSelectionViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return seatClasses.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "SeatClassTableViewCell",
                                                       for: indexPath) as? SeatClassTableViewCell else { return UITableViewCell() }
        let seatClass = seatClasses[indexPath.row]
        
        cell.setupValue(seatClassType: seatClass.seatClass,
                        seatClassName: seatClass.seatClass.name,
                        price: "\(seatClass.price/50)",
                        description: seatClass.description,
                        seatImage: seatClass.seatClass.image())
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        guard !(navigationController?.viewControllers.last is SeatMapSelectionViewController?) else {
            return print("Seat map is loading please wait")
        }
        
        //
        selectedIndexPath = indexPath
        
        let seatClass = seatClasses[indexPath.row]
        
        let selectedEntity = seatMap?.seatClassEntities.first(where: {
            $0.seatClass == seatClass.seatClass
        })
        
        let seatMapSelectionVC = SeatMapSelectionViewController()
        seatMapSelectionVC.seatClass = seatClass
        seatMapSelectionVC.seatClassEntity = selectedEntity
        seatMapSelectionVC.seatMap = seatMap
        seatMapSelectionVC.headerInformation = headerInformation
        seatMapSelectionVC.headerInformation?.carNumber = selectedEntity?.carNumber
        seatMapSelectionVC.headerInformation?.className = seatClass.name
        seatMapSelectionVC.headerInformation?.price = "\(seatClass.price/50)"
        if seatMap == nil {
            self.seatMapSelectionVC = seatMapSelectionVC
        }
        seatMapSelectionVC.thistrainSchedule = thistrainSchedule
        
        navigationController?.pushViewController(seatMapSelectionVC, animated: true)
    }
    
}
