//
//  PostViewController.swift
//  010-PhotoSharingApp
//
//  Created by Takatoshi Miura on 2020/06/13.
//  Copyright © 2020 Takatoshi Miura. All rights reserved.
//
//  ＜概要＞
//  投稿内容編集画面での処理をまとめたクラス。
//  選択した画像と、テキストフィールドに入力したコメントをセットで投稿する。
//
//  ＜機能＞
//  投稿機能
//      選択した画像とコメントを使って投稿内容を作成し、投稿ボタンタップで投稿内容をFirebaseに保存する。
//          投稿画像 → Storageに保存。
//          コメント、アカウント名、投稿日時、投稿ID → Cloud Firestoreに保存。
//          両者は投稿IDで紐付いている。
//
//  投稿キャンセル機能
//      選択した画像、記入したコメントを消去し、投稿画面に戻る。
//

import UIKit

class PostViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // 画像選択画面で選択された画像を表示
        postImage.image = selectedImage
    }
    
    // 画像選択画面にて選択した画像を格納する変数
    var selectedImage:UIImage?
    
    @IBOutlet weak var postImage: UIImageView!
    @IBOutlet weak var postTextField: UITextField!
    
    
    // 「投稿」ボタンの処理
    @IBAction func postButton(_ sender: Any) {
    }
    
    
    // 「キャンセル」ボタンの処理
    @IBAction func cancelButton(_ sender: Any) {
        // 投稿画面に遷移
    }
    
}
