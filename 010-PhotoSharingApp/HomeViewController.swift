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
import FirebaseUI
import SVProgressHUD

class HomeViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // delegateとdataSourceの指定
        self.postTableView.delegate = self
        self.postTableView.dataSource = self
        
        let nib = UINib(nibName: "PostTableViewCell", bundle: nil)
        postTableView.register(nib, forCellReuseIdentifier: "PostTableViewCell")
    }

    
    // テーブルビュー
    @IBOutlet var postTableView: UITableView!
    
    // PostDataを格納した配列
    var postDataArray = [PostTableViewCell]()
    
    
    // HomeViewControllerが呼ばれたときの処理
    override func viewWillAppear(_ animated: Bool) {
        // データベースのデータ格納用
        var postImage:UIImageView!
            postImage = UIImageView()
        var postDataCollection = [String:Any]()
        
        // HUDで処理中を表示
        SVProgressHUD.show()
        
        // データの取得
        let db = Firestore.firestore()
        db.collection("PostData").getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for document in querySnapshot!.documents {
                    print("\(document.documentID) => \(document.data())")
                    // 取得したデータをコレクションに格納
                    postDataCollection = document.data()
                    // 投稿IDを基に、画像をStorageから取得
                    let storage = Storage.storage().reference(forURL: "gs://photosharingapp-729c8.appspot.com")
                    let imageRef = storage.child("\(String(describing: postDataCollection["PostID"]))")
                    postImage.sd_setImage(with: imageRef)
                    // コレクションから値を取り出し、セルを作成
                    let cell = PostTableViewCell()
                    let comment:String? = String(describing: postDataCollection["PostComment"])
                    let time:String?    = String(describing: postDataCollection["PostTime"])
                    
                    print("PostComment:\(String(describing: postDataCollection["PostComment"]))")
                    print("PostTime:\(String(describing: postDataCollection["PostTime"]))")
                    
                    if let comment = comment {
                        print(comment)
                        cell.postComment.text = comment
                    } else {
                        print("commentはnilです。")
                    }
                    
                    if let time = time {
                        print(time)
                        cell.postTime.text = time
                    } else {
                        print("timeはnilです。")
                    }
                    
                    cell.postImage.sd_setImage(with: imageRef)
                    // 作成したセルをリストに挿入
                    self.postDataArray.insert(cell,at:0)
                    self.postTableView.insertRows(at: [IndexPath(row:0,section:0)],with: UITableView.RowAnimation.right)
                }
                // HUDを非表示
                SVProgressHUD.dismiss()
            }
        }
    }
    
    
    // セクションの数を返却する
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    
    // PostDataArray配列の長さ(項目の数)を返却する
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return postDataArray.count
    }


    // テーブルの行ごとのセルを返却する
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //Storyboardで指定した識別子を利用して再利用可能なセルを取得する
        let cell = tableView.dequeueReusableCell(withIdentifier: "PostTableViewCell", for: indexPath) as! PostTableViewCell
        return cell
    }
    
    
    // Firebaseから投稿内容を読み取るメソッド
    
    
    // HomeViewControllerが呼ばれたときの処理
    @IBAction func goToHome(_segue:UIStoryboardSegue){
    }

}
