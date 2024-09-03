<script setup>
import { ref } from 'vue';

const props = defineProps({
  texts: {
    type: Array,
    required: true
  }
});
</script>
<template>
  <div class="topic-list">
    <div v-for="(text, index) in texts" :key="index" class="topic-item">{{ text }}</div>
  </div>
</template>
<style scoped>
.topic-list {
  list-style-type: none;
  padding: 0;
}

.topic-item {
  background-color: #f0f0f0;
  padding: 10px;
  margin-bottom: 10px;
  border-radius: 5px;
}
</style>