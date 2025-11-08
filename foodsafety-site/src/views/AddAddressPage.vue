<template>
  <div class="add-address-page">
    <!-- AppBar -->
    <header class="app-bar">
      <button @click="goBack" class="back-button">
        <span class="material-icons">arrow_back</span>
      </button>
      <h1 class="app-bar-title">新增地址</h1>
      <div class="app-bar-spacer"></div>
    </header>

    <!-- Content -->
    <main class="content">
      <div class="form-container">
        <div class="input-group">
          <label class="input-label">地址</label>
          <input
            v-model="address"
            type="text"
            placeholder="請輸入地址"
            class="input-field"
            @keyup.enter="saveAddress"
          />
        </div>

        <button
          @click="saveAddress"
          class="save-button"
          :class="{ 'save-button--disabled': !address.trim() }"
          :disabled="!address.trim()"
        >
          儲存
        </button>
      </div>
    </main>
  </div>
</template>

<script setup>
import { ref } from "vue";
import { useRouter } from "vue-router";

const router = useRouter();
const address = ref("");

function saveAddress() {
  if (address.value.trim()) {
    const newAddress = address.value.trim();
    // Save to localStorage first
    const savedAddresses = JSON.parse(localStorage.getItem("foodSafetyAddresses") || "[]");
    if (!savedAddresses.includes(newAddress)) {
      savedAddresses.push(newAddress);
      localStorage.setItem("foodSafetyAddresses", JSON.stringify(savedAddresses));
      localStorage.setItem("foodSafetySelectedAddress", newAddress);
    }
    // Emit custom event to notify parent component
    const event = new CustomEvent("address-added", {
      detail: newAddress,
      bubbles: true,
    });
    // Use nextTick to ensure event is dispatched before navigation
    setTimeout(() => {
      window.dispatchEvent(event);
      router.back();
    }, 0);
  }
}

function goBack() {
  router.back();
}
</script>

<style scoped>
@import "@/styles/colors.css";
@import "https://fonts.googleapis.com/icon?family=Material+Icons";

.add-address-page {
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

/* Form Container */
.form-container {
  display: flex;
  flex-direction: column;
  gap: 24px;
  max-width: 100%;
}

/* Input Group */
.input-group {
  display: flex;
  flex-direction: column;
  gap: 8px;
}

.input-label {
  font-size: 16px;
  font-weight: 600;
  color: var(--grayscale-800);
}

.input-field {
  width: 100%;
  padding: 12px 16px;
  border: 1px solid var(--grayscale-200);
  border-radius: 8px;
  background-color: var(--white);
  font-size: 16px;
  color: var(--grayscale-800);
  transition: border-color 0.2s;
}

.input-field::placeholder {
  color: var(--grayscale-400);
}

.input-field:focus {
  outline: none;
  border-color: var(--primary-500);
}

/* Save Button */
.save-button {
  width: 100%;
  padding: 14px 24px;
  background-color: var(--primary-500);
  color: var(--white);
  border: none;
  border-radius: 8px;
  font-size: 16px;
  font-weight: 600;
  cursor: pointer;
  transition: background-color 0.2s;
}

.save-button:hover:not(:disabled) {
  background-color: var(--primary-600);
}

.save-button:active:not(:disabled) {
  background-color: var(--primary-700);
}

.save-button--disabled {
  background-color: var(--grayscale-300);
  color: var(--grayscale-500);
  cursor: not-allowed;
}
</style>
