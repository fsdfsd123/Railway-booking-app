//
//  SelectView.swift
//  Shinkansen3DSeatBookingPrototype
//
//  Created by shawn on 2019/12/24.
//  Copyright © 2019 Virakri Jinangkul. All rights reserved.
//

import UIKit

class SelectView: UIViewController {

    @IBAction func Booking(_ sender: Any) {

        let vc = BookingCriteriaViewController()
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func Record(_ sender: Any) {
        let vc = MyticketViewcontroller()
        
        self.navigationController?.pushViewController(vc,animated:true)
        
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
