---
title: "進度查詢"
source_url: "https://townpass.taipei/docs/micro-service/application-services/case-progress.html"
source_path: "docs/micro-service/application-services/case-progress.md"
retrieved_at: "2026-10-04"
---

# 進度查詢

## API 設計

進度查詢頁面，需要使用者自行開發 API 並串接，藉此更新前端的進度顯示。 我們已經定義好相關規格，並動態使用在 UI 渲染上，開發 API 時可參考規格。 完整 JSON 格式如下

JSON

```
{
  "data": [
    {
      "id": "202406120002", // 案件的 ID
      "name": "臺北市路邊停車費重複繳費申請退費", // 案件名稱
      "date": "2024/06/12", // 案件申請日期
      "status": "待審核", // 案件目前狀態
      "total_step": 5, // 案件審核總流程
      "current_step": 2 // 案件目前進度
    },
    {
      "id": "202406130002",
      "name": "臺北市路邊停車費重複繳費申請退費",
      "date": "2024/06/13",
      "status": "待審核",
      "total_step": 5,
      "current_step": 3
    },
    {
      "id": "202406100002",
      "name": "臺北市路邊停車費重複繳費申請退費",
      "date": "2024/06/10",
      "status": "已結案",
      "total_step": 5,
      "current_step": 5
    }
  ]
}
```

### 進度查詢-data

| 欄位 | 用途 | 範例 |
| --- | --- | --- |
| id | 案件的 ID | 202406120002 |
| name | 案件名稱 | 臺北市路邊停車費重複繳費申請退費 |
| date | 案件申請日期 | 2024/06/12 |
| status | 案件目前狀態 | 待審核 |
| total_step | 案件審核總流程 | 5 |
| current_step | 案件目前進度 | 2 |
