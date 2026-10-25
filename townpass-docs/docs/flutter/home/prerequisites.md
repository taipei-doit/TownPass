---
title: "核心技術與必備知識"
source_url: "https://townpass.taipei/docs/flutter/home/prerequisites.html"
source_path: "docs/flutter/home/prerequisites.md"
retrieved_at: "2026-10-04"
---

# 核心技術與必備知識

## 開發環境

為了最佳的開發體驗，我們建議使用作業系統為 Windows 或 macOS 的電腦。我們也建議進行以下開發環境設定。

### 開發工具

如果您希望使用我們的[專案設定指南](project-setup.md)，請確保您的電腦上有安裝了以下開發工具：[Xcode](https://xcodereleases.com/)（iOS 模擬器，只有 Mac 可以安裝）、[Android Studio](https://developer.android.com/studio?hl=zh-tw)（Android 模擬器）、[Git](https://git-scm.com/)（也可以額外安裝 GitHub Desktop）。另外建議安裝 [FVM](https://fvm.app/) 管理您電腦中專案的 Flutter SDK version。

> 若不想安裝模擬器也可以準備 iOS 與 Android 實機裝置 Debug。

### 程式編輯器

[VScode](https://code.visualstudio.com/) 或是 [Android Studio](https://developer.android.com/studio?hl=zh-tw) 都是我們推薦的編輯器。

## 前端核心庫與套件

### Flutter

本專案選用 Flutter 作為前端框架，透過 Flutter 的跨平台開發特性，用單一語言（Dart）開發出支援 iOS 與 Android 應用程式。 詳細可參考 [Flutter 文件](https://flutter.dev/)。

### GetX

我們透過 GetX 做為專案的狀態與路由管理系統。 GetX 簡化了原始 Flutter 管理狀態與路由的複雜度，程式碼維護上也更加簡潔、易讀。 詳細可參考 [GetX 文件](https://pub.dev/packages/get)。

### cached_network_image

處理來自網路上的圖片，做暫存處理。 詳細可參考 [cached_network_image 文件](https://pub.dev/packages/cached_network_image)。

### carousel_slider

輪播效果 UI。 詳細可參考 [carousel_slider 文件](https://pub.dev/packages/carousel_slider)。

### flutter_localizations

APP 多語系管理。 詳細可參考 [flutter_localizations 文件](https://pub.dev/packages/flutter_localization)。

### intl

APP 多語系管理。 詳細可參考 [intl 文件](https://pub.dev/packages/intl)。

### json_serializable

JSON 資料處理。 詳細可參考 [json_serializable 文件](https://pub.dev/packages/json_serializable)。

> **💡 小撇步：** 如果您是 Flutter 開發的新手，我們建議您可以先從了解 Dart 開始。
>
> [官方文件](https://dart.dev/language)是不錯的資源。
