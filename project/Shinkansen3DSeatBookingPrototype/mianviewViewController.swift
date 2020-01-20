//
//  mianviewViewController.swift
//  Shinkansen3DSeatBookingPrototype
//
//  Created by shawn on 2019/12/23.
//  Copyright © 2019 Virakri Jinangkul. All rights reserved.
//

import UIKit

class mianviewViewController: UIViewController {

     var mainCallToActionButton: Button!
    override func viewDidLoad() {
        super.viewDidLoad()
    
       self.view.backgroundColor = UIColor(patternImage: UIImage(named: "background")!)
 
        let myLabel = UILabel(frame: CGRect(x: 20, y: 50, width: UIScreen.main.bounds.width-40, height: 80))
        myLabel.font = UIFont(name: "Helvetica-Light", size: 44)
        myLabel.text = "台鐵訂票系統"
        // 可以再修改文字的大小
        myLabel.font = myLabel.font.withSize(44)

        // 或是可以使用系統預設字型 並設定文字大小
        myLabel.font = UIFont.systemFont(ofSize: 36)

        // 設定文字位置 置左、置中或置右等等
        myLabel.textAlignment = NSTextAlignment.right

        // 也可以簡寫成這樣
        myLabel.textAlignment = .center

        // 文字行數
        myLabel.numberOfLines = 1

        // 文字過多時 過濾的方式
        myLabel.lineBreakMode = NSLineBreakMode.byTruncatingTail

        // 陰影的顏色 如不設定則預設為沒有陰影
        myLabel.shadowColor = UIColor.orange

        // 陰影的偏移量 需先設定陰影的顏色
        myLabel.shadowOffset = CGSize(width: 2, height: 2)
        
        // 可以單獨設置新的 x 或 y
        myLabel.bounds.origin.x = 50
        myLabel.bounds.origin.y = 100
        // 或是使用 CGPoint(x:,y:) 設置新的原點
        myLabel.bounds.origin = CGPoint(x: 60, y: 120)

        // 可以單獨設置新的 width 或 height
        myLabel.bounds.size.width = 200
        myLabel.bounds.size.height = 100
        // 或是使用 CGSize(width:,height:) 設置新的尺寸
        myLabel.bounds.size = CGSize(width: 250, height: 80)

        // 或是也可以一起設置新的原點及尺寸
        myLabel.bounds = CGRect(
          x: 60, y: 120, width: 250, height: 80)


        // 取得螢幕的尺寸
        let fullScreenSize = UIScreen.main.bounds.size

        // 設置於畫面的中心點
        myLabel.center = CGPoint(
          x: fullScreenSize.width * 0.5,
          y: fullScreenSize.height * 0.3)

        // UILabel 的背景顏色
        //myLabel.backgroundColor = UIColor.orange

        // 加入到畫面中
        self.view.addSubview(myLabel)
        
        
        
        
        
        let button = UIButton(frame: CGRect(x: 40, y: 400, width: UIScreen.main.bounds.width-80, height: 50))
        button.backgroundColor = .gray
        button.setTitle("booking now", for: .normal)

        
        button.layer.cornerRadius = 10.0

        button.addTarget(self, action: #selector(buttonAction), for: .touchUpInside)
    
        self.view.addSubview(button)
        
        let button2 = UIButton(frame: CGRect(x: 40, y: 500, width: UIScreen.main.bounds.width-80, height: 50))
            button2.backgroundColor = .gray
            button2.setTitle("Booking record", for: .normal)

            
            button2.layer.cornerRadius = 10.0

            button2.addTarget(self, action: #selector(buttonAction2), for: .touchUpInside)
        
            self.view.addSubview(button2)
        
    }
    
    @objc func buttonAction(){
   let presentedViewController = NavigationController(rootViewController: BookingCriteriaViewController())
              presentedViewController.modalPresentationStyle = .fullScreen
              //presentedViewController.transitioningDelegate = self
              
              present(presentedViewController, animated: true, completion: nil)


    }
    
     @objc func buttonAction2(){
        let viewController = UIStoryboard(name: "Storyboard", bundle: nil)
        .instantiateViewController(withIdentifier: "WelcomeView") as UIViewController


        present(viewController, animated: true, completion: nil)
        
        
     }


}
