# 元件目錄（自動產生）

> 由 `node tools/check-arch.mjs --catalog` 從各元件的 `@component` 標頭產生，請勿手動編輯。

| 編號 | 元件 | 說明 | 檔案（services/web/src/） |
|---|---|---|---|
| A01 | BaseButton | 按鈕（primary/secondary/outline/ghost/danger） | `ui/atoms/BaseButton.vue` |
| A02 | BaseTag | 小標籤 | `ui/atoms/BaseTag.vue` |
| A03 | BaseChip | 圓角選項（快捷/篩選） | `ui/atoms/BaseChip.vue` |
| A04 | BaseInput | 文字輸入（單行/多行） | `ui/atoms/BaseInput.vue` |
| A05 | SkeletonBlock | 載入中佔位 | `ui/atoms/SkeletonBlock.vue` |
| A06 | IconBadge | 圓形圖示底 | `ui/atoms/IconBadge.vue` |
| A07 | SourceNote | 資料來源註記（競賽規則要求標示出處） | `ui/atoms/SourceNote.vue` |
| EX-C01 | CategoryFilter | 分類篩選 chips | `features/example/ui/CategoryFilter.vue` |
| EX-C02 | FavoriteButton | 收藏切換（需要登入） | `features/example/ui/FavoriteButton.vue` |
| EX-P01 | PlaceListPage | 範例：設施列表 | `features/example/ui/PlaceListPage.vue` |
| EX-P02 | PlaceDetailPage | 範例：設施詳細頁 | `features/example/ui/PlaceDetailPage.vue` |
| M01 | BaseCard | 卡片容器 | `ui/molecules/BaseCard.vue` |
| M02 | ListItem | 列表列 | `ui/molecules/ListItem.vue` |
| M03 | SectionTitle | 區塊標題 | `ui/molecules/SectionTitle.vue` |
| M04 | CollapseItem | 可展開列 | `ui/molecules/CollapseItem.vue` |
| M05 | EmptyState | 空狀態 | `ui/molecules/EmptyState.vue` |
| M06 | InfoTable | 標籤/值資訊列 | `ui/molecules/InfoTable.vue` |
| M07 | ResultCard | 搜尋結果卡片（圖示 + 標題 + 副標 + 標籤） | `ui/molecules/ResultCard.vue` |
| M08 | ChatBubble | 對話泡泡（使用者靠右、系統靠左） | `ui/molecules/ChatBubble.vue` |
| M09 | ChipRail | 可橫向捲動的 chips 列（放 BaseChip） | `ui/molecules/ChipRail.vue` |
| O01 | BaseSheet | 底部面板 | `ui/organisms/BaseSheet.vue` |
| O02 | OsmMap | OpenStreetMap 地圖 | `ui/organisms/OsmMap.vue` |
| O03 | NoticeList | 注意事項清單（第一項預設展開） | `ui/organisms/NoticeList.vue` |
| O04 | ChatComposer | 對話輸入列（快捷 chips + 輸入框 + 送出） | `ui/organisms/ChatComposer.vue` |
| O05 | ChatThread | 對話紀錄（泡泡 + 結果卡片 + 找不到時的建議） | `ui/organisms/ChatThread.vue` |
| O06 | FeatureGrid | 服務卡片兩欄網格 | `ui/organisms/FeatureGrid.vue` |
| O07 | RecentStrip | 近期使用（橫向 chips） | `ui/organisms/RecentStrip.vue` |
| P01 | HomePage | 首頁（對話框單一入口） | `pages/HomePage.vue` |
| P02 | SourcesPage | 資料來源 | `pages/SourcesPage.vue` |
| P03 | UiGalleryPage | UI 元件總覽（每個元件標示編號） | `pages/UiGalleryPage.vue` |
| T01 | PageContainer | 頁面外框 | `ui/templates/PageContainer.vue` |
| T02 | DetailPage | 詳細頁模板 | `ui/templates/DetailPage.vue` |
| XX-P01 | TemplatePage | 新功能首頁 | `features/_template/ui/TemplatePage.vue` |
