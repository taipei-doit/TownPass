---
title: "下載並設定專案"
source_url: "https://townpass.taipei/docs/flutter/home/project-setup.html"
source_path: "docs/flutter/home/project-setup.md"
retrieved_at: "2026-10-04"
---

# 下載並設定專案

## 在本地運行專案

1. 從 [專案程式庫](https://github.com/taipei-doit/TownPass) clone 專案至你的電腦。
   注意

   請勿將 Flutter 安裝/放置到以下目錄或路徑中：

   - 路徑包含特殊字元或空格。
   - 路徑需要較高權限。

   例： `C:\Program Files\` 、 `~/dev/我的專案/` 皆屬上述情況。
2. 使用你的 IDE 開啟專案，並在終端執行下列指令為專案安裝相關依賴套件。
   bash

   ```
   flutter pub get
   ```
3. 輸入下列指令來自動化產生專案/套件需要的額外程式碼：
   bash

   ```
   flutter packages pub run build_runner build
   ```
   注意

   若有修改到會產生額外 dart code 檔案時，執行 `flutter packages pub run build_runner build` 會遇到產生檔衝突。  
    請選擇 `1. Delete` 刪除既有的產生檔案 `xxx.g.dart`。  
    或者直接使用此指令，在遭遇產生檔衝突時，直接以新產生檔覆蓋既有產生檔：

   bash

   ```
   flutter packages pub run build_runner build --delete-conflicting-outputs
   ```
4. 執行專案。

小撇步

Flutter 在程式執行時支援 Hot Reload，能夠在不重新啟動 app 的狀態下，根據調整的內容更新 APP 畫面與邏輯。

更多關於 Hot Reload 的資訊可參考：[官方文件](https://docs.flutter.cn/tools/hot-reload/)。
