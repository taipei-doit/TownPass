<template>
  <div class="food-safety-activity-view">
    <h1>食品安全活動詳情</h1>
    <p>這裡是活動的描述，提供有關食品安全活動的詳細資訊。</p>
    <img src="../assets/activity-image.jpg" alt="活動圖片" />
  </div>
</template>

<script>
export default {
  name: 'FoodSafetyActivityView',
};
</script>

<style scoped>
.food-safety-activity-view {
  padding: 20px;
}
.food-safety-activity-view h1 {
  font-size: 24px;
  margin-bottom: 10px;
}
.food-safety-activity-view p {
  font-size: 16px;
  margin-bottom: 20px;
}
.food-safety-activity-view img {
  max-width: 100%;
  height: auto;
}
</style>