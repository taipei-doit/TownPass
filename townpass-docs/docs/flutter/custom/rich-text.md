---
title: "rich-text"
source_url: "https://townpass.taipei/docs/flutter/custom/rich-text.html"
source_path: "docs/flutter/custom/rich-text.md"
retrieved_at: "2026-10-04"
---

本頁將會介紹自定義中使用到的(簡化版)富文本 (RichText) 內容將如何透過 JSON 來建構。

## 目錄

- [介紹](rich-text.md#介紹)
  - [簡介](rich-text.md#簡介)
  - [`RichTextObject`](rich-text.md#RichTextObject)
  - [`RichTextObject.text`](rich-text.md#RichTextObject.text)
  - [`RichTextObject.style`](rich-text.md#RichTextObject.style)
  - [`RichTextObject.url`](rich-text.md#RichTextObject.url)
- [組合 `RichTextObject`](rich-text.md#組合_RichTextObject)

## 介紹

### 簡介

富文本內容所使用的 key 為 `rich_text`，是 JsonArray，由一個個 [`RichTextObject`](rich-text.md#RichTextObject) 組合而成，以下將詳細介紹該如何來撰寫。

以下為一個富文本 JSON 範例：

json

```
"rich_text": [
  {
    "text": "Are you serious?",
    "style": [
      "ITALIC",
      "BOLD",
      "UNDERLINE"
    ],
    "url": "https://some.url.com"
  },
  {
    "text": "\nNah, I'm kidding."
  }
]
```

關於這個範例...其實有個多餘可刪除的設定，若你看完介紹回來發現的話... 我其實也沒法給你什麼🤣 為自己鼓個掌吧👏

---

### `RichTextObject`

json

```
{
  "text": "Wololo",
  "style": [
    "ITALIC",
    "BOLD"
  ],
  "url": "https://knowyourmeme.com/memes/wololo"
}
```

一個 `RichTextObject` 共有三個 key：

- `text`：富文本將會顯示的文字。
- `style`：富文本的效果，目前可設定的有 `"ITALIC"`(斜體)、`"BOLD"`(粗體)、`"UNDERLINE"`(底線)。
- `url`：超連結網址。

上面的範例 `RichTextObject` 在畫面上將會顯示出：

[***Wololo***](https://knowyourmeme.com/memes/wololo)

接下來我們將分別詳介三個 key 的功能。

---

### `RichTextObject.text`

json

```
{
  "text": "Wololo"
}
```

`text` 即是富文本的文字，上述範例將會顯示：

Wololo

只要是 JSON 支援的字串(String)皆可使用，比如：

json

```
{
  "text": "\uD83D\uDCA9\n\uD83D\uDCA9\uD83D\uDCA9\n\uD83D\uDCA9\uD83D\uDCA9\uD83D\uDCA9"
}
```

將會顯示：

💩  
 💩💩  
 💩💩💩

`text` 可為 `null`，此時將會去查看是否有 `url`，若有 `url` 則會直接顯示 `url` 內容 [(見 `url`)](rich-text.md#RichTextObject.url)。  
 (若此時 `url` 也為空...痾...還是把這塊 `RichTextObject` 刪掉唄～它將不會起任何作用。)

---

### `RichTextObject.style`

json

```
{
  "text": "Wololo",
  "style": [
    "ITALIC"
  ]
}
```

`style` 需配合 `text` 或 `url` 生效，會在顯示的文字上產生指定效果。上述範例將會顯示：

*Wololo*

當前共定義了三種效果：

- `"ITALIC"`(斜體)：*Wololo*
- `"BOLD"`(粗體)：**Wololo**
- `"UNDERLINE"`(底線)：Wololo

三者也可任意組合，比如：

json

```
{
  "text": "Wololo",
  "style": [
    "ITALIC",
    "UNDERLINE"
  ]
}
```

將會顯示：

*Wololo*

* 注意：因超連結即會讓文字帶有底線，使用 [`url`(見下)](rich-text.md#RichTextObject.url) 時再在 `style` 加入 `"UNDERLINE"` 將不會起任何額外作用。

---

### `RichTextObject.url`

json

```
{
  "url": "https://www.google.com"
}
```

`url` 將會生成超連結，以上範例將會顯示：

[https://www.google.com](https://www.google.com)

`url` 也可搭配 `text` 一同使用：顯示文字為 `text` 而超連結會導向 `url`。見以下範例：

json

```
{
  "text": "ググール",
  "url": "https://www.google.co.jp"
}
```

將會顯示：

[ググール](https://www.google.co.jp)

## 組合 `RichTextObject`

上面段落已講解了各個 key 的作用，是時候將它們組合起來了。倘若今天想顯示的內容如下：

You Either **Die A Hero**, Or Live Long Enough To ***[Become A Meme](https://imgflip.com/i/3er8jc)***

可透過以下 JSON：

json

```
"rich_text": [
   {
     "text": "You Either "
   },
   {
     "text": "Die A Hero",
     "style": [
       "BOLD"
     ]
   },
   {
     "text": ", Or Live Long Enough To "
   },
   {
     "text": "Become A Meme",
     "style": [
       "BOLD",
       "ITALIC"
     ],
     "url": "https://imgflip.com/i/3er8jc"
   }
]
```
