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
import CoreImage

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
        // 投稿内容を格納する
        let postComment:String = postTextField.text!
        let postData = PostData(postComment)
        
        // Firebaseに投稿データを保存する
        postData.savePostData(postImage.image!)
        
        // ホーム画面に遷移
    }
    
    
    // 「フィルター」ボタンの処理
    @IBAction func filterButton(_ sender: Any) {
        // エフェクト前画像をアンラップし、エフェクト用画像として取り出す
        if let image = selectedImage {
            // フィルター名を指定
            let filterName = filterArray[filterSelectNumber]
            
            // フィルターを全種類適用したら最初のフィルターに戻す
            filterSelectNumber += 1
            if filterSelectNumber == filterArray.count {
                filterSelectNumber = 0
            }
            
            // 元々の画像の回転角度を取得
            let rotate = image.imageOrientation
            
            // UIImage形式の画像をCIImage形式に変換
            let inputImage = CIImage(image: image)
            guard let effectFilter = CIFilter(name: filterName) else {
                return
            }
            
            // エフェクトのパラメータを初期化
            effectFilter.setDefaults()
            
            // エフェクトする元画像を設定
            effectFilter.setValue(inputImage, forKey: kCIInputImageKey)
            guard let outputImage = effectFilter.outputImage else {
                return
            }
            
            // エフェクト後のCIImage形式の画像を取り出す
            let ciContext = CIContext(options: nil)
            guard let cgImage = ciContext.createCGImage(outputImage, from: outputImage.extent) else {
                return
            }
            
            // エフェクト後の画像をCIContext上に描画し、結果をCGImageとして結果を取得
            postImage.image = UIImage(cgImage: cgImage, scale: 1.0, orientation: rotate)
        }
    }
    
    // フィルター名を格納する配列
    let filterArray = ["CIPhotoEffectMono"   ,"CIPhotoEffectChrome"  ,"CIPhotoEffectFade",
                       "CIPhotoEffectInstant","CIPhotoEffectNoir"    ,"CIPhotoEffectProcess",
                       "CIPhotoEffectTonal"  ,"CIPhotoEffectTransfer","CISepiaTone"]
    
    // フィルター配列の添字
    var filterSelectNumber:Int = 0
    
    
    // 「キャンセル」ボタンの処理
    @IBAction func cancelButton(_ sender: Any) {
        // 投稿画面に遷移
    }
    
}
