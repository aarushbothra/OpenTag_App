//
//  CollectionViewCellLobby.swift
//  laser tag
//
//  Created by Aarush Bothra on 7/26/20.
//  Copyright © 2020 Aarush Bothra. All rights reserved.
//

import UIKit

class CollectionViewCellLobby: UICollectionViewCell {
    
    @IBOutlet var rosterTV: UITableView!
    @IBOutlet var teamLabel: UILabel!
    
    
    var identifier:String!
    
    var players = [Player]()

    override func awakeFromNib() {
        super.awakeFromNib()        
    }
}

extension CollectionViewCellLobby: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        players.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TVCell")!
        cell.textLabel?.text = players[indexPath.row].username
        return cell
    }
    
    
    
}


