---
title: "資料呈現"
source_url: "https://townpass.taipei/docs/micro-service/qna/data.html"
source_path: "docs/micro-service/qna/data.md"
retrieved_at: "2026-10-04"
---

# 資料呈現

## API 設計

Q & A 查詢頁面，使用者僅需定義簡單的 JSON 格式，並可更新前端的常見問題顯示。 我們已經定義好相關規格，並動態使用在 UI 渲染上，開發時只需遵照規格即可。 完整 JSON 格式如下

JSON

```
{
  "//": "Q & A • 常見問題",
  "data": [
    {
      "name": "登入註冊",
      "list": [
        {
          "id": "q1-1",
          "is_show_front_page": false,
          "category": "登入註冊",
          "name": "一定需要實名認證才能加入城市通會員？",
          "name_en": "Does signing up for TownPass membership require real name verification?",
          "content": "城市通會員分為一般會員與金質會員（實名認證會員），建議您申請金質會員享有完整服務。",
          "content_en": "\nTownPass membership is divided into regular and gold members (those whose identity has been verified). Please acquire gold membership for more comprehensive service."
        },
        {
          "id": "q1-2",
          "is_show_front_page": true,
          "category": "登入註冊",
          "name": "已透過悠遊付註冊城市通會員，請問如何登入？",
          "name_en": "I have signed up for EasyWallet. How do I log in?",
          "content": "透過悠遊付APP註冊完成的城市通會員將取得一組帳號及密碼，如您忘記當初設定的密碼，請透過「忘記密碼」功能進行密碼變更。",
          "content_en": "\nIf your registration was successful, you would have received an account and password. If you forgot your pasword, please proceed to \"Forgot Password\" function and change your password accordingly."
        },
        ...
      ]
    },
    {
      "name": "卡證",
      "list": [
        {
          "id": "q2-1",
          "is_show_front_page": false,
          "category": "卡證",
          "name": "城市通是否有提供申請實體卡片的服務？",
          "name_en": "Can I apply for a TownPass physical card?",
          "content": "城市通為虛擬卡證，目前只有特殊身分核發實體卡證。",
          "content_en": "\nTownPass is a virtual membership card which integrates multiple functions. This helps to save you the trouble of carrying around multiple cards in your wallet. Currently, the option of a physical version of the card is reserved for individuals with specific needs."
        }
      ]
    },
    {
      "name": "優惠",
      "list": [
        {
          "id": "q3-1",
          "is_show_front_page": true,
          "category": "優惠",
          "name": "如何使用優惠券？",
          "name_en": "How can I access the coupons?",
          "content": "在城市通特約商家消費時，出示APP優惠券畫面即可享有專屬優惠。超簡單使用方式，請參考操作步驟。",
          "content_en": "\nWhen you shop at any of the TownPass partner stores, simply show the coupon with your app to enjoy the related discount. It is extremely simple to use. Refer to the following instructions."
        },
        {
          "id": "q3-2",
          "is_show_front_page": true,
          "category": "優惠",
          "name": "如何獲得優惠券？ ",
          "name_en": "How can I obtain the discount coupons?",
          "content": "下載城市通App，方能使用優惠，點選「優惠」主題，點選「優惠券」即可查看所有優惠商家。看到喜歡的優惠，可以按「+我的票夾」領取優惠或直接點立即使用票券。詳細操作請查看操作步驟。",
          "content_en": "\nDowload TownPass app to obtain discounts and bargains. Select \"Perk\" -> \"Coupon\" to check out our partner stores. If you see a bargain you like, simply press \"+ Keep it\" to add it to your inventory or \"Use it\" to use the coupon. For details, please refer to instructions."
        }
      ]
    },
    {
      "name": "服務",
      "list": [
        {
          "id": "q4-1",
          "is_show_front_page": true,
          "category": "服務",
          "name": "城市通帳號授權使用市府其他數位平台，可以取消使用授權嗎？",
          "name_en": "'ve authorized my TownPass account to access other digital platforms of the city government. Can I cancel the authorization?",
          "content": "請您登入<a href=\"https://www.taipei-pass.com\" style=\"color: #0000FF;\">城市通官方網站</a>，就可以在會員中心的「安全性」-「授權第三方應用」列表中，選擇取消特定服務的授權。",
          "content_en": "\nPlease login to the <a href=\"https://www.taipei-pass.com\" style=\"color: #0000FF;\">website of TownPass</a>. In the Membership Center, select \"Security\" -> \"Authorize Third Party Access\" and cancel the authorization for the specific service from the list."
        }
      ]
    },
    {
      "name": "帳單",
      "list": [
        {
          "id": "q5-1",
          "is_show_front_page": false,
          "category": "帳單",
          "name": "剛完成停車費繳納，城市通的帳單紀錄為何沒有顯示紀錄？",
          "name_en": "I just paid my parking fee, but why isn't the paid bill displayed in the records?",
          "content": "停車費帳單及繳納資訊非立即更新，請以停管處回覆之即時結果為準。\n如有繳費問題請逕洽停管處客服 02-2726-9600。",
          "content_en": "\nAs parking fee payment information do not receive realtime updates, all results will be based on the updates by the Parking Administration Office. For any questions on parking fee payments, please call the agency at 02-2726-9600."
        }
      ]
    },
    {
      "name": "下載安裝",
      "list": [
        {
          "id": "q6-1",
          "is_show_front_page": false,
          "category": "下載安裝",
          "name": "城市通建議使用環境？使用行動裝置有哪些？",
          "name_en": "What are the specs and requirment for TownPass app? What mobile devices can I install it on?",
          "content": "城市通APP目前提供Android與iOS系統兩個版本，安裝前請先確認智慧型手機之作業系統規格，目前支援 iOS 13.0以上(含)及Android 7.0以上(含)。",
          "content_en": "\nTownPass currently offers the Andriod version and iOS version. Please double check the specs of your mobile phone before installing the app. Currently, the app runs on systems including iOS 13.0 (or later versions) and Android 7.0 (or later versions)"
        }
      ]
    }
  ]
}
```

## 資料欄位說明

### Q & A • 常見問題

#### data

| 欄位 | 用途 | 範例 |
| --- | --- | --- |
| name | 常見問題分類 | 登入註冊 |
| list | 資料列表 | 詳見下表 |

#### list

| 欄位 | 用途 | 範例 |
| --- | --- | --- |
| id | key | q1-1 |
| is_show_front_page | 是否顯示於精選常見問題 | true/false |
| category | 分類 | 登入註冊 |
| name | 問題名稱(中文) | 一定需要實名認證才能加入城市通會員？ |
| name_en | 問題名稱(英文) | Does signing up for TownPass membership require real name verification? |
| content | 問題解答(中文) | 城市通會員分為一般會員與金質會員（實名認證會員），建議您申請金質會員享有完整服務。 |
| content_en | 問題解答(英文) | \nTownPass membership is divided into regular and gold members (those whose identity has been verified). Please acquire gold membership for more comprehensive service. |
