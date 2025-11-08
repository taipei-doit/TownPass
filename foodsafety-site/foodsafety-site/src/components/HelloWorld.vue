<template>
  <div class="hello">
    <h1>Welcome to the Food Safety Project</h1>
    <p>This project aims to provide information and resources related to food safety.</p>
    <router-link to="/food_safety/FoodSafetyView">Go to Food Safety View</router-link>
    <router-link to="/food_safety/AddAddressPage">Add Address</router-link>
    <router-link to="/food_safety/FoodSafetyActivityView">Food Safety Activities</router-link>
    <router-link to="/food_safety/NightMarketPage">Night Market Information</router-link>
    <router-link to="/food_safety/NotificationPage">Notifications</router-link>
    <router-link to="/food_safety/StorePage">Store Information</router-link>
    <router-link to="/food_safety/Tmp">Temporary Page</router-link>
  </div>
</template>

<script>
export default {
  name: 'HelloWorld'
}
</script>

<style scoped>
.hello {
  text-align: center;
  margin-top: 20px;
}
</style>