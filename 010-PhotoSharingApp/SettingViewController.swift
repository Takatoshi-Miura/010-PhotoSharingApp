//
//  SettingViewController.swift
//  010-PhotoSharingApp
//
//  Created by Takatoshi Miura on 2020/06/13.
//  Copyright © 2020 Takatoshi Miura. All rights reserved.
//

import UIKit
import FirebaseAuth
import SVProgressHUD

class SettingViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // テキストフィールドにアカウント名を表示
        let user = Auth.auth().currentUser
        textFieldAccountName.text = user?.displayName
    }
    
    // テキストフィールド
    @IBOutlet weak var textFieldAccountName: UITextField!
    

    // 「アカウント名変更」ボタンの処理
    @IBAction func changeAccountNameButton(_ sender: Any) {
        // アカウント名の変更
        let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest()
        changeRequest?.displayName = textFieldAccountName.text
        changeRequest?.commitChanges { (error) in
        }
        SVProgressHUD.showSuccess(withStatus: "アカウント名を変更しました。")
    }
    
    
    // 「ログアウト」ボタンの処理
    @IBAction func logoutButton(_ sender: Any) {
        // ログアウト処理
        let firebaseAuth = Auth.auth()
        do {
            try firebaseAuth.signOut()
            SVProgressHUD.showSuccess(withStatus: "ログアウトしました。")
        } catch let signOutError as NSError {
            print ("Error signing out: %@", signOutError)
            SVProgressHUD.showError(withStatus: "ログアウトに失敗しました。")
        }
    }
    
    
    
}
