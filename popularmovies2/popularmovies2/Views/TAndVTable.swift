//
//  TAndVTable.swift
//  popularmovies2
//
//  Created by Sayed Abdo on 4/6/18.
//  Copyright © 2018 Bombo. All rights reserved.
//

import Foundation
import SDWebImage
import Alamofire
class TAndVTable : UIViewController , UITableViewDelegate , UITableViewDataSource {
    
    var movie2 : MoviesClass = MoviesClass(_id: 2, _title: "", _poster: "", _release: "", _overview: "", _vote: 2.2 , _trailers : [TrailerClass]() , _reviews : [ReviewClass]())
    
    var tr : [TrailerClass] = [TrailerClass]()
    var rev : [ReviewClass] = [ReviewClass]()
    var nrows : Int = 0

    func numberOfSections(in tableView: UITableView) -> Int {
        if tr.count == 0
        {
           tr = movie2.traillers
           rev = movie2.reviews
        }
                    return 2
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0 :
            nrows=tr.count
        case 1 :
            nrows=rev.count
        default:
            print(section)
        }
        return nrows
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "tvcell", for: indexPath)
        
        switch indexPath.section {
        case 0:
            let lt : UILabel = cell.viewWithTag(5) as! UILabel
            lt.text = tr[indexPath.row].title
        case 1:
            let lv : UILabel = cell.viewWithTag(5) as! UILabel
            lv.text = rev[indexPath.row].auther
        default:
            print("default case ")
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.section {
        case 0 :
            if isConnectedToInternet(){
                getVedio(key: tr[indexPath.row].key)
            }else{
                showAlerts(mess:"please connect to internet ", tit: "no internet connection")
            }
        case 1 :
            if isConnectedToInternet(){
                showAlerts(mess: rev[indexPath.row].content, tit: rev[indexPath.row].auther + "Review")
            }else{
                showAlerts(mess:"please connect to internet ", tit: "no internet connection")
            }
        default:
          print("default did select row")
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0 :
            return "Trailers"
        case 1 :
            return "Reviews"
        default:
            return "default"
        }
    }
    

    
}


//internet connection extention
extension TAndVTable{
    
    //function to check reachability
    func isConnectedToInternet() ->Bool {
        return NetworkReachabilityManager()!.isReachable
    }
    
    //getvedio from youtube
    func getVedio(key : String){
    var url = NSURL(string:"youtube://\(key)")!
    if UIApplication.shared.canOpenURL(url as URL)  {
        UIApplication.shared.openURL(url as URL)
    }else{
        url = NSURL(string:"http://www.youtube.com/watch?v=\(key)")!
        UIApplication.shared.openURL(url as URL)
        }
        
    }
    

    //showalert
    func showAlerts( mess : String , tit : String){
        let alert = UIAlertController(title: tit, message: mess, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler:{ action in
            print(" \(mess) ")
            
        }))
        UIApplication.shared.keyWindow?.rootViewController?.present(alert, animated: true, completion: nil)
    }
}



