//
//  PostTableViewCell.swift
//  010-PhotoSharingApp
//
//  Created by Takatoshi Miura on 2020/06/14.
//  Copyright © 2020 Takatoshi Miura. All rights reserved.
//

import UIKit

class PostTableViewCell: UITableViewCell {
    
    @IBOutlet weak var postImage: UIImageView!
    @IBOutlet weak var postTime: UILabel!
    @IBOutlet weak var postComment: UILabel!
    
    
    // 「返信」ボタンの処理
    @IBAction func replyCommentButton(_ sender: Any) {
    }
    
    
    // セルに投稿内容を表示するメソッド
    func printPostData(_ setImage:UIImage,_ setComment:String,_ setTime:String) {
        // 画像,コメント,投稿日時を表示
        postImage.image  = setImage
        postComment.text = setComment
        postTime.text    = setTime
    }
    
}