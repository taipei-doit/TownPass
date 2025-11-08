<template>
  <div class="food-safety-page">
    <!-- AppBar -->
    <header class="app-bar">
      <div class="app-bar-left">
        <button @click="goNotification" class="app-bar-button">
          <span class="material-icons">notifications_none</span>
        </button>
        <button @click="goReceipt" class="app-bar-button">
          <span class="material-icons">receipt</span>
        </button>
      </div>
      <h1 class="app-bar-title">食品安全</h1>
      <div class="app-bar-right">
        <button @click="goBack" class="app-bar-button">
          <span class="material-icons">close</span>
        </button>
      </div>
    </header>

    <!-- Content -->
    <main class="content">
      <!-- Address Selector -->
      <div class="address-section">
        <div 
          class="address-card" 
          @click="toggleDropdown"
        >
          <span class="address-text">
            {{ isLoadingLocation ? "正在載入地址..." : selectedAddress }}
          </span>
          <div class="address-dropdown-icon">
            <span class="material-icons" :class="{ 'rotate-180': showDropdown }">expand_more</span>
          </div>
        </div>
        <!-- Dropdown positioned relative to address section -->
        <div 
            v-if="showDropdown"
          class="address-dropdown" 
          @click.stop
          >
          <div
              v-for="(address, index) in addressList"
              :key="index"
            class="address-dropdown-item"
            :class="{ 'address-dropdown-item--selected': address === selectedAddress }"
            @click.stop="selectAddress(address)"
          >
            <span class="address-item-text">{{ address }}</span>
            <button
              @click.stop="deleteAddress(address, index)"
              class="address-delete-button"
              :aria-label="`刪除地址 ${address}`"
            >
              <span class="material-icons">delete</span>
            </button>
          </div>
          <div class="address-dropdown-item address-dropdown-item--add" @click="goAddAddress">
            <span class="material-icons">add</span>
            <span>新增地址</span>
          </div>
        </div>
      </div>

      <!-- Map Section -->
      <div class="map-section">
        <div class="map-placeholder">
          <span class="material-icons map-icon">map</span>
          <p class="map-text">地圖預留區</p>
        </div>
      </div>

      <!-- Action Buttons -->
      <div class="action-buttons">
        <button
          class="action-button"
          :class="{ 'action-button--active': activeTab === 'store' }"
          @click="goStore"
        >
          店家
        </button>
        <button
          class="action-button"
          :class="{ 'action-button--active': activeTab === 'night-market' }"
          @click="goNightMarket"
        >
          夜市
        </button>
      </div>

      <!-- Latest News Section -->
      <section class="news-section">
        <div class="news-section-header">
          <h2 class="news-section-title">最新消息</h2>
          <button @click="goActivity" class="news-section-more">
            更多
          </button>
        </div>
        <div v-if="latestNews.length > 0" class="news-list">
          <article
            v-for="(news, index) in latestNews"
            :key="index"
            class="news-card"
            @click="goActivity"
          >
            <div class="news-card-content">
              <h3 class="news-card-title">{{ news.title }}</h3>
              <p class="news-card-date">{{ news.date }}</p>
            </div>
            <span class="material-icons news-card-arrow">chevron_right</span>
          </article>
        </div>
        <div v-else class="empty-state">
          <p class="empty-state-text">目前尚無最新消息</p>
        </div>
      </section>
    </main>

    <!-- Dropdown Overlay -->
    <div
      v-if="showDropdown"
      class="dropdown-overlay"
      @click="showDropdown = false"
    ></div>
  </div>
</template>

<script setup>
import { ref, onMounted, onUnmounted } from "vue";
import { useRouter } from "vue-router";
import { 
  initFlutterBridge, 
  getCurrentLocationAddress, 
  getUserInfo 
} from "@/utils/flutterBridge";

const router = useRouter();

// Address dropdown
const selectedAddress = ref("請選擇地址");
const addressList = ref([]);
const showDropdown = ref(false);
const isLoadingLocation = ref(false);

function toggleDropdown() {
  showDropdown.value = !showDropdown.value;
}

function selectAddress(address) {
  selectedAddress.value = address;
  showDropdown.value = false;
  // Save selected address to localStorage
  localStorage.setItem("foodSafetySelectedAddress", address);
}

function deleteAddress(address, index) {
  if (confirm(`確定要刪除地址「${address}」嗎？`)) {
    // Remove from list
    addressList.value.splice(index, 1);
    // Update localStorage
    if (addressList.value.length > 0) {
      localStorage.setItem("foodSafetyAddresses", JSON.stringify(addressList.value));
    } else {
      localStorage.removeItem("foodSafetyAddresses");
    }
    // If deleted address was selected, select first available address
    if (selectedAddress.value === address) {
      if (addressList.value.length > 0) {
        selectedAddress.value = addressList.value[0];
        localStorage.setItem("foodSafetySelectedAddress", addressList.value[0]);
      } else {
        // If no addresses left, set a default or empty message
        selectedAddress.value = "請新增地址";
        localStorage.removeItem("foodSafetySelectedAddress");
      }
    }
  }
}

// Tab navigation
const activeTab = ref("store");

function goStore() {
  activeTab.value = "store";
  router.push("/store");
}

function goNightMarket() {
  activeTab.value = "night-market";
  router.push("/night-market");
}

// Latest news
const latestNews = ref([
  { title: "食品安全檢驗報告更新", date: "2025/11/05" },
  { title: "夜市衛生宣導活動開跑", date: "2025/11/03" },
  { title: "最新餐廳稽查公告", date: "2025/11/01" },
]);

// Navigation
function goNotification() {
  router.push("/notification");
}

function goReceipt() {
  router.push("/receipt");
}

function goActivity() {
  router.push("/activities");
}

function goAddAddress() {
  showDropdown.value = false;
  router.push("/add-address");
}

function goBack() {
  router.back();
}

// Listen for address updates from AddAddressPage
function handleAddressAdded() {
  // Reload addresses from localStorage to ensure sync
  loadAddresses();
}

// Load addresses from localStorage on mount
function loadAddresses() {
  const savedAddresses = localStorage.getItem("foodSafetyAddresses");
  const savedSelected = localStorage.getItem("foodSafetySelectedAddress");
  if (savedAddresses) {
    const parsed = JSON.parse(savedAddresses);
    if (Array.isArray(parsed) && parsed.length > 0) {
      addressList.value = parsed;
      if (savedSelected && parsed.includes(savedSelected)) {
        selectedAddress.value = savedSelected;
      } else if (parsed.length > 0) {
        selectedAddress.value = parsed[0];
        localStorage.setItem("foodSafetySelectedAddress", parsed[0]);
      }
    }
  }
}

// 初始化地址：獲取當前位置和用戶地址
async function initializeAddresses() {
  // 檢查是否在App環境中
  const isInApp = initFlutterBridge();
  if (!isInApp) {
    console.log("Not running in app, using localStorage addresses only");
    loadAddresses();
    return;
  }

  isLoadingLocation.value = true;
  const newAddresses = [];
  const existingAddresses = new Set();

  // 1. 獲取當前位置並轉換為地址
  try {
    console.log("Getting current location...");
    const currentLocationAddress = await getCurrentLocationAddress();
    if (currentLocationAddress && currentLocationAddress.trim()) {
      newAddresses.push({
        address: currentLocationAddress.trim(),
        source: "location",
        isDefault: true
      });
      existingAddresses.add(currentLocationAddress.trim());
      console.log("Current location address:", currentLocationAddress);
    }
  } catch (error) {
    console.error("Failed to get current location:", error);
  }

  // 2. 獲取用戶的residentAddress
  try {
    console.log("Getting user info...");
    const userInfo = await getUserInfo();
    if (userInfo && userInfo.residentAddress && userInfo.residentAddress.trim()) {
      const residentAddress = userInfo.residentAddress.trim();
      if (!existingAddresses.has(residentAddress)) {
        newAddresses.push({
          address: residentAddress,
          source: "userinfo",
          isDefault: false
        });
        existingAddresses.add(residentAddress);
        console.log("User resident address:", residentAddress);
      }
    }
  } catch (error) {
    console.error("Failed to get user info:", error);
  }

  // 3. 加載已保存的地址
  const savedAddresses = localStorage.getItem("foodSafetyAddresses");
  if (savedAddresses) {
    try {
      const parsed = JSON.parse(savedAddresses);
      if (Array.isArray(parsed)) {
        parsed.forEach(addr => {
          if (typeof addr === 'string' && addr.trim() && !existingAddresses.has(addr.trim())) {
            newAddresses.push({
              address: addr.trim(),
              source: "saved",
              isDefault: false
            });
            existingAddresses.add(addr.trim());
          }
        });
      }
    } catch (error) {
      console.error("Failed to parse saved addresses:", error);
    }
  }

  // 4. 更新地址列表
  if (newAddresses.length > 0) {
    // 將地址轉換為字符串數組
    addressList.value = newAddresses.map(item => item.address);
    
    // 設置默認地址（優先使用當前位置）
    const defaultItem = newAddresses.find(item => item.isDefault) || newAddresses[0];
    if (defaultItem) {
      selectedAddress.value = defaultItem.address;
      localStorage.setItem("foodSafetySelectedAddress", defaultItem.address);
    }

    // 保存到localStorage
    localStorage.setItem("foodSafetyAddresses", JSON.stringify(addressList.value));
  } else {
    // 如果沒有獲取到任何地址，使用localStorage中的地址
    loadAddresses();
  }

  isLoadingLocation.value = false;
}

// Close dropdown when clicking outside
function handleClickOutside(event) {
  if (showDropdown.value && 
      !event.target.closest(".address-section") && 
      !event.target.closest(".address-dropdown")) {
    showDropdown.value = false;
  }
}

onMounted(async () => {
  // 初始化Flutter Bridge並獲取地址
  await initializeAddresses();
  document.addEventListener("click", handleClickOutside);
  window.addEventListener("address-added", handleAddressAdded);
});

onUnmounted(() => {
  document.removeEventListener("click", handleClickOutside);
  window.removeEventListener("address-added", handleAddressAdded);
});
</script>

<style scoped>
@import "@/styles/colors.css";
@import "https://fonts.googleapis.com/icon?family=Material+Icons";

.food-safety-page {
  min-height: 100vh;
  background-color: var(--grayscale-50);
  display: flex;
  flex-direction: column;
  position: relative;
}

/* AppBar */
.app-bar {
  background-color: var(--primary-500);
  box-shadow: 0 2px 8px rgba(11, 13, 14, 0.08);
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 12px 16px;
  height: 56px;
  position: relative;
}

.app-bar-left {
  display: flex;
  align-items: center;
  gap: 4px;
  flex-shrink: 0;
}

.app-bar-title {
  font-size: 24px;
  font-weight: 600;
  color: var(--white);
  margin: 0;
  text-align: center;
  position: absolute;
  left: 50%;
  transform: translateX(-50%);
  pointer-events: none;
  max-width: calc(100% - 200px);
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}

.app-bar-right {
  display: flex;
  align-items: center;
  justify-content: flex-end;
  flex-shrink: 0;
}

.app-bar-button {
  background: none;
  border: none;
  cursor: pointer;
  padding: 8px;
  display: flex;
  align-items: center;
  justify-content: center;
  color: var(--white);
}

.app-bar-button .material-icons {
  font-size: 20px;
}

/* Content */
.content {
  flex: 1;
  overflow-y: auto;
  padding: 16px;
  display: flex;
  flex-direction: column;
  gap: 20px;
}

/* Address Section */
.address-section {
  margin-bottom: 4px;
  position: relative;
}

.address-card {
  background-color: var(--white);
  border: 1px solid var(--grayscale-200);
  border-radius: 8px;
  padding: 12px 16px;
  display: flex;
  align-items: center;
  justify-content: space-between;
  box-shadow: 0 1px 3px rgba(11, 13, 14, 0.1);
  cursor: pointer;
  transition: background-color 0.2s;
  user-select: none;
}

.address-card:hover {
  background-color: var(--grayscale-50);
}

.address-card:active {
  background-color: var(--grayscale-100);
}

.address-text {
  font-size: 16px;
  font-weight: 500;
  color: var(--grayscale-800);
  flex: 1;
}

.address-dropdown-icon {
  display: flex;
  align-items: center;
  justify-content: center;
  color: var(--grayscale-700);
  transition: transform 0.3s ease;
}

.address-dropdown-icon .material-icons {
  font-size: 24px;
}

.address-dropdown-icon .material-icons.rotate-180 {
  transform: rotate(180deg);
}

.address-dropdown {
  position: absolute;
  top: calc(100% + 8px);
  left: 0;
  right: 0;
  width: 100%;
  background-color: var(--white);
  border: 1px solid var(--grayscale-200);
  border-radius: 8px;
  box-shadow: 0 4px 12px rgba(11, 13, 14, 0.15);
  z-index: 100;
  overflow: hidden;
  max-height: calc(100vh - 200px);
  overflow-y: auto;
}

.address-dropdown-item {
  padding: 12px 16px;
  font-size: 16px;
  color: var(--grayscale-800);
  cursor: pointer;
  transition: background-color 0.2s;
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 8px;
}

.address-dropdown-item:hover {
  background-color: var(--primary-50);
}

.address-dropdown-item--selected {
  background-color: var(--primary-50);
  color: var(--primary-600);
  font-weight: 600;
}

.address-item-text {
  flex: 1;
}

.address-delete-button {
  background: none;
  border: none;
  cursor: pointer;
  padding: 4px 8px;
  display: flex;
  align-items: center;
  justify-content: center;
  color: var(--grayscale-500);
  border-radius: 4px;
  transition: all 0.2s;
  flex-shrink: 0;
}

.address-delete-button:hover {
  background-color: var(--red-50);
  color: var(--red-600);
}

.address-delete-button .material-icons {
  font-size: 20px;
}

.address-dropdown-item--add {
  border-top: 1px solid var(--grayscale-100);
  color: var(--primary-500);
}

.address-dropdown-item--add .material-icons {
  font-size: 20px;
}

/* Map Section */
.map-section {
  margin-bottom: 4px;
}

.map-placeholder {
  width: 100%;
  height: 208px;
  background-color: var(--grayscale-100);
  border-radius: 12px;
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  gap: 8px;
}

.map-icon {
  font-size: 48px;
  color: var(--grayscale-400);
}

.map-text {
  font-size: 16px;
  color: var(--grayscale-500);
  margin: 0;
}

/* Action Buttons */
.action-buttons {
  display: flex;
  gap: 12px;
  margin-bottom: 4px;
}

.action-button {
  flex: 1;
  padding: 14px 24px;
  background-color: var(--white);
  border: 1px solid var(--grayscale-200);
  border-radius: 8px;
  font-size: 16px;
  font-weight: 600;
  color: var(--grayscale-700);
  cursor: pointer;
  transition: all 0.2s;
  box-shadow: 0 1px 3px rgba(11, 13, 14, 0.1);
}

.action-button:hover {
  background-color: var(--grayscale-50);
}

.action-button--active {
  background-color: var(--primary-500);
  border-color: var(--primary-500);
  color: var(--white);
  box-shadow: 0 2px 4px rgba(90, 180, 197, 0.3);
}

.action-button--active:hover {
  background-color: var(--primary-600);
}

/* News Section */
.news-section {
  display: flex;
  flex-direction: column;
  gap: 12px;
}

.news-section-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
}

.news-section-title {
  font-size: 18px;
  font-weight: 600;
  color: var(--grayscale-800);
  margin: 0;
}

.news-section-more {
  background: none;
  border: none;
  font-size: 14px;
  font-weight: 400;
  color: var(--primary-500);
  cursor: pointer;
  padding: 4px 8px;
}

.news-list {
  display: flex;
  flex-direction: column;
  gap: 12px;
}

.news-card {
  background-color: var(--white);
  border-radius: 8px;
  padding: 16px;
  display: flex;
  align-items: center;
  justify-content: space-between;
  box-shadow: 0 1px 3px rgba(11, 13, 14, 0.1);
  cursor: pointer;
  transition: background-color 0.2s;
}

.news-card:active {
  background-color: var(--primary-50);
}

.news-card-content {
  flex: 1;
  display: flex;
  flex-direction: column;
  gap: 4px;
}

.news-card-title {
  font-size: 16px;
  font-weight: 600;
  color: var(--grayscale-800);
  margin: 0;
}

.news-card-date {
  font-size: 14px;
  color: var(--grayscale-500);
  margin: 0;
}

.news-card-arrow {
  font-size: 24px;
  color: var(--grayscale-400);
  flex-shrink: 0;
}

/* Empty State */
.empty-state {
  display: flex;
  align-items: center;
  justify-content: center;
  padding: 32px 16px;
  text-align: center;
}

.empty-state-text {
  font-size: 16px;
  color: var(--grayscale-500);
  margin: 0;
}

/* Dropdown Overlay */
.dropdown-overlay {
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  z-index: 99;
  background-color: transparent;
}
</style>
