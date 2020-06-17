//
//  ViewController.swift
//  010-PhotoSharingApp
//
//  Created by Takatoshi Miura on 2020/06/13.
//  Copyright © 2020 Takatoshi Miura. All rights reserved.
//
//  ＜概要＞
//  アカウントがない場合はアカウントを作成し、アカウントがある場合はログインができる。
//  アカウントの登録情報はFirebaseの"Authentication"に保存される。
//
//  ＜機能＞
//  アカウント作成機能
//      入力されたメールアドレスがデータベースに存在しなければ、アカウントが作成される。
//      すでにアカウントが存在している場合は、その旨を通知する。
//  ログイン機能
//      入力されたメールアドレス、パスワードの組み合わせがデータベースに存在すれば、タブ画面に遷移。
//      存在しなければ、入力の誤りがないか確認を促すメッセージを通知。
//

import UIKit
import Firebase
import FirebaseAuth
import SVProgressHUD

class LoginViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // テキストフィールド
    @IBOutlet weak var textFieldMailAddress: UITextField!
    @IBOutlet weak var textFieldPassword: UITextField!
    @IBOutlet weak var textFieldAccountName: UITextField!
    

    // 「ログイン」ボタンの処理
    @IBAction func loginButton(_ sender: Any) {
        if let address = textFieldMailAddress.text, let password = textFieldPassword.text {
            
            // アドレスとパスワード名のいずれかでも入力されていない時は何もしない
            if address.isEmpty || password.isEmpty {
                SVProgressHUD.showError(withStatus: "必要項目を入力して下さい")
                return
            }
            
            // HUDで処理中を表示
            SVProgressHUD.show()
            
            // ログイン処理
            Auth.auth().signIn(withEmail: address, password: password) { authResult, error in
                // エラーのハンドリング
                if let error = error {
                    SVProgressHUD.showError(withStatus: "ログインに失敗しました。入力を確認してください。")
                    return
                }
                SVProgressHUD.showSuccess(withStatus: "ログインしました。")
                
                // タブ画面に遷移
                // メッセージが隠れてしまうため、遅延処理を行う
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1.0) {
                    self.performSegue(withIdentifier: "goTabBarController", sender: nil)
                }
            }
        }
    }
        
    
    // 「アカウント作成」ボタンの処理
    @IBAction func createAccountButton(_ sender: Any) {
        // アドレス,パスワード名,アカウント名の入力を確認
        if let address = textFieldMailAddress.text, let password = textFieldPassword.text, let accountName = textFieldAccountName.text {
            
            // アドレス,パスワード名,アカウント名のいずれかでも入力されていない時は何もしない
            if address.isEmpty || password.isEmpty || accountName.isEmpty {
                SVProgressHUD.showError(withStatus: "必要項目を入力して下さい")
                return
            }
            
            // アカウント作成処理
            Auth.auth().createUser(withEmail: textFieldMailAddress.text!, password: textFieldPassword.text!) { authResult, error in
                // エラーのハンドリング
                if let errorCode = AuthErrorCode(rawValue: error!._code) {
                    switch errorCode {
                        case .invalidEmail:
                            SVProgressHUD.showError(withStatus: "メールアドレスの形式が違います。")
                        case .emailAlreadyInUse:
                            SVProgressHUD.showError(withStatus: "既にこのメールアドレスは使われています。")
                        case .weakPassword:
                            SVProgressHUD.showError(withStatus: "パスワードは6文字以上で入力してください。")
                        default:
                            SVProgressHUD.showError(withStatus: "エラーが起きました。しばらくしてから再度お試しください。")
                    }
                    return
                }
                
                // アカウント名の登録
                let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest()
                changeRequest?.displayName = accountName
                changeRequest?.commitChanges { (error) in}
                SVProgressHUD.showSuccess(withStatus: "アカウントを作成しました。")
                
                // タブ画面に遷移
                // メッセージが隠れてしまうため、遅延処理を行う
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1.0) {
                    self.performSegue(withIdentifier: "goTabBarController", sender: nil)
                }
            }
        }
    }
    
    
    // ログイン画面に戻ってくるときに呼び出される処理
    @IBAction func goToLogin(_segue:UIStoryboardSegue){
        // テキストフィールドをクリア
        textFieldMailAddress.text = ""
        textFieldPassword.text    = ""
        textFieldAccountName.text = ""
    }

}

