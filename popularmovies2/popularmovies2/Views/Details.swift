//
//  ViewController.swift
//  popularmovies2
//
//  Created by Sayed Abdo on 4/3/18.
//  Copyright © 2018 Bombo. All rights reserved.
//

import UIKit
import SDWebImage
import Alamofire
import CoreData
import WCLShineButton
import Cosmos
class Details: UITableViewController {

    @IBOutlet weak var mtitle: UILabel!
    @IBOutlet weak var myear: UILabel!
    @IBOutlet weak var mrate: UILabel!
    @IBOutlet weak var mimg: UIImageView!
    @IBOutlet weak var mdis: UILabel!
   
    @IBOutlet weak var tv: UITableView!
   
    @IBOutlet weak var cellfav: UITableViewCell!
    
  
    @IBOutlet weak var cosmosView: CosmosView!
    
    var movie=MoviesClass(_id: 1, _title: "", _poster: "", _release: "", _overview: "", _vote: 2.2, _trailers: [TrailerClass]() , _reviews: [ReviewClass]() )
    
    var cusTabObj : TAndVTable = TAndVTable()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mtitle.text=movie.title
        myear.text=movie.release
        mrate.text=String.init(movie.vote)
        mdis.text=movie.overview
        tv.delegate=cusTabObj
        tv.dataSource=cusTabObj
        
        mimg.sd_setImage(with: URL.init(string: "http://image.tmdb.org/t/p/w185"+movie.poster)) {(uiimage, error, CacheType, url) in
        }
        if isConnectedToInternet() {
            getMoviesTrailers(mov: movie)
        }else{
            movie.traillers.append(TrailerClass(_key: "default", _title: "please connect to internet "))
            movie.reviews.append(ReviewClass(_auther: "please connect to internet", _content: ""))
            cusTabObj.movie2=self.movie
            tv.reloadData()
        }
        var param1 = WCLShineParams()
        param1.bigShineColor = UIColor(rgb: (255,0,0))
        param1.smallShineColor = UIColor(rgb: (102,102,102))
        
        let bt1 = WCLShineButton(frame: .init(x: 230, y: 120, width: 40, height: 40), params: param1)
        
        if isFav(mov: movie) {
            bt1.fillColor = UIColor(rgb: (255,250,250))
            bt1.color = UIColor(rgb: (250,0,0))
        }else{
            bt1.fillColor = UIColor(rgb: (255,0,0))
            bt1.color = UIColor(rgb: (250,250,250))
        }
        bt1.addTarget(self, action: #selector(favAction), for: .valueChanged)
        cellfav.addSubview(bt1)
        cosmosView.rating=movie.vote/2
        cosmosView.settings.fillMode = .half
        cosmosView.settings.updateOnTouch = false
    }
    
    @objc func favAction(){
        if isFav(mov: movie) {
            print("======this is favorite movie deleted")
            deleteFav(m: movie)
        }else{
          saveFavToDB(m: movie)
        }
    }
}

extension Details{
    
    //function to check reachability
    func isConnectedToInternet() ->Bool {
        return NetworkReachabilityManager()!.isReachable
    }
   
    //function to get trailers
    func getMoviesTrailers(mov : MoviesClass)  {
        let url  = URL(string: "https://api.themoviedb.org/3/movie/"+String.init(mov.id)+"/videos?api_key=e91adf11b0c3432f05f5eaa001035bb9&language=en-US" )!
        let request = NSURLRequest(url: url)
        let session = URLSession(configuration: URLSessionConfiguration.default)
        let task = session.dataTask(with: request as URLRequest) { (data, response, error) in
            do{
                let res = try JSONSerialization.jsonObject(with: data!, options: .allowFragments) as! Dictionary<String,Any>
                for dic in res["results"] as! [Dictionary<String,Any>]{
                    let trailer=TrailerClass(_key: dic["key"] as! String , _title: dic["name"] as! String)
                    mov.traillers.append(trailer)
                    print("movie  \(mov.title) ")
                    print(" \t Trailer \(trailer.title)" )
                }
                DispatchQueue.main.async {
                    self.getMoviesReviws(mov: self.movie)
                }
            }catch let er{
                print("\(er)")
            }
            
        }
        task.resume()
        
    }
    //function to get reviews
    func getMoviesReviws(mov : MoviesClass) {
        let url  = URL(string: "https://api.themoviedb.org/3/movie/"+String.init(mov.id)+"/reviews?api_key=e91adf11b0c3432f05f5eaa001035bb9&language=en-US" )!
        let request = NSURLRequest(url: url)
        let session = URLSession(configuration: URLSessionConfiguration.default)
        let task = session.dataTask(with: request as URLRequest) { (data, response, error) in
            do{
                let res = try JSONSerialization.jsonObject(with: data!, options: .allowFragments) as! Dictionary<String,Any>
                for dic in res["results"] as! [Dictionary<String,Any>]{
                    let review=ReviewClass(_auther: dic["author"] as! String, _content: dic["content"] as! String)
                    mov.reviews.append(review)
                    print("movie \(mov.title) ")
                    print(" \t review  \(review.auther)" )
                }
                DispatchQueue.main.async {
                    self.cusTabObj.movie2=self.movie
                    self.tv.reloadData()
                }
            }catch let er{
                print("\(er)")
            } 
        }
        task.resume()
        
    }
}

extension Details{
    
    //save favorites to db
    func saveFavToDB(m : MoviesClass ) {
        print("from save to db movie is \(m.title)")
        //1
        let appdelegegat=UIApplication.shared.delegate as! AppDelegate
        //2
        let context=appdelegegat.persistentContainer.viewContext
        //3
        let favEntity=NSEntityDescription.entity(forEntityName: "Favorites", in: context)
        //4
        let movie=NSManagedObject(entity: favEntity!, insertInto: context )
        movie.setValue(m.title , forKey: "mtitle")
        movie.setValue(m.id , forKey: "mid")
        movie.setValue(m.vote , forKey: "mvote")
        movie.setValue(m.poster , forKey: "mposter")
        movie.setValue(m.release , forKey: "mrelease")
        movie.setValue(m.overview , forKey: "moverview")
        do{
            //5
            try context.save()
            print("fav movie saved")
        }catch let err{
            print(err)
        }
        
    }
    
    //check if movie is favorite
    func isFav(mov : MoviesClass) ->Bool {
        var isfav : Bool=false
        let dbmovies = retrieveFavFromDB()
        for i in dbmovies {
            if i.id == mov.id {
                isfav=true
                print("mov : \(mov.id) and item \(i.id) ")
            }
        }
        return isfav
    }
    
    //retrive favorites from db
    func retrieveFavFromDB()->[MoviesClass]{
        var dbmovies = [NSManagedObject]()
        //1
        let appdelegegat=UIApplication.shared.delegate as! AppDelegate
        //2
        let context=appdelegegat.persistentContainer.viewContext
        //3
        let fetchreq=NSFetchRequest<NSFetchRequestResult>(entityName: "Favorites")
        do{
            dbmovies = try context.fetch(fetchreq) as! [NSManagedObject]
        }catch{
            
        }
        print("in fetch \(dbmovies.count)")
        return retriveFavFromDBWrapper(arr: dbmovies)
    }
    //function to wrapp th nsmanagedobject to movieclass
    func retriveFavFromDBWrapper(arr : [NSManagedObject])->[MoviesClass]{
        var WrappedMovies=[MoviesClass]()
            print("the number of elements in object array \(arr.count)")
            for i in arr{
                let mytrailers : [TrailerClass] = Array<TrailerClass>()
                let myreviews : [ReviewClass] = Array<ReviewClass>()
                
                let movieobj=MoviesClass(_id: i.value(forKey: "mid") as! Int, _title: String.init(describing: i.value(forKey: "mtitle")!), _poster: String.init(describing: i.value(forKey: "mposter")!), _release: String.init(describing: i.value(forKey: "mrelease")!), _overview: String.init(describing: i.value(forKey: "moverview")!), _vote: i.value(forKey: "mvote") as! Double , _trailers: mytrailers, _reviews: myreviews)
                WrappedMovies.append(movieobj)
            }
        return WrappedMovies
    }
    
    
    //delete favorite
    func deleteFav(m : MoviesClass)
    {
        //1
        let appdelegegat=UIApplication.shared.delegate as! AppDelegate
        //2
        let context=appdelegegat.persistentContainer.viewContext
        //3
        let fetchreq=NSFetchRequest<NSFetchRequestResult>(entityName: "Favorites")
        fetchreq.predicate = NSPredicate(format: "mid = %@", "\(m.id)")
        do
        {
            let fetchedResults =  try context.fetch(fetchreq) as? [NSManagedObject]
            for entity in fetchedResults! {
                context.delete(entity)
            }
        }
        catch _ {
            print("Could not delete")
            
        }
    }
}

