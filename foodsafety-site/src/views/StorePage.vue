<template>
  <div class="store-page">
    <!-- AppBar -->
    <header class="app-bar">
      <button @click="goBack" class="back-button">
        <span class="material-icons">arrow_back</span>
      </button>
      <h1 class="app-bar-title">店家查詢</h1>
      <div class="app-bar-spacer"></div>
    </header>

    <!-- Content -->
    <main class="content">
      <!-- Search Box -->
      <div class="search-container">
        <div class="search-box">
          <span class="material-icons search-icon">search</span>
          <input
            v-model="searchQuery"
            placeholder="搜尋店家名稱"
            class="search-input"
            type="text"
          />
        </div>
      </div>

      <!-- Filter Buttons -->
      <div class="filter-container">
        <button
          v-for="f in filters"
          :key="f"
          @click="toggleFilter(f)"
          class="filter-button"
          :class="{ 'filter-button--active': selectedFilters[f] }"
        >
          {{ f }}
        </button>
      </div>

      <!-- Store List -->
      <div v-if="filteredStores.length > 0" class="store-list">
        <div
          v-for="store in filteredStores"
          :key="store.name"
          class="store-card"
        >
          <div class="store-card-content">
            <div class="store-info">
              <h3 class="store-name">{{ store.name }}</h3>
              <p class="store-address">{{ store.address }}</p>
            </div>
            <span
              class="store-status"
              :class="{
                'store-status--warning': store.status === '限期改善',
                'store-status--success': store.status === '優良',
                'store-status--info': store.status === '合格'
              }"
            >
              {{ store.status }}
            </span>
          </div>
        </div>
      </div>

      <!-- Empty State -->
      <div v-else class="empty-state">
        <p class="empty-state-text">找不到符合條件的店家</p>
      </div>
    </main>
  </div>
</template>

<script setup>
import { reactive, ref, computed } from "vue";
import { useRouter } from "vue-router";

const router = useRouter();

const filters = ["限期改善", "合格", "優良"];
const selectedFilters = reactive({});
filters.forEach((f) => (selectedFilters[f] = false));

const searchQuery = ref("");

const mockStores = [
  { name: "阿明小吃", address: "台北市信義區松高路12號", status: "合格" },
  { name: "幸福滷味", address: "台北市中正區忠孝西路1號", status: "限期改善" },
  { name: "安心便當", address: "台北市大安區復興南路200號", status: "優良" },
];

function toggleFilter(f) {
  selectedFilters[f] = !selectedFilters[f];
}

const filteredStores = computed(() => {
  let result = mockStores.filter((store) =>
    store.name.includes(searchQuery.value)
  );
  const activeFilters = Object.keys(selectedFilters).filter((f) => selectedFilters[f]);
  if (activeFilters.length) {
    result = result.filter((s) => activeFilters.includes(s.status));
  }
  return result;
});

function goBack() {
  router.back();
}
</script>

<style scoped>
@import "@/styles/colors.css";
@import "https://fonts.googleapis.com/icon?family=Material+Icons";

.store-page {
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

/* Search Container */
.search-container {
  margin-bottom: 4px;
}

.search-box {
  position: relative;
  display: flex;
  align-items: center;
  background-color: var(--white);
  border: 1px solid var(--grayscale-200);
  border-radius: 8px;
  padding: 12px 16px;
}

.search-icon {
  color: var(--grayscale-500);
  font-size: 20px;
  margin-right: 12px;
  flex-shrink: 0;
}

.search-input {
  flex: 1;
  border: none;
  outline: none;
  font-size: 16px;
  color: var(--grayscale-800);
  background: transparent;
}

.search-input::placeholder {
  color: var(--grayscale-400);
}

.search-box:focus-within {
  border-color: var(--primary-500);
}

/* Filter Container */
.filter-container {
  display: flex;
  flex-wrap: wrap;
  gap: 8px;
}

.filter-button {
  padding: 6px 16px;
  border: 1px solid var(--grayscale-300);
  border-radius: 16px;
  background-color: var(--white);
  color: var(--grayscale-700);
  font-size: 14px;
  font-weight: 400;
  cursor: pointer;
  transition: all 0.2s;
}

.filter-button:hover {
  border-color: var(--primary-500);
  color: var(--primary-500);
}

.filter-button--active {
  background-color: var(--primary-500);
  border-color: var(--primary-500);
  color: var(--white);
}

/* Store List */
.store-list {
  display: flex;
  flex-direction: column;
  gap: 12px;
}

/* Store Card */
.store-card {
  background-color: var(--white);
  border-radius: 8px;
  padding: 16px;
  box-shadow: 0 1px 3px rgba(11, 13, 14, 0.1);
}

.store-card-content {
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
  gap: 16px;
}

.store-info {
  flex: 1;
  display: flex;
  flex-direction: column;
  gap: 4px;
}

.store-name {
  font-size: 16px;
  font-weight: 600;
  color: var(--grayscale-800);
  margin: 0;
}

.store-address {
  font-size: 14px;
  color: var(--grayscale-500);
  margin: 0;
}

.store-status {
  font-size: 14px;
  font-weight: 600;
  padding: 4px 12px;
  border-radius: 12px;
  white-space: nowrap;
  flex-shrink: 0;
}

.store-status--warning {
  background-color: var(--red-50);
  color: var(--red-600);
}

.store-status--success {
  background-color: var(--primary-50);
  color: var(--primary-600);
}

.store-status--info {
  background-color: var(--grayscale-100);
  color: var(--grayscale-700);
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
