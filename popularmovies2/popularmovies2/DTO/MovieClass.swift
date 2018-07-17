//
//  MovieClass.swift
//  PopularMoviesIOS
//
//  Created by Sayed Abdo on 4/2/18.
//  Copyright © 2018 Bombo. All rights reserved.
//

import Foundation

class MoviesClass {
    
    var id : Int
    var title : String
    var poster : String
    var release : String
    var overview : String
    var vote : Double
    var traillers : [TrailerClass]
    var reviews : [ReviewClass]
    
    init(_id : Int , _title : String , _poster : String , _release : String , _overview : String ,_vote : Double , _trailers : [TrailerClass] , _reviews : [ReviewClass]) {
        id=_id
        title=_title
        poster=_poster
        release=_release
        overview=_overview
        vote=_vote
        traillers=_trailers
        reviews=_reviews
    }
    
    
}

