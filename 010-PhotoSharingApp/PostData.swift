//
//  PostData.swift
//  010-PhotoSharingApp
//
//  Created by Takatoshi Miura on 2020/06/13.
//  Copyright © 2020 Takatoshi Miura. All rights reserved.
//
//  ＜概要＞
//  投稿内容をまとめたクラス。
//  投稿する際にはこのクラスのオブジェクトを生成する。
//

import UIKit
import Firebase


class PostData {
    
    init(_ postImage:UIImage,_ postComment:String) {
        // 投稿IDのセット
        PostData.postCount += 1
        postID  = PostData.postCount
        
        // アカウント名、画像、コメントのセット
        let user = Auth.auth().currentUser
        self.accountName = user?.displayName
        self.postImage = postImage
        self.postComment = postComment
        
        // 現在時刻のセット
        let now = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "ja_JP")
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
        self.postTime = dateFormatter.string(from: now)
    }
    
    static var postCount:Int = 0    // 投稿数
    let postID:Int                  // 投稿ID
    
    let accountName:String?         // 投稿者のアカウント名
    let postImage:UIImage           // 投稿画像
    let postComment:String          // 投稿コメント
    let postTime:String             // 投稿日時
    
    
    // 投稿内容を保存するメソッド
    func savePostData() {
        // 投稿画像以外をCloud Firestoreに保存
        uploadFirestore()
        // 投稿画像をFirebaseのStorageに保存
        uploadImage()
    }
    
    
    // Cloud Firestoreに画像データ以外を保存するメソッド
    func uploadFirestore() {
        // Cloud Firestoreに画像データ以外を保存(画像データは非対応のため)
        let db = Firestore.firestore()
        var ref: DocumentReference? = nil
        ref = db.collection("PostData").addDocument(data: [
            "PostID"     : self.postID,
            "AccountName": self.accountName ?? "",
            "PostComment": self.postComment,
            "PostTime"   : self.postTime
        ]) { err in
            if let err = err {
                print("Error adding document: \(err)")
            } else {
                print("Document added with ID: \(ref!.documentID)")
            }
        }
    }
    
    
    // 画像データをStorageにアップロードするメソッド
    func uploadImage() {
        //Storageの参照（名前を投稿IDに設定して保存）
        let storageref = Storage.storage().reference(forURL: "gs://photosharingapp-729c8.appspot.com").child("\(self.postID)")
        //画像
        let image = self.postImage
        //imageをNSDataに変換
        let data = image.jpegData(compressionQuality: 1.0)! as NSData
        //Storageに保存
        storageref.putData(data as Data, metadata: nil) { (data, error) in
            if error != nil {
                return
            }
        }
    }
    
        
}

