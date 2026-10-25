---
title: "資料呈現"
source_url: "https://townpass.taipei/docs/micro-service/find-places/data.html"
source_path: "docs/micro-service/find-places/data.md"
retrieved_at: "2026-10-04"
---

# 資料呈現

## API 設計

找地點查詢頁面，使用者僅需定義簡單的 JSON 格式，便可在地圖上呈現地點資料。 我們已經定義好相關規格，並動態使用在 UI 渲染上，開發時只需遵照規格即可。  
 主要有兩種獲得資料來源的方式，分別為 **open data api** 與 **靜態 JSON**，用法請參考[詳細說明](data.md#詳細說明)。  
  
 完整 JSON 格式如下：

JSON

```
{
  "list": [
    {
      "name": "交通運輸、停車場、充電站",
      "places": [
        {
          "id": "pa-1",
          "name": "微笑單車 2.0",
          "icon": "",
          "agency": "台北市政府交通局",
          "type": "交通運輸、停車場、充電站",
          "data_type": "api",
          "request_url": "https://tcgbusfs.blob.core.windows.net/dotapp/youbike/v2/youbike_immediate.json",
          "data_path": "",
          "format_fields": {
            "id": "sno",
            "name": "sna",
            "area": "sarea",
            "address": "ar",
            "lat": "latitude",
            "lng": "longitude"
          },
          "service_infos": [
            {
              "title": "備註",
              "value_fields": [
                {
                  "title": "可借車輛",
                  "value_field": "available_rent_bikes"
                },
                {
                  "title": "可停空位",
                  "value_field": "available_return_bikes"
                }
              ]
            },
            {
              "title": "更新時間",
              "value_field": "updateTime"
            }
          ]
        },
        {
          "id": "pa-3",
          "name": "停車場",
          "icon": "",
          "agency": "台北市停車管理工程處",
          "type": "交通運輸、停車場、充電站",
          "data_type": "json",
          "request_url": "/public/mock/find-place/TCMSV_alldesc.json",
          "data_path": "",
          "format_fields": {
            "id": "id",
            "name": "name",
            "area": "area",
            "address": "address",
            "lat": "EntranceCoord.EntrancecoordInfo[0]?.Xcod",
            "lng": "EntranceCoord.EntrancecoordInfo[0]?.Ycod"
          },
          "service_infos": [
            {
              "title": "概況",
              "value_field": "summary"
            },
            {
              "title": "費率",
              "value_field": "payex"
            }
          ]
        }
      ]
    },
    {
      "name": "飲水機、公廁、哺集乳室、AED場所",
      "places": [
        {
          "id": "pb-1",
          "name": "飲水機/提供飲水店家",
          "icon": "/public/images/icon_drinking.svg",
          "agency": "台北市政府環境保護局",
          "type": "飲水機、公廁、哺集乳室、AED場所",
          "data_type": "api",
          "request_url": "https://data.taipei/api/v1/dataset/52538305-ed23-490c-8f67-3efff2d777c3?scope=resourceAquire",
          "data_path": "result.results",
          "format_fields": {
            "id": "_id",
            "name": "場所名稱",
            "area": "行政區",
            "address": "場所地址",
            "lat": "緯度",
            "lng": "經度"
          },
          "service_infos": [
            {
              "title": "場所開放時間",
              "value_field": "場所開放時間"
            },
            {
              "title": "飲水台數",
              "value_field": "飲水台數"
            }
          ]
        },
        {
          "id": "pb-3",
          "name": "公廁",
          "icon": "/public/images/icon_toilet.svg",
          "agency": "",
          "type": "飲水機、公廁、哺集乳室、AED場所",
          "data_type": "json",
          "request_url": "/public/mock/find-place/public_toilet_taipei.json",
          "data_path": "",
          "format_fields": {
            "id": "id",
            "name": "name",
            "area": "city",
            "address": "address",
            "lat": "latitude",
            "lng": "longitude"
          },
          "service_infos": [
            {
              "title": "等級",
              "value_field": "grade"
            }
          ]
        }
      ]
    }
  ]
}
```

## 資料欄位說明

#### 服務地圖-data

| 欄位 | 用途 | 範例 |
| --- | --- | --- |
| name | 服務地圖分類，呈現於地圖選單中的標頭 | 交通運輸、停車場、充電站 |
| places | 該分類下的服務據點 | [詳見下表](data.md#places) |

#### places

| 欄位 | 用途 | 範例 |
| --- | --- | --- |
| id | key | pa-1 |
| name | 服務地圖名稱 | 微笑單車 2.0 |
| icon | 圖示，將圖檔置於/public/images目錄下，如傳空值則無圖示 | /public/images/icon_drinking.svg |
| agency | 服務提供機構 | 台北市政府交通局 |
| type | 地圖所屬分類 | 交通運輸、停車場、充電站 |
| data_type | 資料來源格式 | api 或 json |
| request_url | 資料取得 url   如為json，則將靜態json檔案放置於/public/mock目錄下後引用 | api:[https://tcgbusfs.blob.core.windows.net/dotapp/youbike/v2/youbike_immediate.json](https://tcgbusfs.blob.core.windows.net/dotapp/youbike/v2/youbike_immediate.json)    json:/public/mock/find-place/TCMSV_alldesc.json |
| data_path | 如資料返回值非陣列，則可傳入欲取得之資料物件的路徑; 如返回值即是陣列，則可留空 | result.results   (即返回值欲取得之資料物件存在於responseData.result.results陣列中) |
| format_fields | 資料欄位 mapping | [詳見下表 format_fields](data.md#format-fields) |
| service_infos | 資料詳細資訊 | [詳見下表 service_infos](data.md#service-infos) |

### format_fields

主要使用此區塊來組合不同資料來源格式，填入資料的欄位名稱進行 mapping

| 欄位 | 用途 | 範例 |
| --- | --- | --- |
| id | key | 填入資料 key 值之欄位名稱   必要資訊 |
| name | 地點名稱 | 填入資料地點名稱之欄位名稱   必要資訊 |
| area | 地點所在位置，ex. 行政區 | 填入資料地點所在位置之欄位名稱   必要資訊 |
| address | 地點詳細地址 | 填入資料地點詳細地址之欄位名稱   必要資訊 |
| lat | 經度 | 填入資料經度之欄位名稱   必要資訊，如無經度則無法繪製地點於地圖上 |
| lng | 緯度 | 填入資料緯度之欄位名稱   必要資訊，如無經度則無法繪製地點於地圖上 |

### service_infos

| 欄位 | 用途 | 範例 |
| --- | --- | --- |
| title | 詳細資訊之標題 | 備註 |
| value_fields | 包含多組子詳細資訊，每個項目對應一個 `title` 和對應的 `value_field`，呈現同個 title 底下的多筆相關資料 | 與 `value_field` 擇一呈現，詳見上方 JSON |
| value_field | 包含一組子詳細資訊，對應一個資料欄位，呈現單筆資料 | 與 `value_fields` 擇一呈現，詳見上方 JSON |
