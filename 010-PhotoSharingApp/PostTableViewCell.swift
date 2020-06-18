//
//  PostTableViewCell.swift
//  010-PhotoSharingApp
//
//  Created by Takatoshi Miura on 2020/06/14.
//  Copyright © 2020 Takatoshi Miura. All rights reserved.
//
//  ＜概要＞
//  ホーム画面に表示される投稿のレイアウトを定めたクラス。
//  セルに投稿内容を表示するメソッドに、Firebaseから取得したデータを格納してセルを作成する。
//  そのセルをホーム画面のTableViewのセルとして使用する。
//

import UIKit
import FirebaseStorage

class PostTableViewCell: UITableViewCell {
    
    @IBOutlet weak var postImage: UIImageView!  // 投稿画像
    @IBOutlet weak var postTime: UILabel!       // 投稿日時
    @IBOutlet weak var postComment: UILabel!    // 投稿コメント
    @IBOutlet weak var replyComment: UILabel!   // 返信コメント
    var postID:Int = 0                          // 投稿ID。表示はしないが、返信コメント追加時に必要。
    
    
    @IBOutlet weak var replyCommentButton: UIButton!    // 「返信」ボタン

    
    
    // セルに投稿内容を表示するメソッド
    func printPostData(_ postData:PostData) {
        // 画像を取得し、セルに格納する
        let storage = Storage.storage().reference(forURL: "gs://photosharingapp-729c8.appspot.com")
        let imageRef = storage.child("\(postData.postID)")
        postImage.sd_setImage(with: imageRef)
        
        // 投稿IDをセット
        self.postID = postData.postID
        
        // コメント,投稿日時を表示
        postComment.text  = "\(postData.accountName):\(postData.postComment)"
        postTime.text     = postData.postTime
        replyComment.text = postData.replyComment
    }
    
}
