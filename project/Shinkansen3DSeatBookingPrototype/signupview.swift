//
//  signupview.swift
//  Shinkansen3DSeatBookingPrototype
//
//  Created by shawn on 2019/12/24.
//  Copyright © 2019 Virakri Jinangkul. All rights reserved.
//

import UIKit
import Firebase
 import FirebaseDatabase
//struct HeadInfo:Codable {
//    var dayOfWeek:String = ""
//    var date:String = ""
//    var fromStation:String = ""
//    var toStation:String = ""
//}
struct Ticket:Convertable{
    var Train:TrainSchedule?
    var seat:SeatClassEntity?
    var head:HeaderInformation?

}
protocol Convertable: Codable {

}
extension Convertable {

    /// 直接将Struct或Class转成Dictionary
    func convertToDict() -> Dictionary<String, Any>? {

        var dict: Dictionary<String, Any>? = nil

        do {
            print("init student")
            let encoder = JSONEncoder()

            let data = try encoder.encode(self)
            print("struct convert to data")

            dict = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? Dictionary<String, Any>

        } catch {
            print(error)
        }

        return dict
    }
}

var idcard:String = ""
var email:String = ""
var password:String =  ""
var Myticket:[Ticket] = []
struct TotalTicket:Convertable{
    var ticketlist:[Ticket] = []
}

var TotalTicketlist = TotalTicket()

class SignUpViewController: UIViewController {

    @IBOutlet weak var PASSWORD: UITextField!
    @IBOutlet weak var EMAIL: UITextField!
    @IBOutlet weak var ID: UITextField!
    @IBOutlet weak var login: LineButton!
    
    var ref: DatabaseReference! = Database.database().reference()
    
    @IBAction func Userlogin(_ sender: Any) {
        
        
        idcard = ID.text ?? "none"
        email = EMAIL.text ?? "none"
        password = PASSWORD.text ?? "none"
        
        Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
          // ...
        }
        
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] authResult, error in
          guard let strongSelf = self else { return }
          // ...
        }
        
        print("end")
        
        
        
        
        
        
        let userID = Auth.auth().currentUser?.uid
        print("userID: \(userID)")
        ref.child("users").observeSingleEvent(of: .value, with: { (snapshot) in
            if snapshot.hasChild(userID!){
                self.ref.child("users").child(userID!).observeSingleEvent(of: .value, with: { (snapshot) in
                    if snapshot.hasChild("tickets"){
                    self.ref.child("users").child(userID!).child("tickets").observeSingleEvent(of: .value, with: { (snapshot) in
                    // Get user value
                    //let value = snapshot.value as? NSDictionary
                      //Myticket = value?["TICKET"] as? [Ticket] ?? []
                      let dic = snapshot.value as? NSDictionary
                      let data = try! JSONSerialization.data(withJSONObject: dic, options: [])
                      TotalTicketlist = try! JSONDecoder().decode(TotalTicket.self, from: data)
                      Myticket = TotalTicketlist.ticketlist
                      print("Myticket\(Myticket)")
                    //let username = value?["username"] as? String ?? ""r
                    //let user = User(username: username)
                      print("value")
                      print(dic)
                  
                      
                    // ...
                    }) { (error) in
                      print("error")
                      print(error.localizedDescription)
            
                        }
                    }
   
                })
            }
            else{
                   self.ref.child("users").child(userID!).setValue(["IDCARD": idcard])
                   //self.ref.child("users").child(userID!).setValue(["TICKET": Myticket])
                   print("INITIAL")
               }

        })
 
        
        
         let vc = UIStoryboard(name: "Storyboard", bundle: nil)
              .instantiateViewController(withIdentifier: "selectview") as! SelectView
              let presentedViewController = NavigationController(rootViewController: vc)
              presentedViewController.modalPresentationStyle = .fullScreen
            
              
              present(presentedViewController, animated: true, completion: nil)
 
//
//
//        present(viewController, animated: true, completion: nil)
//        let vc = SelectView()
        //self.present(vc, animated: true, completion: nil)
         //self.view.present(vc, animated: true, completion: nil)
        print("fsd")
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
