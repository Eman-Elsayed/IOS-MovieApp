//
//  Favorites.swift
//  popularmovies2
//
//  Created by Sayed Abdo on 4/11/18.
//  Copyright © 2018 Bombo. All rights reserved.
//

import UIKit
import CoreData
private let reuseIdentifier = "FavCell"

class FavoritesClass: UICollectionViewController {

    var favorites=[MoviesClass]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewWillAppear(_ animated: Bool) {
        favorites=retrieveFavFromDB()
         self.collectionView?.reloadData()
        print(" \(favorites.count) ")
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let cellsAcross: CGFloat = 3
        let spaceBetweenCells: CGFloat = 1
        let dim = (collectionView.bounds.width - (cellsAcross - 1 ) * spaceBetweenCells) / cellsAcross
        return CGSize(width: dim, height: dim)
    }
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        print("inside n of sections")
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        print("inside n of cells")
        return favorites.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath)
        print("inside cells")
        let l=cell.viewWithTag(2) as! UIImageView
        l.sd_setImage(with: URL.init(string: "http://image.tmdb.org/t/p/w185"+favorites[indexPath.row].poster)) {(uiimage, error, CacheType, url) in
            print("favorites image cell completed")
        }
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let dObj: Details = (self.storyboard?.instantiateViewController(withIdentifier: "Details"))! as! Details
        dObj.movie=favorites[indexPath.row]
        navigationController?.pushViewController(dObj , animated: true)
    }

    

}
extension FavoritesClass{
    
    //retrive favorite from db
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
        //to Wrapp the [nsmanagedobject] to "MovieClass"
        return retriveFavFromDBWrapper(arr: dbmovies)
    }
    
    
    //function to wrapp th nsmanagedobject to movieclass
    func retriveFavFromDBWrapper(arr : [NSManagedObject])->[MoviesClass]{
        var WrappedMovies=[MoviesClass]()
        if arr.count==0{
            let alert = UIAlertController(title: "No Favorites Found", message: "you didn't select favorites movies before", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler:{ action in
                print("no fav clicked")
            }))
            self.present(alert, animated: true)
        }else{
            print("the number of elements in object array \(arr.count)")
            for i in arr{
                let mytrailers : [TrailerClass] = Array<TrailerClass>()
                let myreviews : [ReviewClass] = Array<ReviewClass>()
                
                let movieobj=MoviesClass(_id: i.value(forKey: "mid") as! Int, _title: String.init(describing: i.value(forKey: "mtitle")!), _poster: String.init(describing: i.value(forKey: "mposter")!), _release: String.init(describing: i.value(forKey: "mrelease")!), _overview: String.init(describing: i.value(forKey: "moverview")!), _vote: i.value(forKey: "mvote") as! Double , _trailers: mytrailers, _reviews: myreviews)
                WrappedMovies.append(movieobj)
            }
        }
        return WrappedMovies
    }
    
}
