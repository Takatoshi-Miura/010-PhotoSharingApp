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
//  ＜機能＞
//  投稿データ作成機能
//      イニシャライザに投稿したいコメントを渡すことで、投稿データを作成できる。
//  投稿機能
//      画像はStorageに、その他の投稿データはCloudFire Storeに投稿できる。
//  投稿データ取得機能
//      Firebaseにアクセスし、投稿したデータを取得できる。
//

import UIKit
import Firebase
import FirebaseUI
import SVProgressHUD


class PostData {
    
    // 新規投稿データ用
    static var postCount:Int = 0   // 投稿数
    var postID:Int = 0             // 投稿ID
    var accountName:String = ""    // 投稿者のアカウント名
    var postComment:String = ""    // 投稿コメント
    var postTime:String = ""       // 投稿日時
    var replyComment:String = ""   // 返信コメント
    
    
    // データベースの投稿データを格納する
    var postDataArray = [PostData]()

    
    // イニシャライザ
    init() {
    }
     
    // 投稿を新規作成するときのイニシャライザ
    init(_ postComment:String) {
        // 投稿IDのセット
        PostData.postCount += 1
        self.postID  = PostData.postCount
        
        // アカウント名、コメントのセット
        let user = Auth.auth().currentUser
        self.accountName = user?.displayName! as! String
        self.postComment = postComment
        
        // 現在時刻のセット
        let now = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "ja_JP")
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
        self.postTime = dateFormatter.string(from: now)
    }
    
    // データベースの投稿データ取得用イニシャライザ
    init(_ postID:Int,_ accountName:String,_ postComment:String,_ postTime:String,_ replyComment:String) {
        self.postID       = postID
        self.accountName  = accountName
        self.postComment  = postComment
        self.postTime     = postTime
        self.replyComment = replyComment
    }
    
    
    // データベースの投稿を取得するメソッド
    func loadDatabase() {
        // 配列の初期化
        postDataArray = []
        
        // データ取得
        // ホーム画面にて、古い投稿を下、新しい投稿を上に表示させるため、PostIDの降順にソートする
        let db = Firestore.firestore()
        db.collection("PostData").order(by: "PostID", descending: true).getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for document in querySnapshot!.documents {
                    
                    // 取得データ(画像以外)をコレクションに格納
                    // 画像はPostTableViewCellにて取得するため、ここでは取得しない。
                    let postDataCollection = document.data()
                    print("\(document.documentID) => \(postDataCollection)")
                
                    // 取得データを基に、投稿データを作成
                    let databasePostData = PostData(postDataCollection["PostID"] as! Int,
                                                    postDataCollection["AccountName"] as! String,
                                                    postDataCollection["PostComment"] as! String,
                                                    postDataCollection["PostTime"] as! String,
                                                    postDataCollection["ReplyComment"] as! String)
                    
                    // 投稿データを格納 ＆ TODO:PostIDの降順にソート
                    self.postDataArray.append(databasePostData)
                    
                    // postIDの重複対策
                    // データベースの投稿IDの最大値を取得し、新規投稿時のIDは最大値＋１で設定
                    if databasePostData.postID > PostData.postCount {
                        PostData.postCount = databasePostData.postID
                    }
                }
            }
        }
    }
    
    
    // 返信コメントを更新するメソッド
    func updateReplyComment(_ postID:Int,_ replyComment:String) {
        // 受け取ったPostIDの投稿データにアクセス
        let db = Firestore.firestore()
        let washingtonRef = db.collection("PostData").whereField("PostID", isEqualTo: postID)

        // 返信コメントを更新する
        washingtonRef.setValue(replyComment, forKey: "ReplyComment")
    }
    
    
    // 投稿内容を保存するメソッド
    func savePostData(_ postImage:UIImage) {
        // 投稿画像以外をCloud Firestoreに保存
        uploadFirestore()
        
        // 投稿画像をFirebaseのStorageに保存
        uploadImage(postImage)
    }
    
    
    // Cloud Firestoreに画像データ以外を保存するメソッド
    func uploadFirestore() {
        // Cloud Firestoreに画像データ以外を保存(画像データは非対応のため)
        let db = Firestore.firestore()
        var ref: DocumentReference? = nil
        ref = db.collection("PostData").addDocument(data: [
            "PostID"      : self.postID,
            "AccountName" : self.accountName,
            "PostComment" : self.postComment,
            "PostTime"    : self.postTime,
            "ReplyComment": self.replyComment
        ]) { err in
            if let err = err {
                print("Error adding document: \(err)")
            } else {
                print("Document added with ID: \(ref!.documentID)")
            }
        }
    }
    
    
    // 画像データをStorageにアップロードするメソッド
    func uploadImage(_ postImage:UIImage) {
        // Storageの参照（名前を投稿IDに設定して保存）
        let storageref  = Storage.storage().reference(forURL: "gs://photosharingapp-729c8.appspot.com").child("\(self.postID)")
        
        // contentTypeの指定 (Storega上で画像をダウンロードすることなく、確認するため)
        let storagemeta = StorageMetadata()
        storagemeta.contentType = "image/jpeg"
        
        // imageをNSDataに変換
        let data = postImage.jpegData(compressionQuality: 1.0)! as NSData
        
        // Storageに保存
        storageref.putData(data as Data, metadata: storagemeta) { (data, error) in
            if error != nil {
                return
            }
        }
    }
    
        
}

