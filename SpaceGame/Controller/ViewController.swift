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
    var enemySpeed:CGFloat = 10
    var isGameOver:Bool = false
    var livesLeft:Int = 5
    var screenHeight:CGFloat = 0.0
    var scrore:Int = 0


    
    //MARK:- View lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        DispatchQueue.main.async {
            self.screenHeight = UIScreen.main.bounds.size.height
        }
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
                player.blinkPlayer()
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
        let elapsed = CACurrentMediaTime() - startTime
        let steps = (u_int)(elapsed * 60)
        if ((steps % 300) == 0) { //Create on each 300 frame updates
            let rand = 30 + CGFloat(arc4random()%UInt32(UIScreen.main.bounds.size.width - 60))
            createEnemy(pos: CGPoint(x: rand, y: 50))
        }
        for object in self.view.subviews {
            if (object.tag == ShipTag.enemy.rawValue) { //Enemy ship
                object.center = CGPoint(x: object.center.x, y: object.center.y+(0.1 * enemySpeed))
                if let player = player, (object.frame.intersects(player.frame)) { //Collided with player
                    explore(pos: player.center)
                    object.removeFromSuperview()
                    player.removeFromSuperview()
                    reduceLives()
                    //displayLink?.invalidate()
                    //gameOver()
                    break
                }
                if ((steps % 50) == 0) { //Enemy fires bullet on each 50 frame updates
                    createBullet(pos: object.center, isPlayer: false)
                }
            }else if (object.tag == BulletTag.playerBullet.rawValue) { //Player bullet
                object.center = CGPoint(x: object.center.x, y: object.center.y-(0.5 * enemySpeed))
                for enemy in self.view.subviews {
                    if (enemy.tag == ShipTag.enemy.rawValue) { //Enemy ship
                        if (enemy.frame.intersects(object.frame)) { //Enemy hit by player bullet
                            explore(pos: enemy.center)
                            enemy.removeFromSuperview()
                            object.removeFromSuperview()
                            updateScore()
                        }
                        if (enemy.center.y > (screenHeight + 100)) { //Destory out of screen enemies
                            enemy.removeFromSuperview()
                        }
                    }
                }
                if (object.center.y < -100) {  //Destory out of screen enemies
                    object.removeFromSuperview()
                }
            }else if (object.tag == BulletTag.enemyBullet.rawValue) { //Enemy bullet
                object.center = CGPoint(x: object.center.x, y: object.center.y+(0.5 * enemySpeed))
                if let player = player {
                    if (player.frame.intersects(object.frame)) { //Player hit by enemy bullet
                        object.removeFromSuperview()
                        player.removeFromSuperview()
                        explore(pos: player.center)
                        //displayLink?.invalidate()
                        //gameOver()
                        reduceLives()
                    }
                }
                if (object.center.y > (screenHeight + 100)) { //Destory out of screen enemy bullets
                    object.removeFromSuperview()
                }
            }
        }
        
        if ((steps % 50) == 0) { //Fire player bullet on each 50 frame updates
            if let player = player {
                createBullet(pos: player.center, isPlayer: true)
            }
        }
    }

    //MARK:- Collision animation (we can even use sprite sheets/lotte/gif, etc)
    func explore(pos:CGPoint) {
        let explosion = UIImageView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
        explosion.image = #imageLiteral(resourceName: "explosion")
        explosion.center = pos
        explosion.transform = CGAffineTransform(scaleX: 0.001, y: 0.001)
        self.view.addSubview(explosion)
        
        UIView.animate(withDuration: 0.2) {
            explosion.transform = CGAffineTransform(scaleX: 2, y: 2)
        } completion: { (completed) in
            UIView.animate(withDuration: 0.2) {
                explosion.transform = CGAffineTransform(scaleX: 0.001, y: 0.001)
            } completion: { (completed) in
                explosion.removeFromSuperview()
            }
        }
    }
    //MARK:- Update score and lives
    func updateScore() {
        scrore += 1
        scoreLabel.text = "Score \(scrore)"
    }
    
    func reduceLives() {
        livesLeft -= 1
        if (livesLeft <= 0) {
            livesLeft = 0
            lifeLabel.text = "Life \(livesLeft)"
            gameOver()
            return
        }
        lifeLabel.text = "Life \(livesLeft)"
        if (livesLeft <= 2) {
            lifeLabel.textColor = #colorLiteral(red: 0.9254902005, green: 0.2352941185, blue: 0.1019607857, alpha: 1)
        }
        createPlayer(respawn: true) //For blink
    }

    //MARK:- Move Player
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touchPoint = touches.first!.location(in: self.view)
        if (!isGameOver) {
            player?.center = touchPoint
        }
    }
    
    //MARK:- Game Over
    func gameOver() {
        isGameOver = true
        displayLink?.invalidate()
        infoLabel.text = "Game over. Start again?"
        startUI.isHidden = false
        player?.removeFromSuperview()
        player = nil
    }
    
    //MARK:- Clear all game objects
    func clearAllEnemiesAndBullets() {
        for object in self.view.subviews {
            if (object.tag == ShipTag.enemy.rawValue ||
                object.tag == BulletTag.playerBullet.rawValue ||
                object.tag == BulletTag.enemyBullet.rawValue) {
                object.removeFromSuperview()
            }
        }
    }
    
    //MARK:- Start Game
    func startGame() {
        startTime = CACurrentMediaTime()
        displayLink = CADisplayLink(
            target: self, selector: #selector(update)
        )
        displayLink?.add(to: .main, forMode: RunLoop.Mode.common)
    }
    
    @IBAction func startGameButtonClicked(_ sender: UIButton) {
        
        startUI.isHidden = true
        isGameOver = false
        livesLeft = 5
        lifeLabel.text = "Life \(livesLeft)"
        lifeLabel.textColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        if (player == nil) {
            createPlayer(respawn: false)
        }
        player?.center = CGPoint(x: UIScreen.main.bounds.size.width/2, y: UIScreen.main.bounds.size.height - 100)
        startGame()
    }
    
    
}

extension UIImageView {
    func blinkPlayer() {
        let blink = CABasicAnimation(keyPath: "opacity")
        blink.duration = 0.2
        blink.fromValue = 1
        blink.toValue = 0.1
        blink.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        blink.autoreverses = true
        blink.repeatCount = 3
        self.layer.add(blink, forKey: nil)
    }
}
