# 資料來源 Data sources

競賽規則：核心資料必須使用公開且合法的開放資料，並註明來源；非必要資料可用模擬資料。
**每用到一個資料集就在下面加一列**，demo 時評審可能會問。App 內也要有頁面顯示這些來源。

| 資料集 | 提供機關 | 網址 | 授權 | 用途 | 真實/模擬 |
|---|---|---|---|---|---|
| （範例）YouBike 2.0 即時資訊 | 臺北市交通局 | https://data.taipei/ | 政府資料開放授權條款 1.0 | 地圖顯示站點 | 真實 |
| OpenStreetMap 地圖（線上圖磚、隨附的大臺北底圖 `maps/taipei.pmtiles`，由 Protomaps 建置） | OpenStreetMap contributors | https://www.openstreetmap.org/copyright | ODbL 1.0 | 地圖底圖 | 真實 |

可用平台：
- 臺北資料大平台 https://data.taipei/ — API：`https://data.taipei/api/v1/dataset/<resource_id>?scope=resourceAquire`
- 政府資料開放平臺 https://data.gov.tw/
- 城市通 https://townpass.taipei/
- 臺北市資訊局 GitHub https://github.com/taipei-doit

## 裝置端模型

完整清單與授權見 [10-architecture.md](../docs/system/10-architecture.md) §2。Gemma is provided under and subject to the Gemma Terms of Use found at https://ai.google.dev/gemma/terms

`services/web/eval/` 的測試文件全部是虛構資料，只用於評測，不會隨網站提供給使用者。
