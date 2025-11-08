/**
 * Two-Way Connection工具函數
 * 用於與Flutter App進行通信
 */

// 存儲pending的請求，key為請求ID，value為Promise的resolve和reject函數
const pendingRequests = new Map();
let requestIdCounter = 0;

/**
 * 初始化Flutter Bridge
 * 設置消息監聽器來接收App的回復
 */
export function initFlutterBridge() {
  // 檢查是否在App環境中
  if (typeof window === 'undefined' || typeof window.flutterObject === 'undefined') {
    console.warn('Flutter bridge not available - running outside of app');
    return false;
  }

  if (window.addEventListener && !window._flutterBridgeInitialized) {
    window.addEventListener('message', handleFlutterMessage, false);
    window._flutterBridgeInitialized = true;
  }

  // 方法2: 如果flutterObject支持onmessage，也設置它
  // 注意：這取決於flutter_inappwebview的實際實現
  try {
    if (window.flutterObject && typeof window.flutterObject.onmessage === 'undefined') {
      // 某些版本的flutter_inappwebview可能會通過這種方式返回回復
      // 我們暫時不設置，因為可能會干擾其他功能
    }
  } catch (e) {
    // 忽略錯誤
  }

  return true;
}

/**
 * 處理來自Flutter App的消息回復
 * 根據flutter_inappwebview的實現，回復會通過WebMessageListener的replyProxy返回
 * 我們需要使用一個全局的回調機制來接收回復
 */
function handleFlutterMessage(event) {
  try {
    // 檢查消息是否來自Flutter
    if (!event.data) {
      return;
    }

    let response;
    if (typeof event.data === 'string') {
      try {
        response = JSON.parse(event.data);
      } catch (e) {
        // 如果不是JSON，可能是直接的消息
        return;
      }
    } else if (typeof event.data === 'object') {
      response = event.data;
    } else {
      return;
    }

    // 檢查是否是Flutter的回復（包含name和data字段）
    if (response && response.name && typeof response.name === 'string') {
      // 查找對應的pending request（找到最舊的匹配請求）
      let matchedRequest = null;
      let oldestTimestamp = Infinity;
      
      for (const [requestId, requestData] of pendingRequests.entries()) {
        if (requestData.methodName === response.name && requestData.timestamp < oldestTimestamp) {
          oldestTimestamp = requestData.timestamp;
          matchedRequest = { requestId, requestData };
        }
      }

      if (matchedRequest) {
        const { requestId, requestData } = matchedRequest;
        // 清除超時
        if (requestData.timeout) {
          clearTimeout(requestData.timeout);
        }
        // 移除pending request
        pendingRequests.delete(requestId);
        // 解析Promise
        requestData.resolve(response.data);
      }
    }
  } catch (error) {
    console.error('Error handling flutter message:', error);
  }
}

// 注意：根據flutter_inappwebview的實現，回復可能通過不同的方式返回
// 我們在initFlutterBridge中設置監聽器，這裡只是確保在模塊加載時就有監聽器

/**
 * 調用Flutter App方法
 * 根據flutter_inappwebview的WebMessageListener機制，回復會通過replyProxy返回
 * 我們需要設置一個機制來接收回復
 * @param {string} methodName - 方法名稱 (如 'location', 'userinfo')
 * @param {any} data - 要傳遞的數據
 * @returns {Promise} 返回App的回復數據
 */
export function callFlutterMethod(methodName, data = null) {
  return new Promise((resolve, reject) => {
    // 檢查是否在App環境中
    if (typeof window === 'undefined' || typeof window.flutterObject === 'undefined') {
      reject(new Error('Flutter bridge not available - not running in app environment'));
      return;
    }

    try {
      // 創建請求對象
      const request = {
        name: methodName,
        data: data
      };

      // 為每個請求創建一個唯一標識
      const requestId = `${methodName}_${Date.now()}_${requestIdCounter++}`;
      
      // 存儲resolve和reject函數
      const timeout = setTimeout(() => {
        if (pendingRequests.has(requestId)) {
          pendingRequests.delete(requestId);
          reject(new Error(`Flutter method ${methodName} timed out after 10 seconds`));
        }
      }, 10000); // 10秒超時

      pendingRequests.set(requestId, {
        resolve: (responseData) => {
          clearTimeout(timeout);
          resolve(responseData);
        },
        reject: (error) => {
          clearTimeout(timeout);
          reject(error);
        },
        methodName,
        timestamp: Date.now(),
        timeout
      });

      // 發送消息給Flutter App
      // 根據flutter_inappwebview的文檔，postMessage需要傳遞字符串
      // Flutter的WebMessageListener會通過replyProxy.postMessage()回復
      // 回復應該能夠通過某種機制返回到這裡
      window.flutterObject.postMessage(JSON.stringify(request));

      // 注意：根據flutter_inappwebview的實現，回復可能會通過以下方式之一返回：
      // 1. 通過window.message事件
      // 2. 通過postMessage的返回值（如果支持）
      // 3. 通過一個回調機制
      // 我們已經在initFlutterBridge中設置了message事件監聽器

    } catch (error) {
      // 如果發送消息失敗，立即reject
      reject(error);
    }
  });
}

/**
 * 獲取用戶信息
 * @returns {Promise<Object>} 用戶信息對象
 */
export async function getUserInfo() {
  try {
    const userInfo = await callFlutterMethod('userinfo', null);
    return userInfo;
  } catch (error) {
    console.error('Error getting user info:', error);
    return null;
  }
}

/**
 * 獲取當前位置
 * @returns {Promise<Object>} 位置信息對象 (包含latitude, longitude等)
 */
export async function getCurrentLocation() {
  try {
    const location = await callFlutterMethod('location', null);
    return location;
  } catch (error) {
    console.error('Error getting location:', error);
    return null;
  }
}

/**
 * 將經緯度轉換為地址
 * 使用Google Maps Geocoding API (需要API key)
 * 或者可以使用其他reverse geocoding服務
 * @param {number} lat - 緯度
 * @param {number} lng - 經度
 * @returns {Promise<string>} 地址字符串
 */
export async function reverseGeocode(lat, lng) {
  try {
    // 這裡可以使用Google Maps Geocoding API或其他服務
    // 由於需要API key，我們先使用一個簡單的實現
    // 實際應用中應該使用真實的geocoding服務
    
    // 方法1: 使用Google Maps Geocoding API (需要API key)
    // const apiKey = 'YOUR_GOOGLE_MAPS_API_KEY';
    // const response = await fetch(
    //   `https://maps.googleapis.com/maps/api/geocode/json?latlng=${lat},${lng}&key=${apiKey}&language=zh-TW`
    // );
    // const data = await response.json();
    // if (data.results && data.results.length > 0) {
    //   return data.results[0].formatted_address;
    // }

    // 方法2: 使用Nominatim (OpenStreetMap) - 免費但有限制
    const response = await fetch(
      `https://nominatim.openstreetmap.org/reverse?format=json&lat=${lat}&lon=${lng}&zoom=18&addressdetails=1&accept-language=zh-TW,zh,en`,
      {
        headers: {
          'User-Agent': 'TownPass-FoodSafety/1.0'
        }
      }
    );
    
    if (!response.ok) {
      throw new Error('Geocoding API request failed');
    }

    const data = await response.json();
    if (data && data.address) {
      // 構建台灣地址格式
      const addr = data.address;
      let addressParts = [];
      
      // 台灣地址順序: 城市 -> 區 -> 里 -> 路/街 -> 號
      if (addr.city || addr.town || addr.city_district) {
        addressParts.push(addr.city || addr.town || addr.city_district || '');
      }
      if (addr.suburb || addr.district || addr.township) {
        addressParts.push(addr.suburb || addr.district || addr.township || '');
      }
      if (addr.road || addr.street) {
        addressParts.push(addr.road || addr.street || '');
      }
      if (addr.house_number) {
        addressParts.push(addr.house_number);
      }

      const address = addressParts.filter(Boolean).join('');
      return address || data.display_name || `${lat}, ${lng}`;
    }

    return data.display_name || `${lat}, ${lng}`;
  } catch (error) {
    console.error('Error reverse geocoding:', error);
    // 如果geocoding失敗，返回經緯度作為fallback
    return `${lat}, ${lng}`;
  }
}

/**
 * 獲取當前位置並轉換為地址
 * @returns {Promise<string>} 地址字符串
 */
export async function getCurrentLocationAddress() {
  try {
    const location = await getCurrentLocation();
    if (!location || !location.latitude || !location.longitude) {
      return null;
    }

    const address = await reverseGeocode(location.latitude, location.longitude);
    return address;
  } catch (error) {
    console.error('Error getting current location address:', error);
    return null;
  }
}

