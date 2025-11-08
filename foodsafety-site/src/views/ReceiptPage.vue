<template>
  <div class="receipt-page">
    <!-- AppBar -->
    <header class="app-bar">
      <button @click="goBack" class="back-button">
        <span class="material-icons">arrow_back</span>
      </button>
      <h1 class="app-bar-title">發票資訊</h1>
      <div class="app-bar-spacer"></div>
    </header>

    <!-- Content -->
    <main class="content">
      <!-- Month Selector -->
      <div class="month-selector">
        <button @click="prevMonth" class="month-nav-button">
          <span class="material-icons">chevron_left</span>
        </button>
        <h2 class="month-title">{{ currentMonthText }}</h2>
        <button @click="nextMonth" class="month-nav-button">
          <span class="material-icons">chevron_right</span>
        </button>
      </div>

      <!-- Receipt List -->
      <div v-if="currentMonthReceipts.length > 0" class="receipt-list">
        <article
          v-for="(receipt, index) in currentMonthReceipts"
          :key="index"
          class="receipt-card"
          :class="{ 'receipt-card--error': receipt.hasError }"
        >
          <div class="receipt-card-content">
            <div class="receipt-header">
              <h3 class="receipt-title">{{ receipt.storeName }}</h3>
              <span v-if="receipt.hasError" class="receipt-error-badge">問題</span>
            </div>
            <div class="receipt-info">
              <p class="receipt-date">{{ receipt.date }}</p>
              <p class="receipt-amount">NT$ {{ receipt.amount }}</p>
            </div>
            <p v-if="receipt.description" class="receipt-description">{{ receipt.description }}</p>
          </div>
          <span class="material-icons receipt-card-arrow">chevron_right</span>
        </article>
      </div>
      <div v-else class="empty-state">
        <p class="empty-state-text">此月份尚無發票資料</p>
      </div>
    </main>
  </div>
</template>

<script setup>
import { ref, computed } from "vue";
import { useRouter } from "vue-router";

const router = useRouter();

// Current month
const currentDate = ref(new Date());

// Mock receipt data
const receipts = ref([
  {
    id: 1,
    storeName: "7-ELEVEN 信義店",
    date: "2025-11-15",
    amount: 150,
    description: "購買食品",
    hasError: false,
  },
  {
    id: 2,
    storeName: "全家便利商店 松山店",
    date: "2025-11-12",
    amount: 280,
    description: "購買飲料",
    hasError: true,
  },
  {
    id: 3,
    storeName: "全聯福利中心 信義店",
    date: "2025-11-10",
    amount: 1250,
    description: "購買日用品",
    hasError: false,
  },
  {
    id: 4,
    storeName: "家樂福 大直店",
    date: "2025-11-05",
    amount: 3200,
    description: "購買生鮮食品",
    hasError: true,
  },
  {
    id: 5,
    storeName: "麥當勞 信義店",
    date: "2025-10-28",
    amount: 220,
    description: "購買餐點",
    hasError: false,
  },
  {
    id: 6,
    storeName: "星巴克 101店",
    date: "2025-10-25",
    amount: 180,
    description: "購買咖啡",
    hasError: false,
  },
  {
    id: 7,
    storeName: "屈臣氏 信義店",
    date: "2025-10-20",
    amount: 450,
    description: "購買生活用品",
    hasError: true,
  },
]);

// Get current month text
const currentMonthText = computed(() => {
  const year = currentDate.value.getFullYear();
  const month = currentDate.value.getMonth() + 1;
  return `${year}年${month}月`;
});

// Get receipts for current month
const currentMonthReceipts = computed(() => {
  const year = currentDate.value.getFullYear();
  const month = currentDate.value.getMonth();
  return receipts.value.filter((receipt) => {
    const receiptDate = new Date(receipt.date);
    return (
      receiptDate.getFullYear() === year && receiptDate.getMonth() === month
    );
  });
});

function prevMonth() {
  const newDate = new Date(currentDate.value);
  newDate.setMonth(newDate.getMonth() - 1);
  currentDate.value = newDate;
}

function nextMonth() {
  const newDate = new Date(currentDate.value);
  newDate.setMonth(newDate.getMonth() + 1);
  currentDate.value = newDate;
}

function goBack() {
  router.back();
}
</script>

<style scoped>
@import "@/styles/colors.css";
@import "https://fonts.googleapis.com/icon?family=Material+Icons";

.receipt-page {
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
  display: flex;
  flex-direction: column;
  gap: 16px;
}

/* Month Selector */
.month-selector {
  display: flex;
  align-items: center;
  justify-content: space-between;
  background-color: var(--white);
  border-radius: 8px;
  padding: 12px 16px;
  box-shadow: 0 1px 3px rgba(11, 13, 14, 0.1);
}

.month-nav-button {
  background: none;
  border: none;
  cursor: pointer;
  padding: 8px;
  display: flex;
  align-items: center;
  justify-content: center;
  color: var(--grayscale-700);
  border-radius: 4px;
  transition: background-color 0.2s;
}

.month-nav-button:hover {
  background-color: var(--grayscale-50);
}

.month-nav-button .material-icons {
  font-size: 24px;
}

.month-title {
  font-size: 18px;
  font-weight: 600;
  color: var(--grayscale-800);
  margin: 0;
}

/* Receipt List */
.receipt-list {
  display: flex;
  flex-direction: column;
  gap: 12px;
}

/* Receipt Card */
.receipt-card {
  background-color: var(--white);
  border-radius: 8px;
  padding: 16px;
  display: flex;
  align-items: center;
  justify-content: space-between;
  box-shadow: 0 1px 3px rgba(11, 13, 14, 0.1);
  cursor: pointer;
  transition: background-color 0.2s;
  border-left: 4px solid transparent;
}

.receipt-card:active {
  background-color: var(--grayscale-50);
}

.receipt-card--error {
  background-color: var(--red-50);
  border-left-color: var(--red-500);
}

.receipt-card--error:active {
  background-color: var(--red-100);
}

.receipt-card-content {
  flex: 1;
  display: flex;
  flex-direction: column;
  gap: 8px;
}

.receipt-header {
  display: flex;
  align-items: center;
  gap: 8px;
}

.receipt-title {
  font-size: 16px;
  font-weight: 600;
  color: var(--grayscale-800);
  margin: 0;
}

.receipt-error-badge {
  font-size: 12px;
  font-weight: 600;
  color: var(--white);
  background-color: var(--red-500);
  padding: 2px 8px;
  border-radius: 12px;
}

.receipt-info {
  display: flex;
  align-items: center;
  gap: 16px;
}

.receipt-date {
  font-size: 14px;
  color: var(--grayscale-500);
  margin: 0;
}

.receipt-amount {
  font-size: 16px;
  font-weight: 600;
  color: var(--primary-600);
  margin: 0;
}

.receipt-description {
  font-size: 14px;
  color: var(--grayscale-600);
  margin: 0;
}

.receipt-card-arrow {
  font-size: 24px;
  color: var(--grayscale-400);
  flex-shrink: 0;
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

