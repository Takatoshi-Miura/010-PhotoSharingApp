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
//      イニシャライザに投稿したい画像とコメントを渡すことで、投稿データを作成できる。
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
    var postImage:UIImage = UIImage(systemName: "questionmark")!    // 投稿画像
    
    // データベースの投稿データ格納用
    var postIDArray:[Int] = []
    var accountNameArray:[String] = []
    var postCommentArray:[String] = []
    var postTimeArray:[String] = []
    var postImageArray:[UIImage] = []

    
    // データベースの投稿取得用イニシャライザ
    init() {
    }
     
    // 投稿を新規作成するときのイニシャライザ
    init(_ postImage:UIImage,_ postComment:String) {
        // 投稿IDのセット
        PostData.postCount += 1
        self.postID  = PostData.postCount
        
        // アカウント名、画像、コメントのセット
        let user = Auth.auth().currentUser
        self.accountName = user?.displayName! as! String
        self.postImage = postImage
        self.postComment = postComment
        
        // 現在時刻のセット
        let now = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "ja_JP")
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
        self.postTime = dateFormatter.string(from: now)
    }
    
    
    // データベースの投稿を取得するメソッド
    func loadDatabase() {
        // データベースのデータ格納用
        var postImage:UIImageView! = UIImageView()
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
                    
                    // 取得データを配列に追加
                    // 既に取得しているデータかどうかをpostIDで判定し、取得していなければ追加する。
                    let ans = self.postIDArray.filter{$0 == postDataCollection["PostID"] as! Int}
                    if ans == [] {
                        print("重複していないので、データを追加します。")
                        self.postIDArray.append(postDataCollection["PostID"] as! Int)
                        self.accountNameArray.append(postDataCollection["AccountName"] as! String)
                        self.postCommentArray.append(postDataCollection["PostComment"] as! String)
                        self.postTimeArray.append(postDataCollection["PostTime"] as! String)
                        self.postImageArray.append(postImage.image ?? UIImage(systemName: "questionmark")!)
                        print(self.postIDArray)
                        if self.postID > PostData.postCount {
                            PostData.postCount = self.postID
                        }
                    } else {
                        print("重複してます。")
                    }
                    
                }
            }
        }
        // HUDを非表示
        SVProgressHUD.dismiss()
    }
    
    
    // 投稿内容をフィールドにセットするメソッド
    func setPostData(_ postID:Int) {
        self.postID = postID-1
        self.accountName = accountNameArray[postID-1]
        self.postComment = postCommentArray[postID-1]
        self.postTime    = postTimeArray[postID-1]
        self.postImage   = postImageArray[postID-1]
    }
    
    
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
            "AccountName": self.accountName,
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

