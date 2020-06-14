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
        
        postTableView.register(UINib(nibName: "PostTableViewCell", bundle: nil), forCellReuseIdentifier: "PostTableViewCell")
    }

    
    // テーブルビュー
    @IBOutlet var postTableView: UITableView!
    
    // PostDataを格納した配列
    var postDataArray = [PostData]()
    
    
    
    // HomeViewControllerが呼ばれたときの処理
    override func viewWillAppear(_ animated: Bool) {
        // 投稿データの取得
        let databasePostData = PostData()
        databasePostData.readDatabase()
        
        // 取得した投稿の数だけPostDataを作成
        // データの取得が終わるまで時間待ち
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2.0) {
            for num in databasePostData.postIDArray {
                databasePostData.setPostData(num)
                self.postDataArray.append(databasePostData)
                print("postDataArrayにデータを追加しました")
                print("postDataArrayの要素数：\(self.postDataArray.count)")
                self.postTableView.insertRows(at: [IndexPath(row:0,section:0)],with: UITableView.RowAnimation.right)
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
        cell.printPostData(postDataArray[indexPath.row].postImage, postDataArray[indexPath.row].postComment, postDataArray[indexPath.row].postTime)
        print("実行しました")
        return cell
    }
    
    
    // HomeViewControllerが呼ばれたときの処理
    @IBAction func goToHome(_segue:UIStoryboardSegue){
    }

}
