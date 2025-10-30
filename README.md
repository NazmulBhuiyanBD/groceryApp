# 🛒 Grocery App  

A modern **Flutter grocery shopping app** integrated with **Firebase**.  
Users can browse groceries, manage their carts, place orders, update profiles, and sign in using **Google** or **Email + Password**.

---

## 🚀 Features  

### 🔐 Authentication  
- Login & Register using **Email + Password**  
- **Google Sign-In** integration  
- Firebase Auth + Firestore profile sync  

### 🏠 Home  
- Browse grocery products by categories  
- View recent and top-selling items  
- Add items to cart or mark as favorite  

### ❤️ Favorites  
- Save favorite items for quick access  

### 🛒 Cart & Checkout  
- Add multiple products to cart  
- Auto-calculates total + delivery charge  
- Fetches delivery address from user profile  
- Checkout creates order in Firestore  

### 👤 Profile Management  
- Update **photo**, **name**, **phone**, and **address**  
- View **previous orders**  
- Logout anytime  

### ☁️ Firebase Integration  
- Firebase Authentication  
- Firestore Database  
- Firebase Storage for user photos  


## 📱 Screenshots  

| Login | Register | Profile | Favorites |
|:-----:|:--------:|:-------:|:---------:|
| ![Login](screenshot/login.png) | ![Register](screenshot/register.png) | ![Profile](screenshot/profile.png) | ![Favorites](screenshot/favouritesScreen.png) |

| Cart | Product Details | Search Products | Home |
|:----:|:---------------:|:---------------:|:----:|
| ![Cart](screenshot/cart.png) | ![Product Details](screenshot/productDetails.png) | ![Search Products](screenshot/searchAllProduct.png) | ![Home](screenshot/homeScreen.png) |




---

## Tech 

| Technology | Description |
|-------------|-------------|
| **Flutter** | Cross-platform mobile framework |
| **Firebase Auth** | Handles authentication |
| **Cloud Firestore** | Real-time database |
| **Firebase Storage** | Profile photo uploads |
| **Provider** | State management |
| **Google Sign-In** | OAuth login |

---

## ⚙️ Setup Instructions  

### Clone the Repository  
git clone https://github.com/NazmulBhuiyanBD/groceryApp.git
cd grocery_app

### Install Dependencies
flutter pub get

### Run the App
flutter run

