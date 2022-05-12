//
//  BattleViewController.swift
//  techmon
//
//  Created by 八森聖人 on 2022/05/12.
//

import UIKit

class BattleViewController: UIViewController {
    @IBOutlet weak var playerImageView: UIImageView!
    @IBOutlet weak var playerNameLabel: UILabel!
    @IBOutlet weak var playerHPLabel: UILabel!
    @IBOutlet weak var playerMPLabel: UILabel!
    @IBOutlet weak var playerTPLabel: UILabel!
    
    @IBOutlet weak var enemyImageView: UIImageView!
    @IBOutlet weak var enemyNameLabel: UILabel!
    @IBOutlet weak var enemyHPLabel: UILabel!
    @IBOutlet weak var enemyMPLabel: UILabel!
    
    let techMonManager = TechMonManager.shared
    
    var player: Character!
    var enemy: Character!
    
    var playerHP = 100
    var playerMP = 0
    var enemyHP = 200
    var enemyMP = 0
    
    var gameTimer: Timer!
    var isPlayerAttackAvailable: Bool = true
    
    // 0.1秒ごとのゲームの状態を更新する
    @objc func updateGame() {
        // プレイヤーのステータスを更新
        player.currentMP += 1
        if player.currentMP >= 20 {
            isPlayerAttackAvailable = true
            player.currentMP = 20
        } else {
            isPlayerAttackAvailable = false
        }
        
        // 敵のステータスを更新
        enemy.currentMP += 1
        if enemy.currentMP >= 35 {
            enemyAttack()
            enemy.currentMP = 0
        }
        
        updateUI()
    }
    
    // プレイヤーの行動: ためる
    @IBAction func tameruAction() {
        if isPlayerAttackAvailable {
            techMonManager.playSE(fileName: "SE_charge")
            player.currentTP += 40
            if player.currentTP >= player.maxTP {
                player.currentTP = player.maxTP
            }

            player.currentMP = 0
        }
    }
    
    // プレイヤーの行動: ファイア
    @IBAction func fireAction() {
        if isPlayerAttackAvailable && player.currentTP >= 40 {
            techMonManager.damageAnimation(imageView: enemyImageView)
            techMonManager.playSE(fileName: "SE_fire")
            
            enemy.currentHP -= 100
            
            player.currentTP -= 40
            if player.currentTP <= 0 {
                player.currentTP = 0
            }
            player.currentMP = 0
            
            judgeBattle()
        }
    }
    
    // プレイヤーの行動: こうげき
    @IBAction func attackAction() {
        if isPlayerAttackAvailable {
            techMonManager.damageAnimation(imageView: enemyImageView)
            techMonManager.playSE(fileName: "SE_attack")
            
            enemy.currentHP -= player.attackPoint
            player.currentMP = 0
            
            player.currentTP += 10
            if player.currentTP >= player.maxTP {
                player.currentTP = player.maxTP
            }
            
            updateUI()
            judgeBattle()
        }
    }
    
    // 敵の攻撃
    func enemyAttack() {
        techMonManager.damageAnimation(imageView: playerImageView)
        techMonManager.playSE(fileName: "SE_attack")
        
        player.currentHP -= 20
        
        
        updateUI()
        judgeBattle()
    }
    
    // ステータスの反映
    func updateUI() {
        // プレイヤーのステータスを反映
        playerHPLabel.text = "\(player.currentHP) / \(player.maxHP)"
        playerMPLabel.text = "\(player.currentMP) / \(player.maxMP)"
        playerTPLabel.text = "\(player.currentTP) / \(player.maxTP)"

        // 敵のステータスを反映
        enemyHPLabel.text = "\(enemy.currentHP) / \(enemy.maxHP)"
        enemyMPLabel.text = "\(enemy.currentMP) / \(enemy.maxMP)"
    }
    
    // 勝敗判定をする
    func judgeBattle() {
        if player.currentHP <= 0 {
            finishBattle(vanishImageView: playerImageView, isPlayerWin: false)
        } else if enemy.currentHP <= 0 {
            finishBattle(vanishImageView: enemyImageView, isPlayerWin: true)
        }
    }
    
    // 勝敗が決定した時の処理
    func finishBattle(vanishImageView: UIImageView, isPlayerWin: Bool) {
        techMonManager.vanishAnimation(imageView: vanishImageView)
        techMonManager.stopBGM()
        gameTimer.invalidate()
        isPlayerAttackAvailable = false
        
        var finishMessage: String = ""
        if isPlayerWin {
            techMonManager.playSE(fileName: "SE_fanfare")
            finishMessage = "勇者の勝利！！"
        } else {
            techMonManager.playSE(fileName: "SE_gameover")
            finishMessage = "勇者の敗北..."
        }
        
        let alert = UIAlertController(title: "バトル終了", message: finishMessage, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
            self.dismiss(animated: true, completion: nil)
        }))
        present(alert, animated: true, completion: nil)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // キャラクターの読み込み
        player = techMonManager.player
        enemy = techMonManager.enemy
        
        // プレイヤーのステータスの反映
        playerImageView.image = player.image
        playerNameLabel.text = player.name
        
        // 敵のステータスを反映
        enemyImageView.image = enemy.image
        enemyNameLabel.text = enemy.name

        self.updateUI()
        
        // ゲームスタート
        gameTimer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(updateGame), userInfo: nil, repeats: true)
        gameTimer.fire()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        techMonManager.playBGM(fileName: "BGM_battle001")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        techMonManager.stopBGM()
    }
}
