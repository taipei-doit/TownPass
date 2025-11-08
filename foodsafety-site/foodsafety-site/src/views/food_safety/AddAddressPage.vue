<template>
  <div class="add-address-page">
    <h1>新增地址</h1>
    <form @submit.prevent="submitAddress">
      <div>
        <label for="address">地址:</label>
        <input type="text" id="address" v-model="address" required />
      </div>
      <div>
        <label for="city">城市:</label>
        <input type="text" id="city" v-model="city" required />
      </div>
      <div>
        <label for="postalCode">郵遞區號:</label>
        <input type="text" id="postalCode" v-model="postalCode" required />
      </div>
      <button type="submit">提交</button>
    </form>
  </div>
</template>

<script>
export default {
  data() {
    return {
      address: '',
      city: '',
      postalCode: ''
    };
  },
  methods: {
    submitAddress() {
      // 提交地址的邏輯
      console.log('地址已提交:', {
        address: this.address,
        city: this.city,
        postalCode: this.postalCode
      });
      // 清空表單
      this.address = '';
      this.city = '';
      this.postalCode = '';
    }
  }
};
</script>

<style scoped>
.add-address-page {
  max-width: 400px;
  margin: auto;
}
form {
  display: flex;
  flex-direction: column;
}
label {
  margin: 10px 0 5px;
}
input {
  padding: 8px;
  margin-bottom: 15px;
}
button {
  padding: 10px;
  background-color: #4CAF50;
  color: white;
  border: none;
  cursor: pointer;
}
button:hover {
  background-color: #45a049;
}
</style>