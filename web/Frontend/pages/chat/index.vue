<script setup>
const config = useRuntimeConfig();

const messageLists = ref([]);
const tempUserMessage = ref('');
const isLoading = ref(false);

const add_user_message = async () => {
  if (tempUserMessage.value.trim()) {
    messageLists.value.push({
      type: 'user',
      text: tempUserMessage.value
    });
    const userMessage = tempUserMessage.value;
    tempUserMessage.value = '';
    
    // Show loading state
    isLoading.value = true;
    
    try {
      const gptResponse = await get_gpt_response(userMessage);
      messageLists.value.push({
        type: 'ai',
        text: gptResponse
      });
    } catch (error) {
      console.error('Error getting GPT response:', error);
      messageLists.value.push({
        type: 'ai',
        text: 'Sorry, I encountered an error. Please try again.'
      });
    } finally {
      isLoading.value = false;
    }
  }
};

const get_gpt_response = async (message) => {
  const { data, error } = await useFetch(config.public.AZURE_ENDPOINT, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      'api-key': config.public.AZURE_API_KEY
    },
    body: JSON.stringify({
      messages: [
        {
          role: "system",
          content: "You are an AI assistant that helps people find information."
        },
        {
          role: "user",
          content: message
        }
      ],
      temperature: 0.7,
      top_p: 0.95,
      max_tokens: 800
    }),
  });

  if (error.value) {
    throw new Error(error.value.message);
  }
  console.log('data.value', data.value);
  return data.value.choices[0].message.content;
};
</script>
<template>
  <div class="container">
    <header>
      <button class="menu-button">☰</button>
      <h1 class="title">
        文化時空隧道
        <span class="sparkle">✨</span>
      </h1>
    </header>

    <main>
      <p class="description">
        上傳照片，立即生成精彩描述；模擬歷史事件，體驗不同時代的故事；提問與討論，隨時解答您的好奇心；與歷史人物對話，感受他們的智慧與情感。讓我們一起探索台北的魅力吧！
      </p>
      <div class="message-container">
        <div v-for="(message, index) in messageLists" :key="index"
          :class="['message', message.type === 'user' ? 'user-message' : 'ai-message']">
          {{ message.text }}
        </div>
        <div v-if="isLoading" class="message ai-message">
          Thinking...
        </div>

      </div>
    </main>

    <footer>
      <div class="input-container">
        <button class="voice-input">🎤</button>
        <button class="image-upload">🖼️</button>
        <input type="text" placeholder="輸入訊息" class="text-input" v-model="tempUserMessage"
          @keyup.enter="add_user_message">
        <button class="send-message" @click="add_user_message" style="color: white;"><svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24">
            <title>send</title>
            <path d="M2,21L23,12L2,3V10L17,12L2,14V21Z" />
          </svg></button>
      </div>
    </footer>
  </div>
</template>

<style scoped>
.container {
  display: flex;
  flex-direction: column;
  height: 100vh;
  font-family: Arial, sans-serif;
}

header {
  display: flex;
  align-items: center;
  padding: 10px;
}

.menu-button {
  font-size: 24px;
  background: none;
  border: none;
  cursor: pointer;
}

.title {
  font-size: 24px;
  margin-left: 20px;
}

.sparkle {
  color: gold;
}

main {
  flex-grow: 1;
  padding: 20px;
  overflow-y: auto;
}

.description {
  font-size: 16px;
  line-height: 1.5;
}

.message-container {
  display: flex;
  flex-direction: column;
}

.message {
  max-width: 80%;
  margin-bottom: 10px;
  padding: 10px;
  border-radius: 10px;
}

.user-message {
  align-self: flex-end;
  background-color: #e6f3ff;
}

.ai-message {
  align-self: flex-start;
  background-color: #f0f0f0;
}

footer {
  padding: 10px;
}

.input-container {
  display: flex;
  align-items: center;
  background-color: #f0f0f0;
  border-radius: 20px;
  padding: 5px;
}

.voice-input, .image-upload, .send-message {
  background: none;
  border: none;
  font-size: 20px;
  cursor: pointer;
  padding: 5px;
}

.text-input {
  flex-grow: 1;
  border: none;
  background: none;
  padding: 10px;
  font-size: 16px;
}

.send-message {
  background-color: #5fb0c9;
  color: white;
  border-radius: 50%;
  width: 40px;
  height: 40px;
  display: flex;
  align-items: center;
  justify-content: center;
}
</style>
