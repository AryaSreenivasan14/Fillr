//
//  ViewController.swift
//  SpaceGame
//
//  Created by Arya Sreenivasan on 6/4/21.
//

import UIKit
enum ShipTag:Int {
    case player
    case enemy
}

enum BulletTag:Int {
    case playerBullet = 100 //To avoid conflict with ShipTag, started with 100
    case enemyBullet = 101
}

class ViewController: UIViewController {
    
    //MARK:- Outlets
    @IBOutlet weak var startUI: UIView!
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var lifeLabel: UILabel!
    @IBOutlet weak var scoreLabel: UILabel!
    
    //MARK:- Variables
    var displayLink: CADisplayLink?
    var startTime = 0.0
    var player:UIImageView?
    var screenHeight:CGFloat = 0.0
    var scrore:Int = 0


    
    //MARK:- View lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        createPlayer(respawn: false) //First time
    }
    
    //MARK:- Spawn ships
    func createPlayer(respawn:Bool) {
        if ((player) != nil) {
            player = nil
        }
        player = UIImageView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
        if let player = player {
            player.image = #imageLiteral(resourceName: "player_ship")
            player.center = CGPoint(x: UIScreen.main.bounds.size.width/2, y: UIScreen.main.bounds.size.height - 100)
            self.view.addSubview(player)
            
            if (respawn) {
            }
        }
    }
    
    func createEnemy(pos:CGPoint) {
        let enemy = UIImageView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
        enemy.image = #imageLiteral(resourceName: "enemy")
        enemy.center = pos
        enemy.tag = ShipTag.enemy.rawValue
        self.view.addSubview(enemy)
    }
    
    func createBullet(pos:CGPoint, isPlayer:Bool) {
        let bullet = UIImageView(frame: CGRect(x: 0, y: 0, width: 5, height: 30))
        self.view.addSubview(bullet)
        
        if (isPlayer) {
            bullet.image = #imageLiteral(resourceName: "laser_blue")
            bullet.tag = BulletTag.playerBullet.rawValue
            bullet.center = CGPoint(x: pos.x, y: pos.y - 25)
        }else {
            bullet.image = #imageLiteral(resourceName: "laser_Red")
            bullet.tag = BulletTag.enemyBullet.rawValue
            bullet.center = CGPoint(x: pos.x, y: pos.y + 30)
        }
    }
    
    //MARK:- Game frame updates (movements & collision handling)
    @objc func update() {
    }


}

