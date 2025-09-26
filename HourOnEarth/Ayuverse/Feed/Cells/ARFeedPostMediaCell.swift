//
//  ARFeedPostMediaCell.swift
//  HourOnEarth
//
//  Created by Paresh Dafda on 09/05/22.
//  Copyright © 2022 AyuRythm. All rights reserved.
//

import UIKit
import AVFoundation

// MARK: -
protocol ARFeedPostMediaCellDelegate {
    func feedPostMediaCell(cell: ARFeedPostMediaCell, didDeleteAt index: Int)
}

class ARFeedPostMediaCell: UICollectionViewCell {
    
    @IBOutlet weak var thumbIV: UIImageView!
    @IBOutlet weak var img_videoIcon: UIImageView!
    @IBOutlet weak var deleteBtn: UIButton!
    
    var delegate: ARFeedPostMediaCellDelegate?
    var count = 0
    override func awakeFromNib() {
        super.awakeFromNib()
        img_videoIcon.isHidden = true
        contentView.layer.cornerRadius = 0
        deleteBtn.isHidden = true
    }
    
    var isForCreatePostCell = false {
        didSet {
            if isForCreatePostCell {
                contentView.layer.cornerRadius = 10
                deleteBtn.isHidden = false
            } else {
                contentView.layer.cornerRadius = 0
                deleteBtn.isHidden = true
            }
            layoutIfNeeded()
        }
    }
    
    var particular_media: UIImage? {
        didSet {
            guard let media = media else { return }
            if count <= 5{
                deleteBtn.isHidden = (deleteBtn.tag == count - 1)
            }

            thumbIV.image = media["value"] as? UIImage
            
            layoutIfNeeded()
        }
    }
    
    var media: [String: Any]? {
        didSet {
            guard let media = media else { return }
            if count <= 5{
                deleteBtn.isHidden = (deleteBtn.tag == count - 1)
            }
            
            let str_Type = media["type"] as? String ?? ""
            if str_Type == "image" {
                self.img_videoIcon.isHidden = true
                if let imgg = media["value"] as? UIImage {
                    thumbIV.image = imgg
                }
            }
            else if str_Type == "video" {
                self.img_videoIcon.isHidden = false
                if let img_url = media["thumb"] as? UIImage {
                    thumbIV.image = img_url
                }
                else if let img_url = media["value"] as? URL {
                    let strThumURl = img_url.absoluteString.replacingOccurrences(of: img_url.pathExtension, with: "png")
                    if let str_imgURL = URL.init(string: strThumURl) {
                        thumbIV.sd_setImage(with: str_imgURL, placeholderImage: UIImage(named: "place_feed"))
                    }
                    else {
                        thumbIV.image = UIImage(named: "add-image")
                        DispatchQueue.global(qos: .userInitiated).async {
                            // Download file or perform expensive task
                            DispatchQueue.main.async {
                                // Update the UI
                                getThumbnailImageFromVideoUrl(url: img_url, completion: { imggggg in
                                    self.thumbIV.image = imggggg
                                })
                            }
                        }
                    }
                }
            }

            layoutIfNeeded()
        }
    }

    func getThumbnailImage(forUrl url: URL) -> UIImage? {
        let asset: AVAsset = AVAsset(url: url)
        let imageGenerator = AVAssetImageGenerator(asset: asset)

        do {
            let thumbnailImage = try imageGenerator.copyCGImage(at: CMTimeMake(value: 1, timescale: 60), actualTime: nil)
            return UIImage(cgImage: thumbnailImage)
        } catch let error {
            print(error)
        }

        return nil
    }
    
    var mediaData: String? {
        didSet {
            guard let str_media = mediaData else { return }
            self.img_videoIcon.isHidden = true
            if let strURL = URL.init(string: str_media) {
                if strURL.lastPathComponent.contains("jpg") || strURL.lastPathComponent.contains("jpeg") || strURL.lastPathComponent.contains("png") {
                    thumbIV.sd_setImage(with: strURL, placeholderImage: UIImage(named: "place_feed"))
                }
                else {
                    self.img_videoIcon.isHidden = false
                    let strThumURl = strURL.absoluteString.replacingOccurrences(of: strURL.pathExtension, with: "png")
                    if let str_imgURL = URL.init(string: strThumURl) {
                        thumbIV.sd_setImage(with: str_imgURL, placeholderImage: UIImage(named: "place_feed"))
                    }
                    else {
                        thumbIV.image = UIImage(named: "place_feed")
                        DispatchQueue.global(qos: .userInitiated).async {
                            // Download file or perform expensive task
                            DispatchQueue.main.async {
                                // Update the UI
                                getThumbnailImageFromVideoUrl(url: strURL, completion: { imggggg in
                                    self.thumbIV.image = imggggg
                                })
                            }
                        }
                    }
                }
            }
        }
    }
    
    @IBAction func deleteBtnPressed(sender: UIButton) {
        delegate?.feedPostMediaCell(cell: self, didDeleteAt: sender.tag)
    }
    
    
    func getThumbnailFrom(path: URL) -> UIImage? {
        do {
            let asset = AVURLAsset(url: path , options: nil)
            let imgGenerator = AVAssetImageGenerator(asset: asset)
            imgGenerator.appliesPreferredTrackTransform = true
            let cgImage = try imgGenerator.copyCGImage(at: CMTimeMake(value: 0, timescale: 1), actualTime: nil)
            let thumbnail = UIImage(cgImage: cgImage)
            return thumbnail
            
        } catch let error {
            print("*** Error generating thumbnail: \(error.localizedDescription)")
            return nil
        }
    }
}


