# Food Safety Project

This project is designed to provide information and resources related to food safety. It includes various views that cover different aspects of food safety, including notifications, activities, and store information.

## Project Structure

The project has the following structure:

```
foodsafety-site
├── .gitignore
├── babel.config.js
├── jsconfig.json
├── package.json
├── README.md
├── vue.config.js
├── public
│   └── index.html
└── src
    ├── App.vue
    ├── main.js
    ├── assets
    ├── components
    │   └── HelloWorld.vue
    └── views
        └── food_safety
            ├── AddAddressPage.vue
            ├── FoodSafetyActivityView.vue
            ├── FoodSafetyView.vue
            ├── NightMarketPage.vue
            ├── NotificationPage.vue
            ├── StorePage.vue
            └── Tmp.vue
```

## Views Overview

- **AddAddressPage.vue**: A page for adding new addresses, featuring a form and a submit button.
- **FoodSafetyActivityView.vue**: Displays detailed information about food safety activities, including descriptions and related images.
- **FoodSafetyView.vue**: The main view for food safety, showcasing relevant information and guidelines.
- **NightMarketPage.vue**: Provides information about night markets, including locations and opening hours.
- **NotificationPage.vue**: Displays the latest food safety notifications and alerts.
- **StorePage.vue**: Shows information about stores, including names, addresses, and contact details.
- **Tmp.vue**: A temporary page that may be used for testing or unfinished features.

## Installation

To get started with the project, clone the repository and install the dependencies:

```bash
npm install
```

## Usage

To run the project in development mode, use the following command:

```bash
npm run serve
```

Visit `http://localhost:8080` in your browser to view the application.

## License

This project is licensed under the MIT License.