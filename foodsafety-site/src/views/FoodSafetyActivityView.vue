<template>
  <div class="activity-page">
    <!-- AppBar -->
    <header class="app-bar">
      <button @click="goBack" class="back-button">
        <span class="material-icons">arrow_back</span>
      </button>
      <h1 class="app-bar-title">食品安全活動</h1>
      <div class="app-bar-spacer"></div>
    </header>

    <!-- Content -->
    <main class="content">
      <div v-if="allNews.length > 0" class="news-list">
        <article
          v-for="(news, i) in allNews"
          :key="i"
          class="news-item"
        >
          <div class="news-content">
            <h3 class="news-title">{{ news.title }}</h3>
            <div class="news-meta">
              <span class="news-date">{{ news.date }}</span>
              <span class="news-separator">｜</span>
              <p class="news-desc">{{ news.desc }}</p>
            </div>
          </div>
        </article>
      </div>
      <div v-else class="empty-state">
        <p class="empty-state-text">目前尚無活動資訊</p>
      </div>
    </main>
  </div>
</template>

<script setup>
import { useRouter } from "vue-router";

const router = useRouter();

const allNews = [
  { title: "食安稽查加強中", date: "2025-11-01", desc: "政府加強餐飲業抽驗，確保食品安全。" },
  { title: "夜市油品抽驗結果公布", date: "2025-10-28", desc: "多數油品合格，部分攤販需限期改善。" },
  { title: "最新防疫餐飲指南", date: "2025-10-25", desc: "最新防疫措施上路，餐廳需落實實聯制。" },
  { title: "校園午餐抽驗結果良好", date: "2025-10-20", desc: "全市學校午餐皆符合安全標準。" },
  { title: "食材溯源系統升級", date: "2025-10-15", desc: "消費者可線上查詢食材來源，提升透明度。" },
];

function goBack() {
  router.back();
}
</script>

<style scoped>
@import "@/styles/colors.css";
@import "https://fonts.googleapis.com/icon?family=Material+Icons";

.activity-page {
  min-height: 100vh;
  background-color: var(--grayscale-50);
  display: flex;
  flex-direction: column;
}

/* AppBar */
.app-bar {
  background-color: var(--white);
  box-shadow: 0 2px 8px rgba(11, 13, 14, 0.08);
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 12px 16px;
  height: 56px;
}

.back-button {
  background: none;
  border: none;
  cursor: pointer;
  padding: 8px;
  display: flex;
  align-items: center;
  justify-content: center;
  color: var(--grayscale-700);
}

.back-button .material-icons {
  font-size: 24px;
}

.app-bar-title {
  font-size: 18px;
  font-weight: 600;
  color: var(--primary-500);
  margin: 0;
  flex: 1;
  text-align: center;
}

.app-bar-spacer {
  width: 40px;
}

/* Content */
.content {
  flex: 1;
  overflow-y: auto;
  padding: 16px;
}

/* News List */
.news-list {
  display: flex;
  flex-direction: column;
  gap: 0;
}

/* News Item */
.news-item {
  background-color: var(--white);
  padding: 16px;
  border-bottom: 1px solid var(--grayscale-100);
  cursor: pointer;
  transition: background-color 0.2s;
}

.news-item:active {
  background-color: var(--grayscale-50);
}

.news-item:last-child {
  border-bottom: none;
}

.news-content {
  display: flex;
  flex-direction: column;
  gap: 8px;
}

.news-title {
  font-size: 16px;
  font-weight: 600;
  color: var(--grayscale-800);
  margin: 0;
  line-height: 1.5;
}

.news-meta {
  display: flex;
  align-items: flex-start;
  flex-wrap: wrap;
  gap: 4px;
  font-size: 14px;
  color: var(--grayscale-600);
  line-height: 1.5;
}

.news-date {
  color: var(--grayscale-500);
  white-space: nowrap;
}

.news-separator {
  color: var(--grayscale-400);
}

.news-desc {
  margin: 0;
  color: var(--grayscale-600);
  flex: 1;
  min-width: 0;
}

/* Empty State */
.empty-state {
  display: flex;
  align-items: center;
  justify-content: center;
  padding: 64px 16px;
  text-align: center;
}

.empty-state-text {
  font-size: 16px;
  color: var(--grayscale-500);
  margin: 0;
}
</style>
