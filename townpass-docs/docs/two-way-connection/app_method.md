---
title: "app_method"
source_url: "https://townpass.taipei/docs/two-way-connection/app_method.html"
source_path: "docs/two-way-connection/app_method.md"
retrieved_at: "2026-10-04"
---

userinfoweb 呼叫範例 json`{  "name": "userinfo",  "data": null }`app 回傳 Accountid: 使用者唯一序號  
*string*account: 使用者帳號  
*string*username: 使用者名稱  
*string*realName: 真實姓名  
*string*idNo: 身分證字號  
*string*email: 電子郵件  
*string*phoneNo: 手機號碼  
*string*birthday: 生日  
*string*memberType: 會員類別  
*string*  
*"personal": 一般會員*  
`"organization": 組織會員 "foreigner": 外籍人士 "employee": 北市府機關員工 `verifyLevel: 會員驗證等級  
*string**0: 未驗證*  
 > *大於 0: 已實名*  
addresses: 通訊地址  
*array[Address]*Address:zip3: 郵遞區號  
*int*city: 鄉鎮市  
*string*town: 市區  
*string*village: 鄰里  
*string*street: 街道  
*string*usageType: 標記型態  
*string**0: 其他*  
 > *1: 住家*  
 > *2: 公司*  
seq: 序號  
*int*priority: 是否為預設地址  
*bool*residentAddress: 戶籍地址  
*string*citizen: 是否為台北市民  
*bool*nativePeople: 是否為原住民  
*bool*cityInternetUid: 舊網路市民 ID  
*string*app 回傳範例 json`{  "name": "userinfo",  "data": {  "id": "7f3562f4-bb3f-4ec7-89b9-da3b4b5ff250",  "account": "wz7786",  "username": "Wesley",  "realName": "金大森",  "idNo": "A123456789",  "email": "ist83903@bcaoo.com",  "phoneNo": "0932166777",  "birthday": "1988/12/12",  "memberType": "personal",  "verifyLevel": "3",  "addresses": [  {  "zip3": 104,  "city": "臺北市",  "town": "中山區",  "village": "正得里",  "street": "吉林路",  "usageType": "0",  "seq": 1,  "priority": true  }  ],  "residentAddress": "臺北市中山區吉林路 69 號 4 樓",  "citizen": true,  "nativePeople": false,  "cityInternetUid": ""  } }`launch_mapweb 呼叫範例 json`{  "name": "launch_map",  "data": "https://maps.app.goo.gl/sQKx4n3WctXuS5Bw8" }`app 回傳 bool: 可否開啟地圖功能app 回傳範例 json`{  "name": "launch_map",  "data": true }`phone_callweb 呼叫範例 json`{  "name": "phone_call",  "data": "02-1234-5678" }`app 回傳 bool: 可否開啟電話功能app 回傳範例 json`{  "name": "phone_call",  "data": bool }`locationweb 呼叫範例 json`{  "name": "location",  "data": null }`app 回傳 Position [詳見 GeoLocator - Position](https://pub.dev/documentation/geolocator/latest/geolocator/Position-class.html)accuracy: 水平精準度(公尺)  
*double*altitude: 高度(公尺)  
*double*altitude*accuracy: 高度精準度(公尺)  
 _double*floor: 樓層  
*int*, *nullable*heading: 移動中的朝向方向  
*double*heading*accuracy: 移動中的朝向方向精準度(度)  
 _double*is*mocked: 是否為模擬定位數據(Android API lvl 18 後版本)  
 _bool*latitude: 緯度(-90.0(含) ~ +90.0(含))  
*double*longitude: 經度(-180.0(不含) ~ +180.0(含))  
*double*speed: 移動速度(公尺/秒)  
*double*speed*accuracy: 移動速度精準度(公尺/秒)  
 _double*timestamp: 當前數據取得時間(ms)  
*int*app 回傳範例 json`{  "name": "location",  "data": {  "longitude": -121.406417,  "latitude": 38.785834,  "timestamp": 1724466344054,  "accuracy": 5.0,  "altitude": 0.0,  "altitude_accuracy": 0.0,  "floor": null,  "heading": -1.0,  "heading_accuracy": -1.0,  "speed": 0.0,  "speed_accuracy": 0.0,  "is_mocked": true  } }`deviceinfoweb 呼叫範例 json`{  "name": "deviceinfo",  "data": null }`app 回傳範例 ios可參考： [UIDevice](https://developer.apple.com/documentation/uikit/uidevice#1658512), [utsname](https://pubs.opengroup.org/onlinepubs/009695399/basedefs/sys/utsname.h.html)  
json`{  "systemName": "iOS",  "isPhysicalDevice": false,  "utsname": {  "release": "23.6.0",  "sysname": "Darwin",  "nodename": "xxx-MBP",  "machine": "iPhone16,1",  "version": "Darwin Kernel Version xxx: ..."  },  "model": "iPhone",  "localizedModel": "iPhone",  "systemVersion": "17.x",  "name": "iPhone xxx",  "identifierForVendor": "xxx-xxx-xxxx-..." }`android可參考：[android.os.Build](https://developer.android.com/reference/android/os/Build#summary)json`{  "product": "sdk_gphone64_arm64",  "supportedAbis": [  "arm64-v8a"  ],  "serialNumber": "unknown",  "supported32BitAbis": [],  "display": "AP31.xxxx.xxx",  "type": "user",  "isPhysicalDevice": false,  "version": {  "baseOS": "",  "securityPatch": "2024-xx-xx",  "sdkInt": 34,  "release": "14",  "codename": "VanillaIceCream",  "previewSdkInt": 1,  "incremental": "11566045"  },  "systemFeatures": [  "android.hardware.sensor.proximity",  "android.software.adoptable_storage",  ...  ],  "manufacturer": "Google",  "tags": "release-keys",  "supported64BitAbis": [  "arm64-v8a"  ],  "bootloader": "unknown",  "fingerprint": "google/sdk_gphone64_arm64/...",  "host": "x-xxx-...",  "isLowRamDevice": false,  "model": "sdk_gphone64_arm64",  "id": "AP31.xxxx.xxx",  "brand": "google",  "device": "emu64a",  "board": "goldfish_arm64",  "hardware": "xxxxxx" }`notifyweb 呼叫範例 json`{  "title": "訂閱通知",  "content": "已取消訂閱 xxx" }`app 回傳 bool: 是否成功發送手機通知app 回傳範例 json`{  "name": "notify",  "data": true }`
