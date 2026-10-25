---
title: "下載與設定專案"
source_url: "https://townpass.taipei/docs/micro-service/introductions/project-setup.html"
source_path: "docs/micro-service/introductions/project-setup.md"
retrieved_at: "2026-10-04"
---

# 下載與設定專案

## 在本地運行專案

1. Fork [專案程式庫](https://github.com/taipei-doit/TownPass-Services)，然後將專案 clone 到您的電腦。用 VSCode 或您偏好的程式編輯器開啟程式庫。
2. 第一次執行專案需要安裝相關 package，請在專案根目錄下執行

bash

```
pnpm install
```

3. 開啟本地開發環境，預設路徑是 `http://localhost:5173`。

bash

```
pnpm dev
```

本專案是以行動裝置為優先設計，因此透過瀏覽器檢視時會建議使用瀏覽器開發工具中的 device 畫面模擬器去做檢視。
