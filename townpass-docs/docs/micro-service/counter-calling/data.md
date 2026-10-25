---
title: "資料呈現"
source_url: "https://townpass.taipei/docs/micro-service/counter-calling/data.html"
source_path: "docs/micro-service/counter-calling/data.md"
retrieved_at: "2026-10-04"
---

# 資料呈現

## API 設計

關於臨櫃叫號頁面，JSON 格式的欄位定義如下，開發時只需遵照規格即可。 完整 JSON 格式如下

JSON

```
{
  "//": "臨櫃叫號-列表",
  "data": [
    {
      "id": "c-1",
      "name": "地政事務所",
      "icon": "/images/icon_landoffice.svg",
      "list": [
        {
          "id": "c-1-1",
          "name": "古亭地政事務所",
          "is_regularly_used": false,
          "info": {
            "address": "116057 臺北市文山區萬隆街47之12號2至4樓",
            "tel": "02-2935-5369",
            "fax": "02-2935-5373"
          },
          "counters": [
            {
              "id": "ct-1",
              "name": "藤本櫃檯",
              "current_number": "0001",
              "waiting_people": 0
            },
            {
              "id": "ct-2",
              "name": "網路申辦",
              "current_number": "1001",
              "waiting_people": 3
            },
            {
              "id": "ct-3",
              "name": "全功能櫃檯",
              "current_number": "2001",
              "waiting_people": 0
            }
          ]
        },
        {
          "id": "c-1-2",
          "name": "中山地政事務所",
          "is_regularly_used": false,
          "info": {
            "address": "104256 臺北市中山區松江路357巷1號",
            "tel": "02-2502-2881",
            "fax": "02-2502-2982"
          },
          "counters": [
            {
              "id": "ct-1",
              "name": "藤本櫃檯",
              "current_number": "1093",
              "waiting_people": 0
            },
            {
              "id": "ct-2",
              "name": "網路申辦",
              "current_number": "0000",
              "waiting_people": 0
            },
            {
              "id": "ct-3",
              "name": "全功能櫃檯",
              "current_number": "4054",
              "waiting_people": 0
            },
            {
              "id": "ct-4",
              "name": "收件櫃檯",
              "current_number": "3114",
              "waiting_people": 0
            }
          ]
        }
      ]
    },
    {
      "id": "c-2",
      "name": "戶政事務所",
      "icon": "/images/icon_household_office.svg",
      "list": [
        {
          "id": "c-2-1",
          "name": "萬華區戶政事務所",
          "is_regularly_used": false,
          "info": {
            "address": "臺北市萬華區和平西路三段120號4樓",
            "tel": "02-2306-2706",
            "fax": "02-2308-2868"
          },
          "counters": [
            {
              "id": "ct-1",
              "name": "綜合受理",
              "current_number": "0379",
              "waiting_people": 0
            },
            {
              "id": "ct-2",
              "name": "自然人憑證",
              "current_number": "2023",
              "waiting_people": 0
            },
            {
              "id": "ct-3",
              "name": "護照一站式",
              "current_number": "3004",
              "waiting_people": 0
            }
          ]
        },
        {
          "id": "c-2-2",
          "name": "中正區戶政事務所",
          "is_regularly_used": false,
          "info": {
            "address": "臺北市中正區忠孝東路一段108號7樓",
            "tel": "02-2394-8838",
            "fax": "02-2394-2540"
          },
          "counters": [
            {
              "id": "ct-1",
              "name": "藤本櫃檯",
              "current_number": "0328",
              "waiting_people": 0
            },
            {
              "id": "ct-2",
              "name": "自然人憑證",
              "current_number": "1034",
              "waiting_people": 0
            }
          ]
        }
      ]
    },
    {
      "id": "c-3",
      "name": "區公所",
      "icon": "/images/icon_revenue_service.svg",
      "list": [
        {
          "id": "c-3-1",
          "name": "臺北市萬華區公所",
          "is_regularly_used": false,
          "info": {
            "address": "10855 臺北市萬華區和平西路三段120號10~13樓",
            "tel": "02-2306-4468",
            "fax": "02-2306-8052"
          },
          "counters": [
            {
              "id": "ct-1",
              "name": "綜合櫃檯",
              "current_number": "23",
              "waiting_people": 0
            },
            {
              "id": "ct-2",
              "name": "兵役服務",
              "current_number": "703",
              "waiting_people": 0
            },
            {
              "id": "ct-3",
              "name": "博愛櫃檯",
              "current_number": "903",
              "waiting_people": 6
            }
          ]
        },
        {
          "id": "c-3-2",
          "name": "臺北市中正區公所",
          "is_regularly_used": false,
          "info": {
            "address": "10050 臺北市中正區忠孝東路一段108號8樓",
            "tel": "02-2341-6721",
            "fax": ""
          },
          "counters": [
            {
              "id": "ct-1",
              "name": "博愛櫃檯",
              "current_number": "000",
              "waiting_people": 0
            },
            {
              "id": "ct-2",
              "name": "社會業務",
              "current_number": "000",
              "waiting_people": 0
            },
            {
              "id": "ct-3",
              "name": "民政業務",
              "current_number": "000",
              "waiting_people": 0
            },
            {
              "id": "ct-4",
              "name": "兵役服務",
              "current_number": "000",
              "waiting_people": 0
            }
          ]
        }
      ]
    },
    {
      "id": "c-4",
      "name": "稅捐處",
      "icon": "/images/icon_district_office.svg",
      "list": [
        {
          "id": "c-4-1",
          "name": "萬華分處",
          "is_regularly_used": false,
          "info": {
            "address": "108220 臺北市萬華區和平西路三段120號6樓",
            "tel": "02-2302-1191",
            "fax": "02-2302-7245"
          },
          "counters": [
            {
              "id": "ct-1",
              "name": "全功能服務",
              "current_number": "46",
              "waiting_people": 2
            }
          ]
        },
        {
          "id": "c-4-2",
          "name": "大同分處",
          "is_regularly_used": false,
          "info": {
            "address": "10363 臺北市大同區昌吉街57號3樓之2",
            "tel": "02-2587-3650",
            "fax": "02-2593-0103"
          },
          "counters": [
            {
              "id": "ct-1",
              "name": "全功能服務臺",
              "current_number": "24",
              "waiting_people": 0
            }
          ]
        }
      ]
    },
    {
      "id": "c-5",
      "name": "就業服務站",
      "icon": "/images/icon_employment_service.svg",
      "list": [
        {
          "id": "c-5-1",
          "name": "艋舺就業服務站",
          "is_regularly_used": false,
          "info": {
            "address": "臺北市萬華區艋舺大道101號3樓",
            "tel": "02-2308-5231",
            "fax": "02-2308-5352"
          },
          "counters": [
            {
              "id": "ct-1",
              "name": "綜合業務",
              "current_number": "0103",
              "waiting_people": 0
            },
            {
              "id": "ct-2",
              "name": "移工業務",
              "current_number": "2029",
              "waiting_people": 0
            }
          ]
        },
        {
          "id": "c-5-2",
          "name": "西門就業服務站",
          "is_regularly_used": false,
          "info": {
            "address": "臺北市萬華區峨嵋街81號",
            "tel": "02-2381-3344",
            "fax": "02-2371-9805"
          },
          "counters": [
            {
              "id": "ct-1",
              "name": "綜合受理",
              "current_number": "075",
              "waiting_people": 0
            }
          ]
        }
      ]
    }
  ]
}
```

## 資料欄位說明

### 臨櫃叫號

#### data

| 欄位 | 用途 | 範例 |
| --- | --- | --- |
| id | 服務地點 id | c-1 |
| name | 服務地點名稱 | 地政事務所 |
| icon | 地點圖示，將圖檔置於/public/images目錄下，如傳空值則無圖示 | /images/icon_landoffice.svg |
| list | 服務地點列表 | [詳見下表 list](data.md#list) |

#### list

| 欄位 | 用途 | 範例 |
| --- | --- | --- |
| id | key | c-1-1 |
| name | 地點名稱 | 古亭地政事務所 |
| is_regularly_used | 是否加入常用列表 | true/false |
| info | 地點詳細資訊 | [詳見下表 info](data.md#info) |
| counters | 該地點中的各項服務櫃檯 | [詳見下表 counter](data.md#counter) |

#### info 地點詳細資訊

| 欄位 | 用途 | 範例 |
| --- | --- | --- |
| address | 地址 | 116057 臺北市文山區萬隆街47之12號2至4樓 |
| tel | 電話 | 02-2935-5369 |
| fax | 傳真 | 02-2935-5373 |

#### counter 各項服務櫃檯

| 欄位 | 用途 | 範例 |
| --- | --- | --- |
| id | key | ct-1 |
| name | 櫃檯名稱 | 藤本櫃檯 |
| current_number | 目前叫號 | "0001" |
| waiting_people | 目前等待人數 | 0 |
