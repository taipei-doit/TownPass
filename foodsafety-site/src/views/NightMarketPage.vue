<template>
  <div class="night-market-page">
    <!-- AppBar -->
    <header class="app-bar">
      <button @click="goBack" class="back-button">
        <span class="material-icons">arrow_back</span>
      </button>
      <h1 class="app-bar-title">夜市資訊</h1>
      <div class="app-bar-spacer"></div>
    </header>

    <!-- Content -->
    <main class="content">
      <!-- Market Selector -->
      <div class="market-selector-container">
        <select v-model="selectedMarket" class="market-selector">
          <option v-for="m in nightMarkets" :key="m" :value="m">{{ m }}</option>
        </select>
      </div>

      <!-- Lists -->
      <div v-if="selectedUnqualified.length || selectedGood.length" class="lists-container">
        <!-- Unqualified Shops -->
        <section v-if="selectedUnqualified.length" class="shop-section">
          <h2 class="section-title">不合格名單</h2>
          <div class="shop-list">
            <div
              v-for="shop in selectedUnqualified"
              :key="shop.name"
              class="shop-card shop-card--warning"
            >
              <div class="shop-card-content">
                <div class="shop-info">
                  <h3 class="shop-name">{{ shop.name }}</h3>
                  <p class="shop-address">{{ shop.address }}</p>
                </div>
                <span class="shop-status shop-status--warning">{{ shop.status }}</span>
              </div>
            </div>
          </div>
        </section>

        <!-- Good Shops -->
        <section v-if="selectedGood.length" class="shop-section">
          <h2 class="section-title">優良名單</h2>
          <div class="shop-list">
            <div
              v-for="shop in selectedGood"
              :key="shop.name"
              class="shop-card shop-card--success"
            >
              <div class="shop-card-content">
                <div class="shop-info">
                  <h3 class="shop-name">{{ shop.name }}</h3>
                  <p class="shop-address">{{ shop.address }}</p>
                </div>
                <span class="shop-status shop-status--success">{{ shop.status }}</span>
              </div>
            </div>
          </div>
        </section>
      </div>

      <!-- Empty State -->
      <div v-else class="empty-state">
        <p class="empty-state-text">目前尚無資料</p>
      </div>
    </main>
  </div>
</template>

<script setup>
import { ref, computed } from "vue";
import { useRouter } from "vue-router";

const router = useRouter();

const nightMarkets = ["饒河夜市", "士林夜市", "逢甲夜市"];
const selectedMarket = ref(nightMarkets[0]);

const unqualifiedShops = {
  饒河夜市: [
    { name: "阿明臭豆腐", address: "台北市松山區八德路", status: "限期改善" },
    { name: "小美烤魷魚", address: "台北市松山區饒河街", status: "不合格" },
  ],
  士林夜市: [],
  逢甲夜市: [{ name: "阿雄滷味", address: "台中市西屯區逢甲路", status: "限期改善" }],
};

const goodShops = {
  饒河夜市: [
    { name: "小王排骨酥", address: "台北市松山區饒河街", status: "優" },
    { name: "黃家胡椒餅", address: "台北市松山區八德路", status: "良" },
  ],
  士林夜市: [{ name: "大頭雞排", address: "台北市士林區文林路", status: "優" }],
  逢甲夜市: [],
};

const selectedUnqualified = computed(() => unqualifiedShops[selectedMarket.value] || []);
const selectedGood = computed(() => goodShops[selectedMarket.value] || []);

function goBack() {
  router.back();
}
</script>

<style scoped>
@import "@/styles/colors.css";
@import "https://fonts.googleapis.com/icon?family=Material+Icons";

.night-market-page {
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

/* Market Selector */
.market-selector-container {
  margin-bottom: 20px;
}

.market-selector {
  width: 100%;
  padding: 12px 16px;
  border: 1px solid var(--grayscale-200);
  border-radius: 8px;
  background-color: var(--white);
  font-size: 16px;
  color: var(--grayscale-800);
  cursor: pointer;
  appearance: none;
  background-image: url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' width='12' height='12' viewBox='0 0 12 12'%3E%3Cpath fill='%23475259' d='M6 9L1 4h10z'/%3E%3C/svg%3E");
  background-repeat: no-repeat;
  background-position: right 16px center;
  padding-right: 40px;
}

.market-selector:focus {
  outline: none;
  border-color: var(--primary-500);
}

/* Lists Container */
.lists-container {
  display: flex;
  flex-direction: column;
  gap: 24px;
}

/* Section */
.shop-section {
  display: flex;
  flex-direction: column;
  gap: 12px;
}

.section-title {
  font-size: 18px;
  font-weight: 600;
  color: var(--grayscale-800);
  margin: 0;
}

/* Shop List */
.shop-list {
  display: flex;
  flex-direction: column;
  gap: 12px;
}

/* Shop Card */
.shop-card {
  background-color: var(--white);
  border-radius: 8px;
  padding: 16px;
  box-shadow: 0 1px 3px rgba(11, 13, 14, 0.1);
}

.shop-card--warning {
  border-left: 4px solid var(--red-500);
}

.shop-card--success {
  border-left: 4px solid var(--primary-500);
}

.shop-card-content {
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
  gap: 16px;
}

.shop-info {
  flex: 1;
  display: flex;
  flex-direction: column;
  gap: 4px;
}

.shop-name {
  font-size: 16px;
  font-weight: 600;
  color: var(--grayscale-800);
  margin: 0;
}

.shop-address {
  font-size: 14px;
  color: var(--grayscale-500);
  margin: 0;
}

.shop-status {
  font-size: 14px;
  font-weight: 600;
  padding: 4px 12px;
  border-radius: 12px;
  white-space: nowrap;
}

.shop-status--warning {
  background-color: var(--red-50);
  color: var(--red-600);
}

.shop-status--success {
  background-color: var(--primary-50);
  color: var(--primary-600);
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
