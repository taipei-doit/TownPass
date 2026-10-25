---
title: "客製化設計"
source_url: "https://townpass.taipei/docs/micro-service/application-services/custom-design.html"
source_path: "docs/micro-service/application-services/custom-design.md"
retrieved_at: "2026-10-04"
---

# 客製化設計

## 客製化區塊

本專案提供兩大區塊供開發者透過 JSON 來客製化內容，分別是主頁的**服務項目**與表單頁的**申辦服務資料**。

### 服務項目

服務項目透過種類與所屬機關做分類，每個項目都擁有專屬 ID，作為申辦服務資料取得表單欄位組成的依據，完整 JSON 格式如下

json

```
{
  "data": [
    {
      "name": "申訴類", // 服務項目大分類
      "icon": "", // 服務項目大分類 icon 路徑
      "agency": [ // 大分類底下的機關組合
        {
          "name": "交通局", // 機關名稱
          "options": [ // 機關下提供的申辦服務
            {
              "id": "a-1", // 申辦服務 id
              "title": "裁決所受理之申訴案件(本市)", // 申辦服務標題
              "subtitle": "裁決所受理之申訴案件（應到案處所為臺北市交通事件裁決所）-本市舉發案件（屬免書證、免謄本）", // 申辦服務副標題
              "type": "申訴類", // 所屬大分類
              "agency_type": "交通局" // 所屬機關
            },
            {
              "id": "a-2",
              "title": "裁決所受理之申訴案件(外縣市)",
              "subtitle": "裁決所受理之申訴案件（應到案處所為臺北市交通事件裁決所）-外縣市舉發案件（屬免書證、免謄本）",
              "type": "申訴類",
              "agency_type": "交通局"
            },
            {
              "id": "a-3",
              "title": "停管處受理之申訴案件",
              "subtitle": "停管處受理之申訴案件(舉發單位為臺北市停車管理工程處-停車費催(追)繳及舉發違規停車案件)",
              "type": "申訴類",
              "agency_type": "交通局"
            }
          ]
        },
        {
          "name": "警察局",
          "options": [
            {
              "id": "b-1",
              "title": "本市警察局受理之違規申訴案件",
              "subtitle": "本市警察局受理之違規申訴案件（舉發單位為臺北市政府警察局所屬各分局）",
              "type": "申訴類",
              "agency_type": "警察局"
            }
          ]
        }
      ]
    },
  ]
}
```

#### 服務項目-data

| 欄位 | 用途 | 範例 |
| --- | --- | --- |
| name | 服務項目大分類 | 申訴類 |
| icon | 服務項目大分類 icon 路徑，非必填 | [https://www.gov.taipei/images/favicon.ico](https://www.gov.taipei/images/favicon.ico) |
| agency | 大分類底下的機關組合 | 參考[服務項目-agency](custom-design.md#服務項目-agency) |

#### 服務項目-agency

| 欄位 | 用途 | 範例 |
| --- | --- | --- |
| name | 機關名稱 | 交通局 |
| options | 機關下提供的申辦服務 | 參考[服務項目-options](custom-design.md#服務項目-options) |

#### 服務項目-options

| 欄位 | 用途 | 範例 |
| --- | --- | --- |
| id | 申辦服務 id，必須是唯一 | a-1 |
| title | 申辦服務標題 | 裁決所受理之申訴案件(本市) |
| subtitle | 申辦服務副標題 | 裁決所受理之申訴案件（應到案處所為臺北市交通事件裁決所）-本市舉發案件（屬免書證、免謄本） |
| type | 所屬大分類 | 申訴類 |
| agency_type | 所屬機關 | 交通局 |

### 申辦服務資料

申辦服務資料定義了 7 個表單欄位元件讓開發者自由組合：

1. `input` 文字欄位。

![input](../../../assets/52aad64a8db29fbe1d96.png)

2. `select` 下拉選單欄位。

![select](../../../assets/1031a3aa6fc9221816f3.png)

3. `multiple_select` 多選欄位。

![multiple_select](../../../assets/8675572b38c699ec99db.png)

![multiple_select](../../../assets/afeb8d8328843fab8afa.png)

4. `radio_group` radio 群組欄位。

![radio_group](../../../assets/f491f35d6096bec668cb.png)

5. `textarea` 文字內容欄位。

![textarea](../../../assets/affe4d7c5fdec92e7dc8.png)

6. `checkbox_group` checkbox 群組欄位。

![checkbox_group](../../../assets/c772769468bb62806e6b.png)

7. `date_picker` 日期選擇欄位。

![date_picker](../../../assets/efbddddac919bf1d525a.png)

每個欄位都有一個叫 `field` 的 key，他的定義會是該欄位的值對應送出表單的 key，通常這會是後端接收表單定義出來的，因此要注意一致性。

所有有選項的欄位統一選項都要設計成有 `label` 與 `value`。

JSON 中我們同時需要定義 `submit_target`，其目的是讓前端知道這次表單要傳送給後端時的 url、request 方法與 request 接受的資料類型。

這邊的定義完全可以按照開發者自行設計接收表單的 API 格式去定義，記得要跟後端 API 確認這些欄位即可。

提交表單功能可以在專案 `src/views/FormPreview.vue` 下的 `onSubmitClick` 找到範例，請開發者按照自己的想法來串接提交表單的 API 吧。

完整 JSON 如下，表單每個欄位出現次數不限，可以自由組合。

JSON

```
{
  "data": {
    "submit_target": {
      "url": "https://www.gov.taipei/", // 提交表單的目標後端 url
      "method": "POST", // 提交表單時 request 方法
      "content_type": "application/json" // request 可接受的資料類型
    },
    "form_format": [
      {
        "type": "input", // 表單欄位類型
        "label": "違規駕駛人姓名", // 表單欄位標籤
        "required": true, // 此表單欄位是否必填
        "field": "name" // 表單欄位對應送出表單的 key
      },
      {
        "type": "select",
        "label": "承辦機關",
        "required": true,
        "field": "agency",
        "default_option": "請選擇機關", // 預設選項，沒有 value，作用類似 placeholder
        "options": [ // 所有選項
          {
            "label": "交通事件裁決所",
            "value": "交通事件裁決所"
          }
        ]
      },
      {
        "type": "multiple_select",
        "label": "申訴項目",
        "required": true,
        "field": "apply",
        "options": [
          {
            "label": "車禍案件申訴",
            "value": "車禍案件申訴"
          },
          {
            "label": "車型車色不符",
            "value": "車型車色不符"
          }
        ]
      },
      {
        "type": "radio_group",
        "label": "以E-MAIL寄發",
        "required": true,
        "field": "send_by_mail",
        "options": [
          {
            "label": "是",
            "value": "Y"
          },
          {
            "label": "否",
            "value": "N"
          }
        ]
      },
      {
        "type": "textarea",
        "label": "申訴內容",
        "required": true,
        "field": "content"
      },
      {
        "type": "checkbox_group",
        "label": "申請表單",
        "required": true,
        "field": "apply_form",
        "options": [
          {
            "label": "現場圖",
            "value": "現場圖"
          },
          {
            "label": "現場照片",
            "value": "現場照片"
          }
        ]
      },
      {
        "type": "date_picker",
        "label": "肇事日期",
        "required": true,
        "field": "date"
      },
    ]
  }
}
```

#### 申辦服務資料-data

| 欄位 | 用途 | 範例 |
| --- | --- | --- |
| submit_target | 送出表單的目標資訊 | 參考[申辦服務資料-submit_target](custom-design.md#申辦服務資料-submit_target) |
| form_format | 客製化表單元件組成 | 參考[申辦服務資料-form_format](custom-design.md#申辦服務資料-form_format) |

#### 申辦服務資料-submit_target

| 欄位 | 用途 | 範例 |
| --- | --- | --- |
| url | 提交表單的目標後端 url | [https://www.gov.taipei/](https://www.gov.taipei/) |
| method | 提交表單時 request 方法 | POST |
| content_type | request 可接受的資料類型 | application/json |

#### 申辦服務資料-form_format

- input

| 欄位 | 用途 | 範例 |
| --- | --- | --- |
| type | 表單欄位類型 | input |
| label | 表單欄位標籤 | 違規駕駛人姓名 |
| required | 此表單欄位是否必填 | true |
| field | 表單欄位對應送出表單的 key | name |

- select

| 欄位 | 用途 | 範例 |
| --- | --- | --- |
| type | 表單欄位類型 | select |
| label | 表單欄位標籤 | 承辦機關 |
| required | 此表單欄位是否必填 | true |
| field | 表單欄位對應送出表單的 key | agency |
| default_option | 預設選項，沒有 value，作用類似 placeholder | 請選擇機關 |
| options | 所有選項 | 參考[申辦服務資料-選項格式](custom-design.md#申辦服務資料-選項格式) |

- multiple_select

| 欄位 | 用途 | 範例 |
| --- | --- | --- |
| type | 表單欄位類型 | multiple_select |
| label | 表單欄位標籤 | 申訴項目 |
| required | 此表單欄位是否必填 | true |
| field | 表單欄位對應送出表單的 key | send_by_mail |
| options | 所有選項 | 參考[申辦服務資料-選項格式](custom-design.md#申辦服務資料-選項格式) |

- radio_group

| 欄位 | 用途 | 範例 |
| --- | --- | --- |
| type | 表單欄位類型 | radio_group |
| label | 表單欄位標籤 | 以E-MAIL寄發 |
| required | 此表單欄位是否必填 | true |
| field | 表單欄位對應送出表單的 key | apply |
| options | 所有選項 | 參考[申辦服務資料-選項格式](custom-design.md#申辦服務資料-選項格式) |

- textarea

| 欄位 | 用途 | 範例 |
| --- | --- | --- |
| type | 表單欄位類型 | textarea |
| label | 表單欄位標籤 | 申訴內容 |
| required | 此表單欄位是否必填 | true |
| field | 表單欄位對應送出表單的 key | content |

- checkbox_group

| 欄位 | 用途 | 範例 |
| --- | --- | --- |
| type | 表單欄位類型 | checkbox_group |
| label | 表單欄位標籤 | 申請表單 |
| required | 此表單欄位是否必填 | true |
| field | 表單欄位對應送出表單的 key | apply_form |
| options | 所有選項 | 參考[申辦服務資料-選項格式](custom-design.md#申辦服務資料-選項格式) |

- date_picker

| 欄位 | 用途 | 範例 |
| --- | --- | --- |
| type | 表單欄位類型 | date_picker |
| label | 表單欄位標籤 | 肇事日期 |
| required | 此表單欄位是否必填 | true |
| field | 表單欄位對應送出表單的 key | date |

#### 申辦服務資料-選項格式

| 欄位 | 用途 | 範例 |
| --- | --- | --- |
| label | 選項文字 | 是 |
| value | 選項的值，主要用在填入傳送給後端的表單 | Y |
