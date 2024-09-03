<script setup>
// Add any necessary imports and logic here
</script>

<template>
  <div class="container">
    <h1 class="title">
      文化時空隧道
      <span class="sparkle">✨</span>
    </h1>

    <p class="description">
      上傳照片，立即生成精彩描述；模擬歷史事件，體驗不同時代的故事；提問與討論，隨時解答您的好奇心；與歷史人物對話，感受他們的智慧與情感。讓我們一起探索台北的魅力吧！
    </p>

    <button class="primary-button" @click="navigateTo('/chat')">立即使用!</button>

    <p class="subtitle">或是考慮聊聊這些話題</p>

    <TextList :texts="['台北101', '故宮博物院', '中正紀念堂', '台北車站', '西門町']" />
  </div>
</template>

<style scoped>
.container {
  max-width: 600px;
  margin: 0 auto;
  padding: 20px;
  font-family: Arial, sans-serif;
}

.title {
  font-size: 24px;
  font-weight: bold;
  margin-bottom: 20px;
}

.sparkle {
  color: gold;
  margin-left: 5px;
}

.description {
  font-size: 16px;
  line-height: 1.5;
  margin-bottom: 20px;
}

.primary-button {
  background-color: #5fb0c9;
  color: white;
  border: none;
  padding: 10px 20px;
  border-radius: 5px;
  font-size: 16px;
  cursor: pointer;
}

.subtitle {
  font-size: 18px;
  margin-top: 20px;
  margin-bottom: 10px;
}

</style>