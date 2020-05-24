//
//  Downloads .swift
//  WhatsappBySid
//
//  Created by mac on 16/05/20.
//  Copyright © 2020 mac. All rights reserved.
//

import Foundation
import FirebaseStorage
import Firebase
import MBProgressHUD
import AVFoundation

let storage = Storage.storage()

//image

func uploadImage(image: UIImage, chatRoomId: String, view: UIView, completion: @escaping (_ imageLink: String?) -> Void) {
   
    let progressHUD = MBProgressHUD.showAdded(to: view, animated: true)
    
    progressHUD.mode = .determinateHorizontalBar
    
    let dateString = dateFormatter().string(from: Date())
    
    let photoFileName = "PictureMessages/" + FUser.currentId() + "/" + chatRoomId + "/" + dateString + ".jpg"
    
    print(photoFileName)
    
    let storageRef = storage.reference(forURL: kFILEREFERENCE).child(photoFileName)
    
    let imageData = image.jpegData(compressionQuality: 0.7)
    
    var task : StorageUploadTask!
    
    task = storageRef.putData(imageData!, metadata: nil, completion: { (metadata, error) in
        
        task.removeAllObservers()
        progressHUD.hide(animated: true)
        
        if error != nil{
            print("error uploading image \(error!.localizedDescription)")
            return
        }
        
        storageRef.downloadURL(completion: { (url, error) in
            guard let downloadUrl = url else{
                completion(nil)
                return
            }
            completion(downloadUrl.absoluteString)
        })
    })

    task.observe(StorageTaskStatus.progress) { (snapshot) in
        
        progressHUD.progress = Float((snapshot.progress?.completedUnitCount)!) / Float((snapshot.progress?.totalUnitCount)!)
    }


}








func downloadImage(imageUrl: String, completion: @escaping(_ image: UIImage?)-> Void){

    let imageURL = NSURL(string: imageUrl)
    print(imageUrl)

    let imageFileName = (imageUrl.components(separatedBy: "%").last!).components(separatedBy: "?").first!
    print("file name\(imageFileName)")
    
    if fileExistsAtPath(path: imageFileName){
        
        //exist
        if let contentsOfFile = UIImage(contentsOfFile: fileInDocumentsDirectory(fileName: imageFileName)){
            completion(contentsOfFile)
        }else{
            print("could not generate image")
            completion(nil)
        }
    }else{
        //doesnt exist
        let downloadQueue = DispatchQueue(label: "imageDownloadQueue")
        
        downloadQueue.async {
            let data = NSData(contentsOf: imageURL! as URL)
            
            if data != nil{
                var docURL = getDocumentsURL()
                docURL = docURL.appendingPathComponent(imageFileName, isDirectory: false)
                data!.write(to: docURL, atomically: true)

                let imageToReturn = UIImage(data: data! as Data)
                DispatchQueue.main.async {
                    completion(imageToReturn )
                }
            }else{
                DispatchQueue.main.async{
                    print("no image in database")
                    completion(nil)
                }
            }
        }
    }
}





func fileInDocumentsDirectory(fileName: String)-> String {
    let fileURL = getDocumentsURL().appendingPathComponent(fileName)
    return fileURL.path
}




func getDocumentsURL()-> URL {
    let documnetURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last
    return documnetURL!
}



func fileExistsAtPath(path: String)-> Bool {
    var doesExist = false
    let filePath = fileInDocumentsDirectory(fileName: path)
    let fileManager =  FileManager.default
    if fileManager.fileExists(atPath: filePath){
        doesExist = true
    }else{
        doesExist = false
    }
    return doesExist
}
