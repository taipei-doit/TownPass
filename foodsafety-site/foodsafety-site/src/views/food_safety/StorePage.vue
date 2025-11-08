<template>
  <div class="store-page">
    <h1>商店資訊</h1>
    <div class="store-details">
      <h2>商店名稱: {{ storeName }}</h2>
      <p>地址: {{ storeAddress }}</p>
      <p>聯絡方式: {{ storeContact }}</p>
    </div>
  </div>
</template>

<script>
export default {
  data() {
    return {
      storeName: '範例商店',
      storeAddress: '範例地址',
      storeContact: '範例聯絡方式'
    };
  }
};
</script>

<style scoped>
.store-page {
  padding: 20px;
}

.store-details {
  margin-top: 10px;
}
</style>