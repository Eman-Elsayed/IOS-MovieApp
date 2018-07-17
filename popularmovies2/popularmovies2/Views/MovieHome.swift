//
//  MoviesHome.swift
//  PopularMoviesIOS
//
//  Created by Sayed Abdo on 4/1/18.
//  Copyright © 2018 Bombo. All rights reserved.
//

import UIKit
import CoreData
import Alamofire
import SDWebImage
import Dropdowns
private let reuseIdentifier = "Cell"

class MoviesHome: UICollectionViewController , UICollectionViewDelegateFlowLayout{
    
    var movies=[MoviesClass]()
    @IBOutlet var collayout: UICollectionView!
    override func viewDidLoad() {
        super.viewDidLoad()
        if isConnectedToInternet() {
            drawDropDownList()
            getMoviesFromInternet(sort: "now_playing")
        }else{
            movies = retrieveFromDB()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        print("in wil appear ")
         NotificationCenter.default.addObserver(self, selector:#selector(self.viewDidLoad), name: NSNotification.Name.UIApplicationWillEnterForeground, object: UIApplication.shared)
        
    }
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self)
    }
    
    func drawDropDownList(){
        let items = ["Now Playing", "Top Rated", "Most popular"]
        let titleView = TitleView(navigationController: navigationController!, title: "Now playing", items: items)
        titleView?.action = { [weak self] index in
            print("select \(index)")
            switch (index) {
            case 0:
                self?.getMoviesFromInternet(sort: "now_playing")
            case 1:
                self?.getMoviesFromInternet(sort: "top_rated")
            case 2:
                self?.getMoviesFromInternet(sort: "popular")
            default:
                print("default index ")
            }
        }
//        Config.List.DefaultCell.Text.color = UIColor.red
        navigationItem.titleView = titleView
    }
  
    
    // MARK: UICollectionViewDataSource
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
   
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let cellsAcross: CGFloat = 3
        let spaceBetweenCells: CGFloat = 1
        let dim = (collectionView.bounds.width - (cellsAcross - 1 ) * spaceBetweenCells) / cellsAcross
        return CGSize(width: dim, height: dim)
        
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return movies.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath)
        // Configure the cell
        let l=cell.viewWithTag(1) as! UIImageView
        l.sd_setImage(with: URL.init(string: "http://image.tmdb.org/t/p/w185"+movies[indexPath.row].poster)) {(uiimage, error, CacheType, url) in
            print("sd completed")
        }
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let dObj: Details = (self.storyboard?.instantiateViewController(withIdentifier: "Details"))! as! Details
        dObj.movie=movies[indexPath.row]
        navigationController?.pushViewController(dObj , animated: true)
    }
    
}

//coredata extension
extension MoviesHome {
    
    //function to save to DB
    func saveToDB(m : MoviesClass ) {
        print("from save to db movie is \(m.title)")
        //1
        let appdelegegat=UIApplication.shared.delegate as! AppDelegate
        //2
        let context=appdelegegat.persistentContainer.viewContext
        //3
        let movieEntity=NSEntityDescription.entity(forEntityName: "Movies", in: context)
//        let trailerEntity=NSEntityDescription.entity(forEntityName: "Trailers", in: context)
//        let reviewEntity=NSEntityDescription.entity(forEntityName: "Reviews", in: context)
        //4
        let movie=NSManagedObject(entity: movieEntity!, insertInto: context )
        movie.setValue(m.title , forKey: "mtitle")
        movie.setValue(m.id , forKey: "mid")
        movie.setValue(m.vote , forKey: "mvote")
        movie.setValue(m.poster , forKey: "mposter")
        movie.setValue(m.release , forKey: "mrelease")
        movie.setValue(m.overview , forKey: "moverview")
        print("teest \(m.traillers.count) ")
//        for i in m.traillers{
//            let trailer : NSManagedObject = NSManagedObject(entity: trailerEntity!, insertInto: context )
//            trailer.setValue(i.key , forKey: "tkey")
//            trailer.setValue(i.title , forKey: "ttitle")
//            trailer.setValue(movie , forKey: "movie")
//            print("\t trailer is \(i.title)")
//        }
//        for i in m.reviews{
//            let rev : NSManagedObject = NSManagedObject(entity: reviewEntity!, insertInto: context )
//            rev.setValue(i.auther , forKey: "rauther")
//            rev.setValue(i.content , forKey: "rcontent")
//            rev.setValue(movie , forKey: "movie")
//            print("\t Review is \(i.auther)")
//        }
        do{
            //5
            try context.save()
        }catch let err{
            print(err)
        }
        
    }
    
    //function to retrieve all movies from DB
    func retrieveFromDB()->[MoviesClass]{
        var dbmovies = [NSManagedObject]()
        //1
        let appdelegegat=UIApplication.shared.delegate as! AppDelegate
        //2
        let context=appdelegegat.persistentContainer.viewContext
        //3
        let fetchreq=NSFetchRequest<NSFetchRequestResult>(entityName: "Movies")
        do{
            dbmovies = try context.fetch(fetchreq) as! [NSManagedObject]
        }catch{
            
        }
        print("in fetch \(dbmovies.count)")
        //to Wrapp the [nsmanagedobject] to "MovieClass"
        return retriveFromDBWrapper(arr: dbmovies)
    }
    
    
    //function to wrapp th nsmanagedobject to movieclass
    func retriveFromDBWrapper(arr : [NSManagedObject])->[MoviesClass]{
         var WrappedMovies=[MoviesClass]()
        if arr.count==0{
            let alert = UIAlertController(title: "No internet connection", message: "please open internet to load data ", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler:{ action in
                print("clicked")
                if let url = URL(string:"App-Prefs:root=Network&path=Location") {
                    if UIApplication.shared.canOpenURL(url) {
                        _ =  UIApplication.shared.open(url, options: [:], completionHandler: nil)
                    }
                }
                
            }))
            alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler:{ action in
                print("clicked")
                UIControl().sendAction(#selector(URLSessionTask.suspend), to: UIApplication.shared, for: nil)
                // terminaing app in background
                DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1), execute: {
                    exit(EXIT_SUCCESS)
                })
            }))
            self.present(alert, animated: true)
        }else{
            print("the number of elements in object array \(arr.count)")
            for i in arr{
                let mytrailers : [TrailerClass] = Array<TrailerClass>()
                let myreviews : [ReviewClass] = Array<ReviewClass>()
                //            let g : NSSet=(i.value(forKey: "gen")! as AnyObject).valueForKey("name")! as! NSSet
                //
                //            for it in g {
                //                gens.append(it as! String)
                //            }
                
                //fetch trailers
                //            let tits : NSSet=(i.value(forKey: "trailers")! as AnyObject).value(forKey: "ttitle")! as! NSSet
                //            let tkeys : NSSet=(i.value(forKey: "trailers")! as AnyObject).value(forKey: "tkey")! as! NSSet
                
                //            for x in 1...tits.allObjects.count-1 {
                //                var Trailerobj : TrailerClass=TrailerClass(_key: tkeys.allObjects[x] as! String , _title: tits.allObjects[x] as! String)
                //                mytrailers.append(Trailerobj)
                //            }
                // fetch reviews
                //            let revauthers : NSSet=(i.value(forKey: "reviews")! as AnyObject).value(forKey: "rauther")! as! NSSet
                //            let revcontents : NSSet=(i.value(forKey: "reviews")! as AnyObject).value(forKey: "rcontent")! as! NSSet
                //            for x2 in 1...revauthers.allObjects.count-1 {
                //                var ReviewObj : ReviewClass=ReviewClass(_auther:  revauthers.allObjects[x2] as! String , _content: revcontents.allObjects[x2] as! String)
                //                myreviews.append(ReviewObj)
                //            }
                
                let movieobj=MoviesClass(_id: i.value(forKey: "mid") as! Int, _title: String.init(describing: i.value(forKey: "mtitle")!), _poster: String.init(describing: i.value(forKey: "mposter")!), _release: String.init(describing: i.value(forKey: "mrelease")!), _overview: String.init(describing: i.value(forKey: "moverview")!), _vote: i.value(forKey: "mvote") as! Double , _trailers: mytrailers, _reviews: myreviews)
                
                WrappedMovies.append(movieobj)
            }
        }
        return WrappedMovies
    }
    
    // MARK: Delete Records
    func deleteRecords() -> Void {
        let moc = getContext()
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Movies")
        
        let result = try? moc.fetch(fetchRequest)
        let resultData = result as! [NSManagedObject]
        
        for object in resultData {
            moc.delete(object)
        }
        
        do {
            try moc.save()
            print("deleted")
        } catch let error as NSError  {
            print("Could not save \(error), \(error.userInfo)")
        } catch {
            
        }
        
    }
    
    // MARK: Get Context
    func getContext () -> NSManagedObjectContext {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        return appDelegate.persistentContainer.viewContext
    }
}


//network extention
extension MoviesHome{
    
    //function to check reachability
    func isConnectedToInternet() ->Bool {
        return NetworkReachabilityManager()!.isReachable
    }
    
    //creates connection and get movies from yrl
    func getMoviesFromInternet(sort:String ) {
        //delete from db
        self.deleteRecords()
        //delete movies array  for update
        self.movies.removeAll()
        let url  = URL(string: "https://api.themoviedb.org/3/movie/"+sort+"?api_key=e91adf11b0c3432f05f5eaa001035bb9&language=en-US&page=1")!
        let request = NSURLRequest(url: url)
        let session = URLSession(configuration: URLSessionConfiguration.default)
        let task = session.dataTask(with: request as URLRequest) { (data, response, error) in
            do{
                
                let res = try JSONSerialization.jsonObject(with: data!, options: .allowFragments) as! Dictionary<String,Any>
    
                for dic in res["results"] as! [Dictionary<String,Any>]{
                    let m=MoviesClass(_id: dic["id"] as! Int, _title: dic["title"] as! String, _poster: dic["poster_path"] as! String, _release: dic["release_date"] as! String, _overview: dic["overview"] as! String, _vote: dic["vote_average"] as! Double , _trailers : [TrailerClass](), _reviews : [ReviewClass]())
                    self.movies.append(m)
                    
                    //save into DB
                    DispatchQueue.main.async {
                        self.saveToDB(m: m)
                                      }
                    print("after save \(m.title) size \(self.movies.count) " )
                    
                }
                DispatchQueue.main.async {
                    self.collectionView?.reloadData()
                }
            }catch let er{
                print("\(er)")
            }
        }
        task.resume()
    }
}

