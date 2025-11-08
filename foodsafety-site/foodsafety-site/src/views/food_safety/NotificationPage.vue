<template>
  <div class="notification-page">
    <h1>最新食品安全通知</h1>
    <ul>
      <li v-for="notification in notifications" :key="notification.id">
        <h2>{{ notification.title }}</h2>
        <p>{{ notification.message }}</p>
        <span>{{ notification.date }}</span>
      </li>
    </ul>
  </div>
</template>

<script>
export default {
  data() {
    return {
      notifications: [
        {
          id: 1,
          title: '食品安全警示',
          message: '請注意，某品牌的牛奶可能受到污染，請勿食用。',
          date: '2023-10-01'
        },
        {
          id: 2,
          title: '最新檢查結果',
          message: '最近的食品檢查顯示，某些餐廳的衛生狀況不佳，請小心選擇。',
          date: '2023-10-02'
        }
      ]
    };
  }
};
</script>

<style scoped>
.notification-page {
  padding: 20px;
}

.notification-page h1 {
  color: #333;
}

.notification-page ul {
  list-style-type: none;
  padding: 0;
}

.notification-page li {
  margin-bottom: 15px;
  border: 1px solid #ccc;
  padding: 10px;
  border-radius: 5px;
}

.notification-page h2 {
  margin: 0;
  font-size: 1.2em;
}

.notification-page p {
  margin: 5px 0;
}

.notification-page span {
  font-size: 0.9em;
  color: #777;
}
</style>