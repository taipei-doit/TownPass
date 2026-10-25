---
title: "資料呈現"
source_url: "https://townpass.taipei/docs/micro-service/citizen-report/data.html"
source_path: "docs/micro-service/citizen-report/data.md"
retrieved_at: "2026-10-04"
---

# 資料呈現

## API 設計

關於有話要說頁面，JSON 格式的欄位定義如下，開發時只需遵照規格即可。 各頁面完整 JSON 格式如下

### [/citizen-report](user-interface.md#citizen-report)

熱門項目資料

JSON

```
"data": {
  "hot_report": [
    {
      "id": "R-1",
      "name": "教育事務",
      "icon": "/images/report/report-transport.svg"
    },
    {
      "id": "R-2",
      "name": "公車、計程車、復康巴士問題",
      "icon": "/images/report/report-building.svg"
    },
    {
      "id": "R-3",
      "name": "停車管理及收費問題",
      "icon": "/images/report/report-transport.svg"
    },
    {
      "id": "R-4",
      "name": "建築物使用管理、違建查報及拆除",
      "icon": "/images/report/report-building.svg"
    },
    {
      "id": "R-11",
      "name": "教育事務",
      "icon": "/images/report/report-transport.svg"
    },
    {
      "id": "R-12",
      "name": "公車、計程車、復康巴士問題",
      "icon": "/images/report/report-building.svg"
    },
    {
      "id": "R-13",
      "name": "停車管理及收費問題",
      "icon": "/images/report/report-transport.svg"
    },
    {
      "id": "R-14",
      "name": "建築物使用管理、違建查報及拆除",
      "icon": "/images/report/report-building.svg"
    },
    {
      "id": "R-15",
      "name": "教育事務",
      "icon": "/images/report/report-transport.svg"
    },
    {
      "id": "R-16",
      "name": "公車、計程車、復康巴士問題",
      "icon": "/images/report/report-building.svg"
    }
  ],
}
```

進度查詢資料

JSON

```
{
  "data": {
    "1999": [
      {
        "id": "A10-1130930-00160",
        "title": "公車、計程車、復康巴士問題",
        "date": "2024/09/28 15:55:57",
        "status": "處理中"
      },
      {
        "id": "A10-1130930-00161",
        "title": "建築物使用管理、違建查報及拆除",
        "date": "2024/10/28 15:55:57",
        "status": "處理完成"
      },
      {
        "id": "A10-1130930-00162",
        "title": "停車管理及收費問題",
        "date": "2024/11/28 15:55:57",
        "status": "處理中"
      }
    ],
    "disaster": []
  }
}
```

#### 資料欄位說明-熱門項目

| 欄位 | 用途 | 範例 |
| --- | --- | --- |
| hot_report | 熱門通報項目 | 參考 [hot_report](data.md#hot_report) |

##### hot_report

| 欄位 | 用途 | 範例 |
| --- | --- | --- |
| id | 通報項目 ID | R-16 |
| name | 通報項目名稱 | 公車、計程車、復康巴士問題 |
| icon | 通報項目的 icon url (若要將 icon 放在本地端，可以放在 `public` 資料夾中) | /images/report/report-building.svg |

#### 資料欄位說明-進度查詢

| 欄位 | 用途 | 範例 |
| --- | --- | --- |
| 1999 | 屬於 1999 通報的項目 | 參考 [1999](data.md#1999) |
| disaster | 屬於災難通報的項目 | 資料格式與 1999 相同，參考 [1999](data.md#1999) |

##### 1999

| 欄位 | 用途 | 範例 |
| --- | --- | --- |
| id | 通報項目 ID | A10-1130930-00160 |
| title | 通報項目名稱 | 公車、計程車、復康巴士問題 |
| date | 通報日期 | 2024/11/28 15:55:57 |
| status | 處理進度 | 處理完成 (進度完成，一律叫處理完成) |

### [/citizen-report/list](user-interface.md#citizen-report-list)

所有通報項目資料

JSON

```
{
  "data": {
    "all_report": [
      {
        "id": "CR-1",
        "name": "垃圾、噪音、汙染及資源回收",
        "icon": "/images/report/report-env.svg",
        "service_requesting": [
          {
            "id": "R-5",
            "name": "道路散落物或油漬處理"
          },
          {
            "id": "R-6",
            "name": "汙染舉發"
          }
        ],
        "problem_reporting": [
          {
            "id": "R-7",
            "name": "無牌廢棄車、廢物誤觸理(含醫療廢棄物)及資源回收"
          },
          {
            "id": "R-8",
            "name": "有牌廢棄車"
          }
        ]
      },
      {
        "id": "CR-2",
        "name": "文教、體育、資訊、觀光及媒體",
        "icon": "/images/report/report-env.svg",
        "service_requesting": [],
        "problem_reporting": [
          {
            "id": "R-9",
            "name": "文化事務(樹木保護、文化資產、表演藝術、文化場館、藝文推廣)"
          },
          {
            "id": "R-1",
            "name": "教育事務(校園、教師、幼兒園、圖書館、補教業)"
          }
        ]
      }
    ]
  }
}
```

#### 資料欄位說明-所有通報項目

| 欄位 | 用途 | 範例 |
| --- | --- | --- |
| all_report | 所有通報項目 | 參考 [all_report](data.md#all_report) |

##### all_report

| 欄位 | 用途 | 範例 |
| --- | --- | --- |
| id | 通報項目分類 ID | CR-2 |
| name | 通報項目分類名稱 | 文教、體育、資訊、觀光及媒體 |
| icon | 通報項目分類的 icon url (若要將 icon 放在本地端，可以放在 `public` 資料夾中) | /images/report/report-env.svg |
| service_requesting | 立即支援的通報項目 | 參考 [service_requesting](data.md#service_requesting) |
| problem_reporting | 民眾陳情的通報項目 | 資料格式與 service_requesting 相同，參考 [service_requesting](data.md#service_requesting) |

##### service_requesting

| 欄位 | 用途 | 範例 |
| --- | --- | --- |
| id | 通報項目 ID | R-9 |
| name | 通報項目名稱 | 文化事務(樹木保護、文化資產、表演藝術、文化場館、藝文推廣) |

### [/citizen-report/search-detail/:id](user-interface.md#citizen-report-search-detail-id)

進度查詢詳細資料，這邊實際上要用 url params 的 `id` 去跟 api 要對應的詳細資料，先看預期的資料範例

JSON

```
{
  "data": {
    "status": "處理完成",
    "reply": {
      "from": {
        "agency": "文化局",
        "date": "2024/09/30 15:32:23"
      },
      "content": "AABBCCDDEEFFF"
    },
    "detail": {
      "case_title": "主旨主旨主旨",
      "case_id": "A10-1130930-00160",
      "acceptance_time": "2024/09/28 15:55:57",
      "category": "文教、體育、資訊、觀光及媒體-文化事務(樹木保護、文化資產、表演藝術、文化場館、藝文推廣)",
      "agency": "文化局",
      "expected_time": "2024/10/09",
      "actual_time": "2024/09/30",
      "content": "1234567890"
    }
  }
}
```

#### 資料欄位說明-進度查詢詳細

| 欄位 | 用途 | 範例 |
| --- | --- | --- |
| status | 處理進度 | 處理完成 |
| reply | 相關單位回覆 | 參考 [reply](data.md#reply) |
| detail | 通報項目的詳細內容 | 參考 [detail](data.md#detail) |

##### reply

| 欄位 | 用途 | 範例 |
| --- | --- | --- |
| from | 回覆來自哪個單位 | 參考 [from](data.md#from) |
| content | 回覆內容 | AABBCCDDEEFFF |

##### from

| 欄位 | 用途 | 範例 |
| --- | --- | --- |
| agency | 回覆單位 | 文化局 |
| date | 回覆時間 | 2024/09/30 15:32:23 |

##### detail

| 欄位 | 用途 | 範例 |
| --- | --- | --- |
| case_title | 通報主旨 | 主旨主旨主旨 |
| case_id | 通報案件編號 | A10-1130930-00160 |
| acceptance_time | 受理時間 | 2024/09/28 15:55:57 |
| category | 通報案件分類 | 文教、體育、資訊、觀光及媒體-文化事務(樹木保護、文化資產、表演藝術、文化場館、藝文推廣) |
| agency | 辦理機關 | 文化局 |
| expected_time | 預計完成時間 | 2024/10/09 |
| actual_time | 實際完成時間 | 2024/09/30 |
| content | 通報具體內容 | 1234567890 |
