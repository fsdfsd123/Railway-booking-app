//
//  UITableView.swift
//  Shinkansen 3D Seat Booking Prototype
//
//  Created by Virakri Jinangkul on 6/1/19.
//  Copyright © 2019 Virakri Jinangkul. All rights reserved.
//

import UIKit

extension UITableView {
    func setupTheme() {
        visibleCells.forEach { (cell) in
            if let cell = cell as? TrainScheduleTableViewCell {
                cell.setupTheme()
            }
            
            if let cell = cell as? SeatClassTableViewCell {
                cell.setupTheme()
            }
        }
    }
}
