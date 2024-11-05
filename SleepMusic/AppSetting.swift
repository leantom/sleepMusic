//
//  AppSetting.swift
//  SleepMusic
//
//  Created by QuangHo on 1/11/24.
//

import Foundation
class AppSetting:ObservableObject {
    static let shared = AppSetting()
    
    @Published var isOpenFromWidget:Bool = false
    @Published var trackId:String = ""
}
