//
//  Globle.swift
//  RedButton
//
//  Created by Zignuts Technolab on 26/03/18.
//  Copyright © 2018 Zignuts Technolab. All rights reserved.
//
import Foundation
import UIKit
import AVFoundation
import Photos
import os.log
import PDFKit
//import SVProgressHUD

//MARK:- VARIABLES DECLARATION

var arr_DummyData_forChart = [480, 456, 440, 424, 408, 384, 376, 360, 344, 328, 320, 304, 288, 272, 264, 248, 232, 224, 216, 208, 200, 192, 184, 176, 176, 160, 160, 160, 168, 208, 248, 320, 368, 440, 488, 528, 536, 544, 536, 528, 520, 496, 488, 464, 440, 416, 400, 384, 376, 352, 344, 320, 320, 296, 288, 264, 256, 240, 232, 224, 216, 208, 208, 200, 192, 184, 176, 176, 176, 200, 232, 304, 320, 384, 440, 464, 480, 480, 480, 464, 456, 432, 424, 400, 392, 368, 360, 344, 336, 320, 320, 296, 288, 272, 264, 248, 240, 224, 216, 208, 200, 192, 192, 184, 176, 168, 168, 160, 160, 184, 208, 264, 312, 368, 408, 456, 472, 480, 480, 464, 456, 440, 432, 416, 400, 376, 368, 352, 344, 328, 320, 312, 296, 280, 264, 256, 248, 232, 224, 216, 208, 200, 200, 192, 184, 176, 176, 168, 160, 152, 152, 152, 168, 208, 248, 312, 352, 416, 456, 488, 496, 496, 496, 480, 472, 456, 448, 424, 408, 392, 376, 360, 352, 336, 328, 320, 304, 288, 280, 264, 248, 240, 232, 224, 216, 208, 200, 192, 184, 184, 176, 168, 168, 160, 160, 176, 216, 248, 312, 352, 416, 472, 488, 496, 496, 496, 480, 472, 456, 440, 424, 408, 392, 376, 360, 352, 336, 328, 320, 304, 288, 272, 264, 256, 240, 232, 224, 216, 208, 200, 192, 192, 184, 176, 168, 160, 160, 152, 168, 192, 240, 312, 352, 400, 456, 488, 504, 504, 496, 488, 472, 456, 448, 432, 416, 400, 384, 376, 360, 352, 336, 320, 312, 304, 288, 272, 256, 248, 240, 232, 224, 216, 208, 200, 192, 184, 176, 176, 168, 160, 152, 168, 184, 240, 280, 352, 400, 464, 496, 520, 520, 512, 504, 488, 480, 464, 448, 432, 416, 400, 392, 376, 360, 344, 336, 320, 304, 296, 280, 272, 256, 248, 240, 232, 224, 216, 208, 200, 192, 184, 176, 168, 168, 160, 168, 192, 232, 296, 336, 416, 464, 504, 520, 528, 520, 504, 488, 480, 464, 448, 432, 416, 400, 384, 376, 360, 352, 328, 320, 312, 296, 280, 272, 256, 248, 240, 232, 224, 216, 208, 200, 192, 184, 176, 176, 176, 192, 224, 264, 320, 376, 448, 488, 520, 528, 528, 520, 504, 496, 480, 464, 440, 432, 408, 392, 384, 368, 360, 336, 328, 312, 304, 288, 272, 264, 256, 240, 232, 224, 224, 208, 208, 200, 192, 184, 184, 176, 184, 216, 248, 312, 344, 416, 456, 504, 520, 520, 512, 504, 488, 472, 464, 440, 424, 408, 400, 384, 368, 352, 344, 328, 320, 304, 296, 280, 264, 256, 248, 240, 232, 224, 216, 208, 208, 200, 192, 184, 184, 184, 200, 240, 280, 336, 384, 448, 480, 504, 512, 504, 504, 488, 472, 456, 440, 424, 408, 392, 376, 360, 352, 336, 328, 312, 304, 288, 280, 264, 256, 248, 240, 232, 224, 216, 208, 200, 200, 192, 184, 176, 176, 184, 200, 240, 280, 344, 384, 464, 480, 504, 512, 504, 496, 480, 472, 456, 440, 424, 408, 392, 376, 360, 352, 336, 328, 312, 304, 288, 280, 264, 256, 240, 240, 224, 224, 216, 208, 200, 200, 192, 184, 176, 176, 184, 200, 248, 288, 344, 392, 456, 480, 504, 512, 504, 496, 480, 472, 456, 440, 416, 408, 384, 376, 360, 352, 336, 320, 304, 304, 288, 272, 264, 256, 240, 232, 224, 224, 208, 208, 200, 192, 184, 176, 168, 168, 168, 184, 216, 256, 320, 360, 432, 464, 504, 512, 512, 512, 496, 480, 464, 456, 432, 416, 400, 384, 368, 360, 344, 328, 320, 312, 296, 280, 264, 256, 248, 240, 232, 224, 216, 208, 200, 192, 184, 184, 176, 168, 160, 168, 184, 208, 264, 312, 376, 424, 480, 512, 520, 520, 512, 504, 488, 472, 456, 440, 424, 408, 392, 376, 360, 352, 336, 320, 312, 296, 280, 272, 256, 248, 240, 232, 224, 216, 208, 200, 192, 192, 184, 176, 168, 168, 176, 192, 240, 280, 352, 400, 464, 496, 528, 528, 528, 520, 496, 488, 464, 448, 432, 408, 392, 384, 368, 352, 336, 320, 312, 296, 280, 264, 248, 240, 232, 224, 216, 208, 200, 192, 184, 184, 168, 168, 160, 160, 176, 200, 256, 296, 368, 416, 472, 496, 504, 504, 488, 480, 456, 440, 416, 408, 384, 376, 360, 352, 336, 328, 320, 304, 288, 280, 256, 248, 240, 232, 224, 216, 208, 208, 216, 232, 272, 304, 360, 400, 456, 488, 512, 520, 512, 504, 480, 464, 432, 416, 400, 384, 376, 376, 368, 360, 344, 336, 320, 312, 288, 272, 256, 248, 240, 232, 224, 216, 208, 200, 192, 184, 184, 192, 224, 264, 320, 360, 424, 456, 488, 496, 496, 488, 472, 464, 440, 424, 408, 392, 368, 352, 336, 328, 312, 304, 280, 272, 256, 248, 232, 224, 216, 208, 200, 192, 184, 176, 168, 160, 152, 152, 144, 136, 144, 160, 208, 248, 320, 360, 424, 456, 488, 488, 488, 480, 472, 456, 440, 424, 408, 392, 368, 352, 336, 328, 320, 312, 288, 280, 264, 248, 240, 224, 216, 208, 200, 200, 192, 184, 176, 168, 168, 160, 152, 160, 184, 200, 248, 280, 328, 352, 384, 392, 464, 456, 424, 408, 376, 360, 336, 320, 296, 280, 264, 248, 232, 216, 192, 176, 152, 136, 112, 104, 88, 72, 64, 56, 48, 40, 32, 24, 8, 8, 16, 40, 104, 160, 248, 304, 368, 400, 408, 400, 384, 368, 344, 328, 320, 304, 280, 264, 248, 232, 224, 208, 192, 184, 176, 160, 144, 128, 120, 104, 96, 88, 80, 72, 64, 56, 56, 72, 96, 152, 200, 280, 320, 368, 384, 384, 376, 352, 344, 320, 312, 296, 280, 256, 240, 232, 224, 208, 200, 184, 176, 160, 144, 128, 120, 112, 104, 96, 96, 88, 88, 80, 80, 72, 64, 64, 72, 104, 136, 208, 256, 320, 360, 392, 400, 392, 376, 360, 352, 328, 320, 296, 272, 240, 216, 192, 184, 160, 152, 128, 120, 112, 96, 88, 80, 80, 80, 80, 80, 80, 80, 80, 80, 80, 80, 88, 88, 112, 144, 216, 272, 344, 400, 464, 496, 504, 496, 472, 456, 424, 408, 376, 360, 336, 328, 320, 312, 296, 288, 272, 264, 248, 232, 224, 216, 208, 200, 192, 192, 192, 192, 192, 192, 208, 232, 272, 312, 352, 384, 416, 432, 544, 528, 488, 456, 408, 384, 344, 328, 312, 304, 288, 280, 264, 248, 216, 200, 152, 128, 96, 80, 56, 40, 16, 8, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 88, 264, 384, 560, 648, 728, 744, 520, 504, 472, 464, 440, 424, 408, 392, 368, 352, 336, 328, 320, 304, 288, 280, 264, 248, 232, 224, 208, 200, 192, 184, 176, 168, 160, 160, 152, 144, 136, 128, 128, 144, 200, 248, 328, 384, 464, 504, 536, 536, 520, 504, 488, 472, 456, 448, 424, 408, 392, 376, 360, 352, 336, 320, 312, 296, 272, 264, 248, 240, 224, 216, 192, 176, 144, 104, 24, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 200, 352, 552, 648, 720, 728, 512, 496, 480, 464, 440, 432, 416, 408, 400, 392, 384, 376, 368, 368, 360, 352, 352, 352, 352, 352, 352, 344, 344, 344, 336, 328, 328, 328, 336, 352, 376, 400, 424, 440, 448, 448, 448, 440, 432, 528, 504, 496, 464, 456, 432, 424, 408, 392, 376, 368, 344, 328, 304, 288, 272, 256, 240, 224, 216, 208, 200, 192, 176, 168, 152, 144, 144, 160, 216, 280, 368, 440, 536, 576, 616, 624, 616, 600, 584, 568, 544, 528, 496, 480, 456, 432, 416, 400, 376, 352, 320, 312, 288, 264, 240, 232, 208, 200, 184, 176, 168, 152, 144, 136, 120, 112, 120, 128, 192, 256, 352, 464, 528, 576, 616, 624, 608, 592, 568, 552, 528, 504, 480, 464, 432, 424, 400, 384, 360, 344, 320, 304, 280, 264, 240, 224, 200, 192, 176, 168, 160, 144, 136, 128, 112, 104, 88, 88, 112, 152, 248, 352, 512, 544, 600, 640, 648, 632, 608, 584, 560, 536, 512, 488, 464, 440, 416, 400, 392, 368, 352, 320, 312, 280, 248, 232, 216, 200, 184, 176, 152, 144, 128, 120, 104, 96, 80, 80, 96, 128, 216, 288, 408, 488, 600, 648, 680, 672, 648, 632, 584, 576, 544, 528, 504, 480, 464, 448, 432, 416, 392, 376, 344, 328, 304, 280, 256, 240, 216, 200, 176, 168, 152, 144, 128, 120, 112, 96, 96, 104, 160, 216, 328, 408, 536, 600, 672, 688, 680, 664, 640, 616, 576, 536, 456, 392, 280, 200, 112, 80, 72, 104, 176, 232, 312, 352, 408, 392, 344, 296, 208, 144, 64, 24, 0, 0, 8, 40, 96, 144, 224, 280, 344, 392, 448, 496, 568, 616, 712, 784, 888, 936, 968, 632, 584, 520, 464, 408, 320, 272, 216, 192, 192, 216, 264, 304, 352, 368, 432, 400, 320, 256, 160, 104, 64, 80, 184, 304, 520, 680, 904, 1016, 1016, 1016, 1016, 704, 664, 640, 600, 568, 536, 512, 488, 464, 440, 424, 392, 376, 336, 320, 280, 256, 216, 208, 184, 168, 152, 136, 120, 104, 80, 64, 40, 24, 0, 0, 0, 32, 136, 232, 384, 488, 632, 696, 736, 736, 712, 504, 488, 472, 456, 440, 424, 416, 400, 384, 376, 360, 352, 336, 320, 312, 296, 280, 264, 240, 232, 224, 208, 208, 200, 192, 184, 176, 168, 160, 152, 152, 176, 208, 272, 320, 392, 440, 496, 512, 520, 512, 496, 488, 464, 456, 432, 424, 408, 392, 376, 368, 352, 344, 328, 320, 304, 288, 272, 256, 248, 240, 232, 232, 224, 224, 216, 208, 200, 192, 176, 168, 160, 176, 216, 264, 336, 392, 464, 520, 536, 536, 528, 512, 496, 488, 464, 456, 440, 424, 408, 400, 384, 376, 360, 344, 320, 312, 296, 280, 256, 248, 232, 224, 216, 208, 192, 176, 152, 128, 112, 96, 72, 72, 104, 152, 240, 304, 392, 448, 512, 528, 528, 528, 520, 520, 536, 552, 568, 584, 600, 624, 616, 600, 584, 552, 528, 488, 456, 440, 424, 416, 416, 424, 432, 440, 440, 440, 440, 440, 440, 432, 432, 528, 512, 472, 408, 392, 368, 328, 312, 280, 256, 224, 208, 176, 152, 128, 96, 72, 48, 8, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 96, 272, 384, 536, 616, 664, 664, 632, 600, 552, 528, 488, 456, 432, 416, 392, 376, 352, 328, 304, 272, 224, 192, 144, 112, 72, 48, 24, 16, 0, 0, 8, 32, 112, 200, 328, 432, 568, 640, 696, 704, 496, 472, 464, 448, 424, 416, 392, 384, 376, 368, 360, 352, 344, 328, 320, 304, 288, 264, 256, 240, 232, 224, 224, 240, 256, 312, 336, 400, 432, 472, 480, 480, 472, 448, 440, 416, 408, 392, 384, 368, 360, 352, 336, 328, 320, 304, 296, 272, 264, 248, 232, 224, 216, 208, 208, 208, 216, 248, 280, 320, 352, 392, 408, 416, 496, 472, 448, 416, 400, 376, 352, 328, 320, 296, 280, 256, 240, 216, 192, 160, 144, 120, 104, 88, 80, 72, 72, 72, 88, 128, 176, 264, 320, 416, 464, 520, 520, 504, 480, 440, 416, 384, 368, 344, 336, 320, 312, 296, 288, 264, 240, 216, 200, 168, 152, 136, 120, 112, 104, 96, 88, 96, 104, 160, 216, 312, 376, 472, 520, 552, 560, 536, 512, 480, 464, 440, 424, 400, 384, 360, 344, 320, 312, 296, 272, 248, 224, 200, 184, 160, 152, 128, 120, 112, 104, 88, 88, 88, 104, 160, 216, 312, 368, 464, 504, 536, 536, 512, 488, 456, 416, 408, 392, 376, 360, 344, 336, 320, 312, 288, 272, 248, 232, 200, 192, 160, 160, 144, 136, 120, 112, 104, 96, 96, 104, 152, 208, 304, 360, 448, 496, 536, 536, 512, 496, 456, 440, 416, 400, 376, 368, 344, 336, 320, 312, 296, 280, 248, 232, 208, 192, 176, 168, 152, 144, 136, 120, 104, 96, 88, 128, 152, 208, 304, 368, 464, 512, 552, 544, 520, 488, 464, 432, 416, 392, 384, 360, 352, 336, 320, 304, 288, 256, 240, 208, 192, 168, 152, 136, 120, 104, 104, 96, 88, 80, 72, 88, 120, 200, 272, 376, 440, 528, 560, 568, 544, 504, 480, 440, 416, 392, 376, 368, 360, 344, 336, 320, 304, 280, 256, 224, 208, 184, 168, 144, 136, 120, 112, 104, 96, 88, 80, 88, 104, 176, 248, 352, 432, 544, 600, 640, 632, 608, 584, 552, 528, 504, 480, 464, 448, 424, 408, 392, 376, 344, 328, 304, 280, 248, 224, 200, 184, 168, 152, 144, 136, 128, 120, 128, 152, 224, 288, 392, 464, 560, 608, 632, 624, 592, 568, 480, 480, 456, 440, 424, 408, 392, 384, 360, 328, 320, 296, 264, 240, 216, 200, 176, 168, 152, 144, 136, 128, 136, 160, 232, 304, 400, 480, 576, 616, 648, 648, 624, 608, 576, 560, 528, 512, 488, 456, 440, 424, 400, 384, 352, 328, 304, 288, 256, 232, 208, 192, 168, 160, 144, 128, 120, 112, 96, 96, 136, 184, 288, 360, 488, 568, 656, 680, 696, 680, 664, 648, 616, 592, 560, 536, 504, 480, 448, 432, 400, 384, 352, 328, 296, 272, 224, 184, 104, 32, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 72, 352, 520, 736, 824, 880, 872, 576, 560, 528, 512, 480, 464, 448, 432, 424, 416, 408, 400, 392, 384, 368, 360, 344, 336, 320, 320, 320, 320, 312, 320, 320, 344, 384, 416, 464, 496, 536, 552, 560, 552, 536, 528, 496, 480, 456, 440, 424, 416, 400, 392, 376, 368, 352, 336, 320, 304, 296, 280, 264, 256, 240, 232, 224, 216, 208, 200, 192, 184, 168, 160, 144, 136, 128, 120, 144, 168, 240, 320, 368, 424, 488, 520, 528, 520, 504, 480, 464, 448, 424, 408, 392, 384, 368, 360, 344, 336, 320, 312, 288, 280, 256, 240, 224, 208, 200, 192, 176, 176, 168, 160, 160, 152, 144, 136, 128, 120, 120, 136, 160, 224, 272, 352, 408, 472, 504, 520, 512, 496, 480, 456, 440, 424, 408, 392, 384, 368, 352, 328, 328, 320, 312, 288, 272, 256, 248, 232, 224, 208, 200, 200, 192, 184, 184, 176, 168, 160, 152, 144, 136, 136, 144, 176, 216, 288, 328, 400, 440, 480, 480, 464, 448, 424, 408, 392, 376, 360, 352, 328, 320, 312, 304, 296, 288, 280]


//MARK:- Storyboards
let Story_Main = UIStoryboard.init(name:"Main", bundle: nil)
let Story_Home = UIStoryboard(name: "Home", bundle: nil)
let Story_MyHome = UIStoryboard(name: "MyHome", bundle: nil)
let Story_ForYou = UIStoryboard(name: "ForYou", bundle: nil)
let Story_Profile = UIStoryboard(name: "Profile", bundle: nil)
let Story_InitialFlow = UIStoryboard(name: "InitialFlow", bundle: nil)
let Story_SparshnaResult = UIStoryboard(name: "SparshnaResult", bundle: nil)
let Story_PrakritiResult = UIStoryboard(name: "PrakritiResult", bundle: nil)
let Story_LoginSignup = UIStoryboard.init(name:"Login_Signup", bundle: nil)
let Story_Assessment = UIStoryboard.init(name:"Assessment", bundle: nil)
let Story_SideMenu = UIStoryboard.init(name:"SideMenu", bundle: nil)
let Story_Certificate = UIStoryboard.init(name:"Certificates", bundle: nil)
let Story_ChooseLang = UIStoryboard.init(name:"ChooseLanguage", bundle: nil)



let appDelegate = UIApplication.shared.delegate as! AppDelegate
let screenWidth = UIScreen.main.bounds.size.width
let screenHeight = UIScreen.main.bounds.size.height
let screenScale = screenWidth/320

let Min_Mobile_Number:Int = 9
let Max_Mobile_Number:Int = 15
var topConstraint: CGFloat = 0
var homeCollectionCell_Height: CGFloat = 211


//KPV Colors
let kapha_colors = [#colorLiteral(red: 0.4235294118, green: 0.7529411765, blue: 0.4078431373, alpha: 1), #colorLiteral(red: 0.7411764706, green: 0.8392156863, blue: 0.1882352941, alpha: 1), #colorLiteral(red: 1, green: 0.862745098, blue: 0.1882352941, alpha: 1)]  //6CC068, //BDD630, //FFDC30
let pitta_colors = [#colorLiteral(red: 0.9882352941, green: 0, blue: 0, alpha: 1), #colorLiteral(red: 1, green: 0.7960784314, blue: 0.1647058824, alpha: 1)]  //FC0000, //FFCB2A
let vata_colors = [#colorLiteral(red: 0.2352941176, green: 0.568627451, blue: 0.9019607843, alpha: 1), #colorLiteral(red: 0.737254902, green: 0.4078431373, blue: 0.7529411765, alpha: 1), #colorLiteral(red: 0.2352941176, green: 0.568627451, blue: 0.9019607843, alpha: 1)]  //3C91E6, //BC68C0, //3C91E6
//**********************************************************//


//MARK:- METHODS
public func makeCall(number:String)
{
    let url = URL.init(string:"tel://\(number)" )
    if UIApplication.shared.canOpenURL(url!) {
        if #available(iOS 10.0, *) {
            UIApplication.shared.open(url!, options: [:], completionHandler: nil)
        } else {
            UIApplication.shared.openURL(url!)
        }
    }
    else{
        debugPrint("This device unable to make call")
    }
}

//MARK:- USERDEFAULT
func AppSetArchiveObjectToUserDefault(_ params:Any, Key: String ) {
    //let data = NSKeyedArchiver.archivedData(withRootObject: params)
    //UserDefaults.appSetObject(data, forKey: Key)
}

func AppGetArchievedObjectFromUserDefault(Key:String) -> Any {
    //if let data = UserDefaults.appObjectForKey(Key) as? Data {
    //   if let storedData = NSKeyedUnarchiver.unarchiveObject(with: data){
    //       return storedData
    //   }
    //}
    return NSNull()
}
//******************************************************************************************************//
//******************************************************************************************************//

//MARK:- PROGRESS HUD
public func ShowProgressHud(message:String) {
    //SVProgressHUD.show(withStatus: message)
}

public func DismissProgressHud() {
    //SVProgressHUD.dismiss()
}



func randomString(length: Int = 10) -> String {
    let base = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
    var randomString: String = ""
    
    for _ in 0..<length {
        let randomValue = arc4random_uniform(UInt32(base.count))
        randomString += "\(base[base.index(base.startIndex, offsetBy: Int(randomValue))])"
    }
    return randomString
}


func ConvertedDateforDisplay(_ strDateTime: String) -> String {
    
    var strSchdule = ""
    let formatter = DateFormatter()
    formatter.dateFormat = "dd-MM-yyyy hh:mm a"
    if let yourDate = formatter.date(from: strDateTime) {
        //then again set the date format whhich type of output you need
        formatter.dateFormat = "dd MMM yyyy"
        // again convert your date to string
        strSchdule = formatter.string(from: yourDate)
    }
    
    return strSchdule
}

func ConvertedDateforDisplayFromTimeStamp(_ timestamp: Int) -> Date {
    
    var strSchduleDate = Date()
    
    let dateTimeStamp = Date(timeIntervalSince1970:Double(timestamp/1000))  //UTC time  //YOUR currentTimeInMiliseconds METHOD
    let dateFormatter = DateFormatter()
    dateFormatter.timeZone = NSTimeZone.local
    dateFormatter.dateFormat = "yyyy-MM-dd"
    dateFormatter.dateStyle = DateFormatter.Style.full
    dateFormatter.timeStyle = DateFormatter.Style.short
    
    strSchduleDate = dateTimeStamp
    
    return strSchduleDate
}

func isValidEmail(testStr:String) -> Bool {
    let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
    
    let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
    return emailTest.evaluate(with: testStr)
}

func ConvertedDayWithDateMonthforrDisplayFromTimeStamp(_ timestamp: Int) -> String {
    
    var strPassDate = ""
    var str_WeekDay = ""
    
    let dateTimeStamp = NSDate(timeIntervalSince1970:Double(timestamp/1000))  //UTC time  //YOUR currentTimeInMiliseconds METHOD
    let dateFormatter = DateFormatter()
    dateFormatter.timeZone = NSTimeZone.local
    dateFormatter.dateFormat = "yyyy-MM-dd hh:mm a"
    dateFormatter.dateStyle = DateFormatter.Style.full
    dateFormatter.timeStyle = DateFormatter.Style.short
    
    let strDateSelect = dateFormatter.string(from: dateTimeStamp as Date)
    print("Local Time", strDateSelect) //Local time
    
    let date3 = dateFormatter.date(from: strDateSelect)
    dateFormatter.dateFormat = "yyyy-MM-dd hh:mm a"
    let strSchdule = dateFormatter.string(from: date3 ?? Date())
    
    dateFormatter.dateFormat = "dd MMM,hh:mm a"
    let strConvertedDate = dateFormatter.string(from: date3 ?? Date())
    
    if let weekday = getDayOfWeek(strSchdule) {
        str_WeekDay = weekday
    }
    
    strPassDate = "\(str_WeekDay). \(strConvertedDate)"
    
    return strPassDate
}

func ConvertedDayWithDateMonthWithYearforrDisplayFromTimeStamp(_ timestamp: Int) -> String {
    
    var strPassDate = ""
    var str_WeekDay = ""
    
    let dateTimeStamp = NSDate(timeIntervalSince1970:Double(timestamp/1000))  //UTC time  //YOUR currentTimeInMiliseconds METHOD
    let dateFormatter = DateFormatter()
    dateFormatter.timeZone = NSTimeZone.local
    dateFormatter.dateFormat = "yyyy-MM-dd hh:mm a"
    dateFormatter.dateStyle = DateFormatter.Style.full
    dateFormatter.timeStyle = DateFormatter.Style.short
    
    let strDateSelect = dateFormatter.string(from: dateTimeStamp as Date)
    print("Local Time", strDateSelect) //Local time
    
    let date3 = dateFormatter.date(from: strDateSelect)
    dateFormatter.dateFormat = "yyyy-MM-dd hh:mm a"
    let strSchdule = dateFormatter.string(from: date3 ?? Date())
    
    dateFormatter.dateFormat = "dd MMM yyyy,hh:mm a"
    let strConvertedDate = dateFormatter.string(from: date3 ?? Date())
    
    if let weekday = getDayOfWeek(strSchdule) {
        str_WeekDay = weekday
    }
    
    strPassDate = "\(str_WeekDay). \(strConvertedDate)"
    
    return strPassDate
}


func ConvertedDayWithDateMonthWithiutDayforrDisplayFromTimeStamp(_ timestamp: Int) -> String {
    
    var strPassDate = ""
    
    let dateTimeStamp = NSDate(timeIntervalSince1970:Double(timestamp/1000))  //UTC time  //YOUR currentTimeInMiliseconds METHOD
    let dateFormatter = DateFormatter()
    dateFormatter.timeZone = NSTimeZone.local
    dateFormatter.dateFormat = "yyyy-MM-dd hh:mm a"
    dateFormatter.dateStyle = DateFormatter.Style.full
    dateFormatter.timeStyle = DateFormatter.Style.short
    
    let strDateSelect = dateFormatter.string(from: dateTimeStamp as Date)
    print("Local Time", strDateSelect) //Local time
    
    let date3 = dateFormatter.date(from: strDateSelect)
    dateFormatter.dateFormat = "dd MMM,hh:mm a"
    let strConvertedDate = dateFormatter.string(from: date3 ?? Date())
    
    strPassDate = "\(strConvertedDate)"
    
    return strPassDate
}

func ConvertedDayWithDateMonthforEdirTaskFromTimeStamp(_ timestamp: Int) -> String {
    
    var strPassDate = ""
    
    let dateTimeStamp = NSDate(timeIntervalSince1970:Double(timestamp/1000))  //UTC time  //YOUR currentTimeInMiliseconds METHOD
    let dateFormatter = DateFormatter()
    dateFormatter.timeZone = NSTimeZone.local
    dateFormatter.dateFormat = "d MMM yyyy, hh:mm a"
    dateFormatter.dateStyle = DateFormatter.Style.full
    dateFormatter.timeStyle = DateFormatter.Style.short
    let strDateSelect = dateFormatter.string(from: dateTimeStamp as Date)
    print("Local Time", strDateSelect) //Local time
    let date3 = dateFormatter.date(from: strDateSelect)
    dateFormatter.dateFormat = "d MMM yyyy, hh:mm a"
    let strConvertedDate = dateFormatter.string(from: date3 ?? Date())
    strPassDate = "\(strConvertedDate)"
    
    return strPassDate
}

func ConverteDisplayDateFromTimeStamp(_ timestamp: Int) -> String {
    
    var strPassDate = ""
    
    let dateTimeStamp = NSDate(timeIntervalSince1970:Double(timestamp/1000))  //UTC time  //YOUR currentTimeInMiliseconds METHOD
    let dateFormatter = DateFormatter()
    dateFormatter.timeZone = NSTimeZone.local
    dateFormatter.dateFormat = "yyyy-MM-dd hh:mm a"
    dateFormatter.dateStyle = DateFormatter.Style.full
    dateFormatter.timeStyle = DateFormatter.Style.short
    
    let strDateSelect = dateFormatter.string(from: dateTimeStamp as Date)
    print("Local Time", strDateSelect) //Local time
    
    let date3 = dateFormatter.date(from: strDateSelect)
    dateFormatter.dateFormat = "MMM dd, yyyy"
    let strConvertedDate = dateFormatter.string(from: date3 ?? Date())
    
    strPassDate = "\(strConvertedDate)"
    
    return strPassDate
}

func resize(_ image: UIImage) -> UIImage
{
    var actualHeight = Float(image.size.height)
    var actualWidth = Float(image.size.width)
    let maxHeight: Float = 500
    let maxWidth: Float = 500
    var imgRatio: Float = actualWidth / actualHeight
    let maxRatio: Float = maxWidth / maxHeight
    let compressionQuality: Float = 0.9
    //50 percent compression
    if actualHeight > maxHeight || actualWidth > maxWidth {
        if imgRatio < maxRatio {
            //adjust width according to maxHeight
            imgRatio = maxHeight / actualHeight
            actualWidth = imgRatio * actualWidth
            actualHeight = maxHeight
        }
        else if imgRatio > maxRatio {
            //adjust height according to maxWidth
            imgRatio = maxWidth / actualWidth
            actualHeight = imgRatio * actualHeight
            actualWidth = maxWidth
        }
        else {
            actualHeight = maxHeight
            actualWidth = maxWidth
        }
    }
    let rect = CGRect(x: 0.0, y: 0.0, width: CGFloat(actualWidth), height: CGFloat(actualHeight))
    UIGraphicsBeginImageContext(rect.size)
    image.draw(in: rect)
    let img = UIGraphicsGetImageFromCurrentImageContext()
    let imageData = img?.jpegData(compressionQuality: CGFloat(compressionQuality))
    UIGraphicsEndImageContext()
    return UIImage(data: imageData!) ?? UIImage()
}




func getDayOfWeek(_ today:String) -> String? {
    var strWeekDay = ""
    let formatter  = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd hh:mm a"
    guard let todayDate = formatter.date(from: today) else { return nil }
    let myCalendar = Calendar(identifier: .gregorian)
    let weekDay = myCalendar.component(.weekday, from: todayDate)
    
    if weekDay == 1 {
        strWeekDay = "Sun"
    }
    else if weekDay == 2 {
        strWeekDay = "Mon"
    }
    else if weekDay == 3 {
        strWeekDay = "Tue"
    }
    else if weekDay == 4 {
        strWeekDay = "Wed"
    }
    else if weekDay == 5 {
        strWeekDay = "Thu"
    }
    else if weekDay == 6 {
        strWeekDay = "Fri"
    }
    else if weekDay == 7 {
        strWeekDay = "Sat"
    }
    return strWeekDay
}


func ConvertedDateForDisplayFromTimeStamp(_ timestamp: Int) -> Date {
    
    let dateTimeStamp = NSDate(timeIntervalSince1970:Double(timestamp/1000))  //UTC time  //YOUR currentTimeInMiliseconds METHOD
    let dateFormatter = DateFormatter()
    dateFormatter.timeZone = NSTimeZone.local
    dateFormatter.dateFormat = "yyyy-MM-dd hh:mm a"
    dateFormatter.dateStyle = DateFormatter.Style.full
    dateFormatter.timeStyle = DateFormatter.Style.short
    
    let strDateSelect = dateFormatter.string(from: dateTimeStamp as Date)
    print("Local Time", strDateSelect) //Local time
    
    let date3 = dateFormatter.date(from: strDateSelect)
    dateFormatter.dateFormat = "dd/MM/yyyy"
    let strConvertedDate = dateFormatter.string(from: date3 ?? Date())
    
    let Date_Converted = dateFormatter.date(from: strConvertedDate)
    
    return Date_Converted ?? Date()
}

func getLinkFromString(str_Text: String) -> String {
    var str_urlll = ""
    let detector = try! NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue)
    let matches = detector.matches(in: str_Text, options: [], range: NSRange(location: 0, length: str_Text.utf16.count))
    
    for match in matches {
        guard let range = Range(match.range, in: str_Text) else { continue }
        str_urlll = String(str_Text[range])
        print("detected link==============>>\(str_urlll)")
    }
    return str_urlll
}

func getQueryStringParameter(url: String, param: String) -> String? {
    let strrtextt = url
    guard let url = URLComponents(string: strrtextt) else {
        
        if strrtextt.contains(param) {
            if strrtextt.contains("?") {
                let arr_word = strrtextt.components(separatedBy: "?")
                if (arr_word.last ?? "").contains("&") {
                    let arr_Sword = (arr_word.last ?? "").components(separatedBy: "&")
                    var strwordsss = arr_Sword.first ?? ""
                    var strdescccc = arr_Sword.last ?? ""
                    
                    if strwordsss.contains("=") {
                        let arr_strwordsss = strwordsss.components(separatedBy: "=")
                        strwordsss = arr_strwordsss.last ?? ""
                    }
                    
                    if strdescccc.contains("=") {
                        let arr_strdescccc = strdescccc.components(separatedBy: "=")
                        strdescccc = arr_strdescccc.last ?? ""
                    }
                    
                    
                    if param == "word" {
                        return strwordsss
                    }
                    if param == "description" {
                        return strdescccc
                    }
                }
            }
        }
        
        return nil
    }
    return url.queryItems?.first(where: { $0.name == param })?.value
}

func getCurrentUTCDate_Time() -> String{
    let formater = DateFormatter()
    formater.timeZone = TimeZone(identifier: "UTC")
    formater.dateFormat = "yyyy-MM-dd HH:mm:ss"
    
    let strDate = formater.string(from: Date())
    
    return strDate
}

func getCurrentDate(_ date_format: String = "yyyy-MM-dd") -> String {
    let formater = DateFormatter()
    formater.dateFormat = date_format
    let strDate = formater.string(from: Date())
    return strDate
}

func getCurrentFullDateTime() -> String {
    
    var strPassDate = ""
    var str_WeekDay = ""
    
    let dateFormatter = DateFormatter()
    dateFormatter.timeZone = NSTimeZone.local
    dateFormatter.dateFormat = "yyyy-MM-dd hh:mm a"
    dateFormatter.dateStyle = DateFormatter.Style.full
    dateFormatter.timeStyle = DateFormatter.Style.short
    
    let strDateSelect = dateFormatter.string(from: Date())
    print("Local Time", strDateSelect) //Local time
    
    let date3 = dateFormatter.date(from: strDateSelect)
    dateFormatter.dateFormat = "yyyy-MM-dd hh:mm a"
    let strSchdule = dateFormatter.string(from: date3 ?? Date())
    
    dateFormatter.dateFormat = "dd MMM,hh:mm a"
    let strConvertedDate = dateFormatter.string(from: date3 ?? Date())
    
    if let weekday = getDayOfWeek(strSchdule) {
        str_WeekDay = weekday
    }
    
    strPassDate = "\(str_WeekDay). \(strConvertedDate)"
    
    return strPassDate
}

func getCurrentDate_TimeForChat() -> Date {
    let formater = DateFormatter()
    formater.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
    let strDate = formater.string(from: Date())
    let str_Date = formater.date(from: strDate)
    
    return str_Date ?? Date()
}


func getCurrentMillis(date: Date)->Int64{
    return  Int64(date.timeIntervalSince1970 * 1000)
}


func get_Day_Status() -> String {
    
    var str_Status = ""
    let hour = Calendar.current.component(.hour, from: Date())
    let minute = Calendar.current.component(.minute, from: Date())
    
    let str = "\(hour).\(minute)"
    let doubleStr = Double(str) ?? 0.0
    let hour_min = doubleStr.roundToDecimal()
    
    switch hour_min {
    case 5.0..<11.60 : str_Status = "Good Morning"
    case 12.0..<16.60 : str_Status = "Good Afternoon"
    case 17.0..<23.60 : str_Status = "Good Evining"
    default: str_Status = "Good Evining"
    }
    
    return str_Status
    
}



func LocalizationStringggggg(_ text : String) -> String {
    let alertTitle = NSLocalizedString(text, comment: "")
    return alertTitle
}

//MARK:- API call to fatch available seeds
func get_AvailableSeeds(completion:@escaping (Int)->Void) {

    if Utils.isConnectedToNetwork() {
        let params = ["language_id" : Utils.getLanguageId()] as [String : Any]
        Utils.doAPICall(endPoint: .Available_ayuseedinfo, parameters: params, headers: Utils.apiCallHeaders) {  isSuccess, status, message, responseJSON in
            if isSuccess, let responseJSON = responseJSON {
                let ayuseeds = responseJSON["ayuseeds"].intValue
                completion(ayuseeds)
            }
        }
    }
}



//MARK:- UIALERT VIEW
func showSingleAlert(Title:String, Message:String, buttonTitle:String, delegate:UIViewController? = appDelegate.window?.rootViewController, completion:@escaping ()->Void) {
    if let parentVC = delegate{
        let alertConfirm = UIAlertController(title: Title, message: Message, preferredStyle: .alert)
        let actOk = UIAlertAction(title: buttonTitle, style: .default) { (finish) in
            completion()
        }
        alertConfirm.addAction(actOk)
        parentVC.present(alertConfirm, animated: true, completion: nil)
    }
    
}


//MARK:- JSON METHOD
func jsonToStringFrom(from object:Any) -> String? {
    guard let data = try? JSONSerialization.data(withJSONObject: object, options: []) else {
        return nil
    }
    return String(data: data, encoding: String.Encoding.utf8)
}

func stringToJson(from jsonString:String) -> Any?{
    let data = jsonString.data(using: .utf8)!
    do {
        let jsonArray = try JSONSerialization.jsonObject(with: data, options : .allowFragments)
        return jsonArray
        
    } catch let error as NSError {
        print(error)
    }
    return nil
}


//MARK:- FORMATED JSON
func JSONStringify(value: AnyObject,prettyPrinted:Bool = false) -> String{
    
    let options = prettyPrinted ? JSONSerialization.WritingOptions.prettyPrinted : JSONSerialization.WritingOptions(rawValue: 0)
    if JSONSerialization.isValidJSONObject(value) {
        do{
            let data = try JSONSerialization.data(withJSONObject: value, options: options)
            if let string = NSString(data: data, encoding: String.Encoding.utf8.rawValue) {
                return string as String
            }
        }catch {
            
            print("error")
            //Access error here
        }
    }
    return ""
}

//MARK:- Get File Size

func fileSize(forURL url: Any) -> Double {
    var fileURL: URL?
    var fileSize: Double = 0.0
    if (url is URL) || (url is String)
    {
        if (url is URL) {
            fileURL = url as? URL
        }
        else {
            fileURL = URL(fileURLWithPath: url as! String)
        }
        var fileSizeValue = 0.0
        try? fileSizeValue = (fileURL?.resourceValues(forKeys: [URLResourceKey.fileSizeKey]).allValues.first?.value as! Double?)!
        if fileSizeValue > 0.0 {
            fileSize = (Double(fileSizeValue) / (1024 * 1024))
        }
    }
    return fileSize
}

func getThumbnailImageFromVideoUrl(url: URL, completion: @escaping ((_ image: UIImage?)->Void)) {
    DispatchQueue.global().async { //1
        let asset = AVAsset(url: url) //2
        let avAssetImageGenerator = AVAssetImageGenerator(asset: asset) //3
        avAssetImageGenerator.appliesPreferredTrackTransform = true //4
        let thumnailTime = CMTimeMake(value: 2, timescale: 1) //5
        do {
            let cgThumbImage = try avAssetImageGenerator.copyCGImage(at: thumnailTime, actualTime: nil) //6
            let thumbNailImage = UIImage(cgImage: cgThumbImage) //7
            DispatchQueue.main.async { //8
                completion(thumbNailImage) //9
            }
        } catch {
            print(error.localizedDescription) //10
            DispatchQueue.main.async {
                completion(nil) //11
            }
        }
    }
}

func pdfThumbnail(url: URL, width: CGFloat = 240) -> UIImage? {
    guard let data = try? Data(contentsOf: url),
          let page = PDFDocument(data: data)?.page(at: 0) else {
        return nil
    }
    
    let pageSize = page.bounds(for: .mediaBox)
    let pdfScale = width / pageSize.width
    
    // Apply if you're displaying the thumbnail on screen
    let scale = UIScreen.main.scale * pdfScale
    let screenSize = CGSize(width: pageSize.width * scale,
                            height: pageSize.height * scale)
    
    return page.thumbnail(of: screenSize, for: .mediaBox)
}


//MARK:- SIMPLE PRINT METHODS
func printFonts() {
    let fontFamilyNames = UIFont.familyNames
    for familyName in fontFamilyNames {
        debugPrint("------------------------------")
        debugPrint("Font Family Name = [\(familyName)]")
        let names = UIFont.fontNames(forFamilyName: familyName)
        debugPrint("Font Names = [\(names)]")
    }
}

//MARK:- DATE FUNCTIONS
func currentTimeInMiliseconds(currentDate:Date = Date()) -> Int {
    let since1970 = currentDate.timeIntervalSince1970
    return Int(since1970 * 1000)
}

func dateFromMilliseconds(milisecond:Int) -> Date {
    return Date(timeIntervalSince1970: TimeInterval(milisecond)/1000)
}

func getYesterdayDate() -> String{
    //let formater = DateFormatter()
    //formater.dateFormat = "yyyy-MM-dd"
    //let strDate = formater.string(from: Date.yesterday)
    return ""// strDate
}

//MARK: DATE FORMATE
func convertGetFormatedDate(fromDate:String, fromFormate:String, ToFormate:String, timezone:String = "UTC", isreport:Bool = false) -> String{
    let formater = DateFormatter()
    formater.timeZone = TimeZone(identifier: timezone)
    formater.dateFormat = fromFormate
    if let serverDate = formater.date(from: fromDate){
        formater.dateFormat = ToFormate
        if isreport {formater.timeZone = TimeZone.current}
        return formater.string(from: serverDate)
    }
    return fromDate
}
func convertGetDateFromJson(fromDate:String, fromFormate:String, ToFormate:String) -> Date?{
    let formater = DateFormatter()
    formater.timeZone = TimeZone(identifier: "UTC")
    formater.dateFormat = fromFormate
    if let serverDate = formater.date(from: fromDate){
        formater.dateFormat = ToFormate
        //        formater.timeZone = TimeZone.current
        let strdate = formater.string(from: serverDate)
        return formater.date(from: strdate)
    }
    return nil
}



func formatedStringFromDate(Date2Formate:Date, strFormate:String, timezone:String = (TimeZone.current.identifier)) -> String {
    let dFormater = DateFormatter()
    dFormater.dateFormat = strFormate
    dFormater.timeZone = TimeZone.init(identifier: timezone)
    return dFormater.string(from: Date2Formate)
}

//MARK:- VALIDATIONS
func isValidPassword(password:String) -> Bool {
    return password.count > 5
    //let emailPred = NSPredicate(format:"SELF MATCHES %@", ValidationExpression.password)
    //return emailPred.evaluate(with: password)
}

func is_PasswordValidation(testStr:String?) -> Bool {
    guard testStr != nil else { return false }
    
    // at least one uppercase,
    // at least one digit
    // at least one lowercase
    // 8 characters total
    let passwordTest = NSPredicate(format: "SELF MATCHES %@", "(?=.*[a-z])(?=.*[0-9])(?=.*[a-z]).{8,}")
    return passwordTest.evaluate(with: testStr)
}

func isValidValue(_ object:Any? = nil) -> Bool{
    if object == nil{
        return false
    }
    
    if object as? NSNull != nil{
        return false
    }
    
    return true
}


//MARK:- Get Distance from One latitude or longitude
func getDistanceBetweenTwoLat_Long(firstLat_long: CLLocationCoordinate2D, secondLat_long: CLLocationCoordinate2D) -> String {
    //First location
    let first_Location = CLLocation(latitude: firstLat_long.latitude, longitude: firstLat_long.longitude)
    
    //Second location
    let second_Location = CLLocation(latitude: secondLat_long.latitude, longitude: secondLat_long.longitude)
    
    //Measuring my distance to my buddy's (in km)
    let distance = first_Location.distance(from: second_Location) / 1000
    
    //Display the result in km
    print(String(format: "Particular distance is %.01f KM", distance))
    
    return "\(Int(distance.rounded()))"
}




//MARK:- Session Helper

func clearDataOnLogout() {
    //Removes persistant login detail from userdefault
    //UserDefaults.standard.removeObject(forKey: NSUDKey.userData)
    UIApplication.shared.applicationIconBadgeNumber = 0
}


//MARK: - Setup Attribute Text
func setupAttributedText(str_FullText: String, fullTextFont: UIFont, fullTextColor: UIColor, highlightText1: String, highlightText1Font: UIFont, highlightText1Color: UIColor, highlightText2: String, highlightText2Font: UIFont, highlightText2Color: UIColor, lbl_attribute: UILabel) {
    let newText = NSMutableAttributedString.init(string: str_FullText)
    let paragraphStyle = NSMutableParagraphStyle()
    paragraphStyle.lineSpacing = 1.26 // Whatever line spacing you want in points
    paragraphStyle.alignment = .left
    
    newText.addAttribute(NSAttributedString.Key.paragraphStyle, value:paragraphStyle, range: NSRange.init(location: 0, length: newText.length))
    newText.addAttribute(NSAttributedString.Key.font, value: fullTextFont, range: NSRange.init(location: 0, length: newText.length))
    newText.addAttribute(NSAttributedString.Key.foregroundColor, value: fullTextColor, range: NSRange.init(location: 0, length: newText.length))
    
    let textRange = NSString(string: str_FullText)
    let highlight_range = textRange.range(of: highlightText1)
    newText.addAttribute(NSAttributedString.Key.font, value: highlightText1Font, range: highlight_range)
    newText.addAttribute(NSAttributedString.Key.foregroundColor, value: highlightText1Color, range: highlight_range)
    
    let highlight_rangeKPV = textRange.range(of: highlightText2)
    newText.addAttribute(NSAttributedString.Key.font, value: highlightText2Font, range: highlight_rangeKPV)
    newText.addAttribute(NSAttributedString.Key.foregroundColor, value: highlightText2Color, range: highlight_rangeKPV)
    
    lbl_attribute.attributedText = newText
}




func verifyUrl (urlString: String?) -> Bool {
    //Check for nil
    if let urlString = urlString {
        // create NSURL instance
        if let url = URL(string: urlString) {
            // check if your application can open the NSURL instance
            return UIApplication.shared.canOpenURL(url)
        }
    }
    return false
}


func imageOrientation(fromDevicePosition devicePosition: AVCaptureDevice.Position = .back) -> UIImage.Orientation {
    var deviceOrientation = UIDevice.current.orientation
    if deviceOrientation == .faceDown || deviceOrientation == .faceUp || deviceOrientation == .unknown {
        deviceOrientation = currentUIOrientation()
    }
    switch deviceOrientation {
    case .portrait:
        return devicePosition == .front ? .leftMirrored : .right
    case .landscapeLeft:
        return devicePosition == .front ? .downMirrored : .up
    case .portraitUpsideDown:
        return devicePosition == .front ? .rightMirrored : .left
    case .landscapeRight:
        return devicePosition == .front ? .upMirrored : .down
    case .faceDown, .faceUp, .unknown:
        return .up
    @unknown default:
        fatalError()
    }
}

func currentUIOrientation() -> UIDeviceOrientation {
    let deviceOrientation = { () -> UIDeviceOrientation in
        switch UIApplication.shared.statusBarOrientation {
        case .landscapeLeft:
            return .landscapeRight
        case .landscapeRight:
            return .landscapeLeft
        case .portraitUpsideDown:
            return .portraitUpsideDown
        case .portrait, .unknown:
            return .portrait
        @unknown default:
            fatalError()
        }
    }
    guard Thread.isMainThread else {
        var currentOrientation: UIDeviceOrientation = .portrait
        DispatchQueue.main.sync {
            currentOrientation = deviceOrientation()
        }
        return currentOrientation
    }
    return deviceOrientation()
}

func getCountryPhonceCode (_ country : String) -> String {
    
    let countryDictionary  = ["AF":"93",
                              "AL":"355",
                              "DZ":"213",
                              "AS":"1",
                              "AD":"376",
                              "AO":"244",
                              "AI":"1",
                              "AG":"1",
                              "AR":"54",
                              "AM":"374",
                              "AW":"297",
                              "AU":"61",
                              "AT":"43",
                              "AZ":"994",
                              "BS":"1",
                              "BH":"973",
                              "BD":"880",
                              "BB":"1",
                              "BY":"375",
                              "BE":"32",
                              "BZ":"501",
                              "BJ":"229",
                              "BM":"1",
                              "BT":"975",
                              "BA":"387",
                              "BW":"267",
                              "BR":"55",
                              "IO":"246",
                              "BG":"359",
                              "BF":"226",
                              "BI":"257",
                              "KH":"855",
                              "CM":"237",
                              "CA":"1",
                              "CV":"238",
                              "KY":"345",
                              "CF":"236",
                              "TD":"235",
                              "CL":"56",
                              "CN":"86",
                              "CX":"61",
                              "CO":"57",
                              "KM":"269",
                              "CG":"242",
                              "CK":"682",
                              "CR":"506",
                              "HR":"385",
                              "CU":"53",
                              "CY":"537",
                              "CZ":"420",
                              "DK":"45",
                              "DJ":"253",
                              "DM":"1",
                              "DO":"1",
                              "EC":"593",
                              "EG":"20",
                              "SV":"503",
                              "GQ":"240",
                              "ER":"291",
                              "EE":"372",
                              "ET":"251",
                              "FO":"298",
                              "FJ":"679",
                              "FI":"358",
                              "FR":"33",
                              "GF":"594",
                              "PF":"689",
                              "GA":"241",
                              "GM":"220",
                              "GE":"995",
                              "DE":"49",
                              "GH":"233",
                              "GI":"350",
                              "GR":"30",
                              "GL":"299",
                              "GD":"1",
                              "GP":"590",
                              "GU":"1",
                              "GT":"502",
                              "GN":"224",
                              "GW":"245",
                              "GY":"595",
                              "HT":"509",
                              "HN":"504",
                              "HU":"36",
                              "IS":"354",
                              "IN":"91",
                              "ID":"62",
                              "IQ":"964",
                              "IE":"353",
                              "IL":"972",
                              "IT":"39",
                              "JM":"1",
                              "JP":"81",
                              "JO":"962",
                              "KZ":"77",
                              "KE":"254",
                              "KI":"686",
                              "KW":"965",
                              "KG":"996",
                              "LV":"371",
                              "LB":"961",
                              "LS":"266",
                              "LR":"231",
                              "LI":"423",
                              "LT":"370",
                              "LU":"352",
                              "MG":"261",
                              "MW":"265",
                              "MY":"60",
                              "MV":"960",
                              "ML":"223",
                              "MT":"356",
                              "MH":"692",
                              "MQ":"596",
                              "MR":"222",
                              "MU":"230",
                              "YT":"262",
                              "MX":"52",
                              "MC":"377",
                              "MN":"976",
                              "ME":"382",
                              "MS":"1",
                              "MA":"212",
                              "MM":"95",
                              "NA":"264",
                              "NR":"674",
                              "NP":"977",
                              "NL":"31",
                              "AN":"599",
                              "NC":"687",
                              "NZ":"64",
                              "NI":"505",
                              "NE":"227",
                              "NG":"234",
                              "NU":"683",
                              "NF":"672",
                              "MP":"1",
                              "NO":"47",
                              "OM":"968",
                              "PK":"92",
                              "PW":"680",
                              "PA":"507",
                              "PG":"675",
                              "PY":"595",
                              "PE":"51",
                              "PH":"63",
                              "PL":"48",
                              "PT":"351",
                              "PR":"1",
                              "QA":"974",
                              "RO":"40",
                              "RW":"250",
                              "WS":"685",
                              "SM":"378",
                              "SA":"966",
                              "SN":"221",
                              "RS":"381",
                              "SC":"248",
                              "SL":"232",
                              "SG":"65",
                              "SK":"421",
                              "SI":"386",
                              "SB":"677",
                              "ZA":"27",
                              "GS":"500",
                              "ES":"34",
                              "LK":"94",
                              "SD":"249",
                              "SR":"597",
                              "SZ":"268",
                              "SE":"46",
                              "CH":"41",
                              "TJ":"992",
                              "TH":"66",
                              "TG":"228",
                              "TK":"690",
                              "TO":"676",
                              "TT":"1",
                              "TN":"216",
                              "TR":"90",
                              "TM":"993",
                              "TC":"1",
                              "TV":"688",
                              "UG":"256",
                              "UA":"380",
                              "AE":"971",
                              "GB":"44",
                              "US":"1",
                              "UY":"598",
                              "UZ":"998",
                              "VU":"678",
                              "WF":"681",
                              "YE":"967",
                              "ZM":"260",
                              "ZW":"263",
                              "BO":"591",
                              "BN":"673",
                              "CC":"61",
                              "CD":"243",
                              "CI":"225",
                              "FK":"500",
                              "GG":"44",
                              "VA":"379",
                              "HK":"852",
                              "IR":"98",
                              "IM":"44",
                              "JE":"44",
                              "KP":"850",
                              "KR":"82",
                              "LA":"856",
                              "LY":"218",
                              "MO":"853",
                              "MK":"389",
                              "FM":"691",
                              "MD":"373",
                              "MZ":"258",
                              "PS":"970",
                              "PN":"872",
                              "RE":"262",
                              "RU":"7",
                              "BL":"590",
                              "SH":"290",
                              "KN":"1",
                              "LC":"1",
                              "MF":"590",
                              "PM":"508",
                              "VC":"1",
                              "ST":"239",
                              "SO":"252",
                              "SJ":"47",
                              "SY":"963",
                              "TW":"886",
                              "TZ":"255",
                              "TL":"670",
                              "VE":"58",
                              "VN":"84",
                              "VG":"284",
                              "VI":"340"]
    if countryDictionary[country] != nil {
        return countryDictionary[country]!
    }
    
    else {
        return ""
    }
    
}




extension Date {
    var millisecondsSince1970:Int64 {
        return Int64((self.timeIntervalSince1970 * 1000.0).rounded())
        //RESOLVED CRASH HERE
    }
    
    init(milliseconds:Int) {
        self = Date(timeIntervalSince1970: TimeInterval(milliseconds / 1000))
    }
}


extension Double {
    func roundToDecimal(_ fractionDigits: Int = 2) -> Double {
        let multiplier = pow(10, Double(fractionDigits))
        return Darwin.round(self * multiplier) / multiplier
    }
}


extension CLLocation {
    func fetchCityAndCountry(completion: @escaping (_ city: String?, _ country:  String?, _ error: Error?) -> ()) {
        CLGeocoder().reverseGeocodeLocation(self) { completion($0?.first?.locality, $0?.first?.country, $1) }
    }
}
