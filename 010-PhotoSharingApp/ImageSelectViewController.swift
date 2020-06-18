//
//  ImageSelectViewController.swift
//  010-PhotoSharingApp
//
//  Created by Takatoshi Miura on 2020/06/13.
//  Copyright © 2020 Takatoshi Miura. All rights reserved.
//
//  ＜概要＞
//  投稿タブでの処理をまとめたクラス。
//  画像をライブラリか、カメラから取得した後、投稿内容編集画面に遷移する。
//
//  ＜機能＞
//  ライブラリ画像選択機能
//      画像ライブラリへのアクセス許可を求めるダイアログを表示。
//      許可されたら画像ライブラリを表示。
//      画像を選択したら投稿内容編集画面に遷移。遷移時に選択した画像を渡す。
//  カメラ画像選択機能
//      カメラの使用許可を求めるダイアログを表示。
//      許可されたらカメラを起動。
//      撮影したら投稿内容編集画面に遷移。遷移時に撮影した画像を渡す。
//

import UIKit
import SVProgressHUD
import CLImageEditor

class ImageSelectViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, CLImageEditorDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // 選択する画像を格納する変数
    var selectImage:UIImage?
    
    
    // 「ライブラリ」ボタンの処理
    @IBAction func handleLibraryButton(_ sender: Any) {
        // ライブラリが利用可能か判定
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            print("ライブラリは利用可能です")
            // ライブラリを起動
            let imagePickerController = UIImagePickerController()
            imagePickerController.sourceType = .photoLibrary
            imagePickerController.delegate = self
            present(imagePickerController, animated: true, completion: nil)
        } else {
            print("ライブラリは利用できません")
            SVProgressHUD.showError(withStatus: "ライブラリにアクセスできません。アクセスを許可して下さい。")
        }
    }
    
    
    // 「カメラ」ボタンの処理
    @IBAction func handleCamaraButton(_ sender: Any) {
        // カメラが利用可能か判定
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            print("カメラは利用可能です")
            // カメラを起動
            let imagePickerController = UIImagePickerController()
            imagePickerController.sourceType = .camera
            imagePickerController.delegate = self
            present(imagePickerController, animated: true, completion: nil)
        } else {
            print("カメラは利用できません")
            SVProgressHUD.showError(withStatus: "カメラを起動できません。カメラを許可して下さい。")
        }
    }
    
    
    // 「キャンセル」ボタンの処理
    @IBAction func handleCancelButton(_ sender: Any) {
    }
    
    
    // 画像選択時に呼ばれるメソッド
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        // 画像を投稿内容編集画面に渡す
        selectImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage
        
        // CLImageEditorに画像を渡して、加工画面を起動する
//        let editor = CLImageEditor(image: selectImage)!
//        editor.delegate = self
//        picker.pushViewController(editor, animated: true)
        
        // 画面遷移
        self.performSegue(withIdentifier: "goPostViewController", sender: nil)
    }
    
    
    // キャンセルした時に呼ばれるメソッド
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        // 今開いている画面を閉じる
        picker.dismiss(animated: true, completion: nil)
    }
    
    
    // CLImageEditorでキャンセルされた時にこのメソッドで前の画面に戻る
    func imageEditorDidCancel(_ editor: CLImageEditor!) {
        editor.dismiss(animated: true, completion: nil)
    }
    
    
    // CLImageEditorで加工が終わった時に呼ばれるメソッド
    func imageEditor(_ editor: CLImageEditor!, didFinishEditingWith image: UIImage!) {
        // PostviewControllerのNavigationControllerのidentifierに "Post"を設定する
        let navigationController = self.storyboard?.instantiateViewController(withIdentifier: "goPostViewController") as! UINavigationController
        let viewControllers = navigationController.viewControllers;
        let postViewController = viewControllers[0] as! PostViewController;
        // 画像を受け取る
        postViewController.selectedImage = image
        editor.present(navigationController, animated: true, completion: nil)
    }
    
    
    //
    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        let pickerController = navigationController as! UIImagePickerController
        if pickerController.sourceType == .camera {
            viewController.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelButtonDidPush))
        }
    }

    
    //
    @objc func cancelButtonDidPush() {
        dismiss(animated: true, completion: nil)
    }
    
    // 画面遷移時に画像を渡す
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // 投稿内容編集画面のインスタンスを作成し、画像を渡す
        if let nextViewController = segue.destination as? PostViewController {
            nextViewController.selectedImage = selectImage
        }
    }
    
    // 画像選択画面に戻ってくるときに呼び出される処理
    @IBAction func goToImageSelect(_segue:UIStoryboardSegue){
        SVProgressHUD.showSuccess(withStatus: "投稿をキャンセルしました")
    }

}
