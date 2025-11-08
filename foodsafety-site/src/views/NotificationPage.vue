<template>
  <div class="notification-page">
    <!-- AppBar -->
    <header class="app-bar">
      <button @click="goBack" class="back-button">
        <span class="material-icons">arrow_back</span>
      </button>
      <h1 class="app-bar-title">通知中心</h1>
      <div class="app-bar-spacer"></div>
    </header>

    <!-- Content -->
    <main class="content">
      <div v-if="notifications.length > 0" class="notification-list">
        <div
          v-for="(n, i) in notifications"
          :key="i"
          @click="markAsRead(n)"
          class="notification-card"
          :class="{ 'notification-card--read': n.isRead }"
        >
          <div class="notification-indicator" :class="{ 'notification-indicator--read': n.isRead }"></div>
          <div class="notification-content">
            <div class="notification-header">
              <span class="material-icons notification-icon" :class="{ 'notification-icon--read': n.isRead }">
                {{ n.isRead ? 'notifications_none' : 'notifications_active' }}
              </span>
              <h3 class="notification-title" :class="{ 'notification-title--read': n.isRead }">
                {{ n.title }}
              </h3>
            </div>
            <p class="notification-text">{{ n.content }}</p>
          </div>
        </div>
      </div>
      <div v-else class="empty-state">
        <p class="empty-state-text">目前尚無通知</p>
      </div>
    </main>
  </div>
</template>

<script setup>
import { reactive } from "vue";
import { useRouter } from "vue-router";

const router = useRouter();

const notifications = reactive([
  { title: "食品安全快訊", content: "最新抽驗結果已公布。", isRead: false },
  { title: "夜市衛生稽查公告", content: "部分攤商需限期改善。", isRead: true },
  { title: "防疫新規提醒", content: "請配合政府防疫規範。", isRead: false },
]);

function markAsRead(n) {
  n.isRead = true;
}

function goBack() {
  router.back();
}
</script>

<style scoped>
@import "@/styles/colors.css";
@import "https://fonts.googleapis.com/icon?family=Material+Icons";

.notification-page {
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
  padding: 12px 0;
}

/* Notification List */
.notification-list {
  display: flex;
  flex-direction: column;
  gap: 0;
}

/* Notification Card */
.notification-card {
  background-color: var(--white);
  padding: 16px;
  display: flex;
  align-items: flex-start;
  gap: 16px;
  cursor: pointer;
  transition: background-color 0.2s;
  border-bottom: 1px solid var(--grayscale-100);
}

.notification-card:active {
  background-color: var(--grayscale-50);
}

.notification-card--read {
  background-color: var(--grayscale-100);
}

.notification-card--read:active {
  background-color: var(--grayscale-200);
}

/* Notification Indicator */
.notification-indicator {
  width: 10px;
  height: 10px;
  border-radius: 50%;
  background-color: var(--primary-500);
  flex-shrink: 0;
  margin-top: 6px;
}

.notification-indicator--read {
  background-color: var(--primary-100);
}

/* Notification Content */
.notification-content {
  flex: 1;
  display: flex;
  flex-direction: column;
  gap: 4px;
}

.notification-header {
  display: flex;
  align-items: center;
  gap: 16px;
}

.notification-icon {
  font-size: 20px;
  color: var(--primary-500);
  flex-shrink: 0;
}

.notification-icon--read {
  color: var(--grayscale-600);
}

.notification-title {
  font-size: 16px;
  font-weight: 600;
  color: var(--grayscale-800);
  margin: 0;
  flex: 1;
}

.notification-title--read {
  font-weight: 400;
  color: var(--grayscale-500);
}

.notification-text {
  font-size: 14px;
  color: var(--grayscale-600);
  margin: 0;
  padding-left: 36px;
  line-height: 1.5;
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
