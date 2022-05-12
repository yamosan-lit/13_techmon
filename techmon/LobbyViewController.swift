//
//  LobbyViewController.swift
//  techmon
//
//  Created by 八森聖人 on 2022/05/12.
//

import UIKit

class LobbyViewController: UIViewController {
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var staminaLabel: UILabel!
    
    let techMonManager = TechMonManager.shared
    
    var stamina: Int = 100
    var staminaTimer: Timer!
    
    @IBAction func toBattle(_ sender: UIButton) {
        // スタミナが50以上あればスタミナ50を消費し戦闘画面へ
        if stamina >= 50 {
            stamina -= 50
            staminaLabel.text = "\(stamina) / 100"
            performSegue(withIdentifier: "toBattle", sender: nil)
        } else {
            
            let alert = UIAlertController(
                title: "バトルに行けません",
                message: "スタミナが足りません",
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(
                title: "OK",
                style: .default,
                handler: nil
            ))
            present(alert, animated: true, completion: nil)
        }
    }
    
    
    // スタミナの回復
    @objc func updateStaminaValue() {
        if stamina < 100 {
            stamina += 1
            staminaLabel.text = "\(self.stamina) / 100"
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // UIの設定
        nameLabel.text = "勇者"
        staminaLabel.text = "\(stamina) / 100"
        
        // タイマー設定
        staminaTimer = Timer.scheduledTimer(timeInterval: 3, target: self, selector: #selector(updateStaminaValue), userInfo: nil, repeats: true)
        staminaTimer.fire()
    }
    
    // ロビー画面が見えなくなるとき呼ばれる
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        techMonManager.stopBGM()
    }
}
