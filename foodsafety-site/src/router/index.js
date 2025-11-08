import { createRouter, createWebHistory } from "vue-router";
import FoodSafetyWebView from "@/views/FoodSafetyWebView.vue";
import FoodSafetyActivityView from "@/views/FoodSafetyActivityView.vue";
import AddAddressPage from "@/views/AddAddressPage.vue";
import StorePage from "@/views/StorePage.vue";
import NotificationPage from "@/views/NotificationPage.vue";
import NightMarketPage from "@/views/NightMarketPage.vue";
import ReceiptPage from "@/views/ReceiptPage.vue";

const routes = [
  { path: "/", component: FoodSafetyWebView },
  { path: "/activities", component: FoodSafetyActivityView },
  { path: "/add-address", component: AddAddressPage },
  { path: "/store", component: StorePage },
  { path: "/notification", component: NotificationPage },
  { path: "/night-market", component: NightMarketPage },
  { path: "/receipt", component: ReceiptPage },
];

const router = createRouter({
  history: createWebHistory(),
  routes,
});

export default router;
