//
//  Player.swift
//  laser tag
//
//  Created by Aarush Bothra on 7/24/20.
//  Copyright © 2020 Aarush Bothra. All rights reserved.
//

import Foundation

class Player{
    var username:String
    var team:Int
    var gunType:Int
    var gunID:Int
    var isSelf: Bool
    var kills = 0
    var deaths = 0
    var score = 0
    
    var shield = 0
    var health = 100
    var totalAmmo = Game.ammo
    var ammoInGun: Int!
    
    init(username: String, team: Int, gunType: Int, gunID: Int, isSelf: Bool, kills: Int, deaths: Int, score: Int) {
        print("player created")
        self.username = username
        self.team = team
        self.gunType = gunType
        self.gunID = gunID
        self.isSelf = isSelf
        self.kills = kills
        self.deaths = deaths
        self.score = score
    }
    
    
    
}
