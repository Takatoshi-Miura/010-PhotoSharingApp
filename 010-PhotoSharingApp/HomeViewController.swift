//
//  HomeViewController.swift
//  010-PhotoSharingApp
//
//  Created by Takatoshi Miura on 2020/06/13.
//  Copyright © 2020 Takatoshi Miura. All rights reserved.
//
//  ＜概要＞
//  ホーム画面での処理をまとめたクラス。
//  Firebaseから投稿内容を読み取り、PostTableViewCellのレイアウトで表示する。
//  画面の更新は、ホーム画面が呼ばれる毎に行う。
//
//  ＜機能＞
//  投稿読み取り機能
//      Firebaseにアクセスして投稿内容を読み取り、PostTableViewCellに格納する。
//  投稿表示機能
//      PostTableViewCellに格納した投稿データをPostDataArrayに格納する。
//      PostDataArrayをセルとして表示する。
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseUI
import SVProgressHUD

class HomeViewController: UIViewController , UITableViewDelegate, UITableViewDataSource {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // dataSource,delegateの指定
        postTableView.dataSource = self
        postTableView.delegate   = self
        
        // PostTableViewCellを登録
        postTableView.register(UINib(nibName: "PostTableViewCell", bundle: nil), forCellReuseIdentifier: "PostTableViewCell")
        
        // テーブルビューの更新
        self.postTableView.reloadRows(at:[IndexPath(row: 0, section: 0)],with:UITableView.RowAnimation.fade)
        self.postTableView?.reloadData()
        
    }

    
    // テーブルビュー
    @IBOutlet var postTableView: UITableView!
    
    // PostDataを格納した配列
    var postDataArray = [PostData]()
    
    
    // HomeViewControllerが呼ばれたときの処理
    override func viewWillAppear(_ animated: Bool) {
        // HUDで処理中を表示
        SVProgressHUD.show()
        
        // データベースの投稿を取得
        let databasePostData = PostData()
        databasePostData.loadDatabase()
        
        // 投稿データを取得
        // データの取得が終わるまで時間待ち
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2.0) {
            self.postDataArray = []
            self.postDataArray = databasePostData.postDataArray
            
            self.postTableView?.reloadData()
            // HUDを非表示
            SVProgressHUD.dismiss()
        }
    }
    
    
    // セクションの数を返却する
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    
    // PostDataArray配列の長さ(項目の数)を返却する
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return postDataArray.count
    }
    

    // セルの高さ設定
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 450
    }

    
    // テーブルの行ごとのセルを返却する
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Storyboardで指定した識別子を利用して再利用可能なセルを取得する
        let cell = tableView.dequeueReusableCell(withIdentifier: "PostTableViewCell", for: indexPath) as! PostTableViewCell
        
        // 「返信」ボタンをタップしたときの処理を設定
        cell.replyCommentButton.tag = indexPath.row
        cell.replyCommentButton.addTarget(self, action: #selector(self.pushButton(_:)), for: .touchUpInside)
        
        // セルに投稿データをセットする
        cell.printPostData(postDataArray[indexPath.row].accountName,
                           postDataArray[indexPath.row].postComment,
                           postDataArray[indexPath.row].postTime,
                           postDataArray[indexPath.row].postID,
                           postDataArray[indexPath.row].replyComment)
        
        return cell
    }
    
    
    // 返信ボタンをタップしたときの処理
    @objc private func pushButton(_ sender:UIButton) {
        // 指定した投稿に返信コメントを追加
        addReplyComment(postDataArray[sender.tag].postID)
    }
    
    
    // 返信コメントを作成するメソッド
    func addReplyComment(_ postID:Int) {
        // 返信コメント格納用
        var replyComment:String = ""
        
        // アラートダイアログを生成
        let alertController = UIAlertController(title:"返信を追加",message:"コメントを入力してください",preferredStyle:UIAlertController.Style.alert)
        
        // テキストエリアを追加
        alertController.addTextField(configurationHandler:nil)
        
        // OKボタンを宣言
        let okAction = UIAlertAction(title:"OK",style:UIAlertAction.Style.default){(action:UIAlertAction)in
            // OKボタンがタップされたときの処理
            if let textField = alertController.textFields?.first {
                // 現在のアカウント名を取得
                let user = Auth.auth().currentUser
                
                // テキストフィールドの入力値を用いて返信コメントを作成
                replyComment = "\(user!.displayName!):\(textField.text!)"
                
                // データベースを更新
                let postData = PostData()
                postData.addReplyComment(postID, replyComment)
                
                // ビューを更新
                self.viewWillAppear(true)
            }
        }
        
        //CANCELボタンを宣言
        let cancelButton = UIAlertAction(title:"CANCEL",style:UIAlertAction.Style.cancel,handler:nil)
        
        // ボタンを追加
        alertController.addAction(okAction)
        alertController.addAction(cancelButton)
        
        //アラートダイアログを表示
        self.present(alertController,animated:true,completion:nil)
    }
    
    
    // HomeViewControllerが呼ばれたときの処理
    @IBAction func goToHome(_segue:UIStoryboardSegue){
    }

}
