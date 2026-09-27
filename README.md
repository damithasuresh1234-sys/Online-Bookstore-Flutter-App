# Online Bookstore Mobile Application

## 1. Project Overview

The Online Bookstore is a full-stack mobile application developed using Flutter and Dart for the mobile frontend, PHP REST API for the backend, and MySQL for database storage.

The system supports three user roles:

- Customer
- Staff Member
- Administrator

Customers can browse books, search and filter books, manage their shopping cart, place orders and view order history.

Staff members can manage books and customer orders.

Administrators can manage users, books and orders.

---

## 2. Technologies Used

### Frontend

- Flutter
- Dart
- Provider
- SharedPreferences

### Backend

- PHP
- REST API
- JSON
- HTTP
- JWT Authentication
- PDO

### Database

- MySQL

### Development Tools

- Android Studio
- XAMPP
- Android Emulator

---

## 3. System Architecture

The application follows a client-server architecture:

Flutter Mobile Application
        |
        | HTTP / JSON
        |
        v
PHP REST API
        |
        | PDO / SQL
        |
        v
MySQL Database

---

## 4. User Roles

### Customer

Customers can:

- Register an account
- Login
- Browse books
- Search books by title or author
- Filter books by category
- View book details
- Add books to the shopping cart
- Increase or decrease quantities
- Remove cart items
- View cart total
- Enter a shipping address
- Place an order
- View order history
- View profile
- Logout

### Staff Member

Staff members can:

- Login
- Access the Staff Dashboard
- Manage books
- Add and edit book information
- View customer orders
- Update order status
- Logout

### Administrator

Administrators can:

- Login
- Access the Administrator Dashboard
- Manage users
- Update user roles
- Manage books
- Add books
- Edit books
- Delete books
- Manage customer orders
- Update order status
- Logout

---

## 5. Demo Login Accounts

### Administrator

Email:
admin@bookstore.com

Password:
Password123

Role:
ADMIN

### Staff Member

Email:
staff@bookstore.com

Password:
Password123

Role:
STAFF

### Customer

Email:
customer@bookstore.com

Password:
Password123

Role:
CUSTOMER

---

## 6. Database

Database name:

bookstore_db

The database contains the following main tables:

- users
- books
- cart_items
- orders
- order_items

The SQL database export is provided in:

database/bookstore_database.sql

---

## 7. Database Setup

1. Install XAMPP.
2. Start Apache and MySQL from the XAMPP Control Panel.
3. Open phpMyAdmin:

   http://localhost/phpmyadmin

4. Create a database named:

   bookstore_db

5. Select the bookstore_db database.
6. Select Import.
7. Select:

   database/bookstore_database.sql

8. Click Import.

The SQL file contains the database structure and sample data required by the application.

---

## 8. Backend Setup

The backend PHP REST API is located in:

backend/

Copy the contents of the backend folder into the XAMPP htdocs directory and rename the folder:

bookstore_api

The final backend location should be:

C:\xampp\htdocs\bookstore_api

The API should therefore be accessible at:

http://localhost/bookstore_api

---

## 9. Database Configuration

The database connection is configured in:

backend/config/database.php

Default configuration:

Host:
127.0.0.1

Database:
bookstore_db

Username:
root

Password:
empty

These settings are suitable for the default XAMPP MySQL configuration.

If the local MySQL configuration is different, update database.php accordingly.

---

## 10. Flutter Application Setup

1. Install Flutter.
2. Install Android Studio.
3. Open the following folder in Android Studio:

   flutter_app/

4. Open the terminal inside the Flutter project.
5. Run:

   flutter pub get

6. Start an Android Emulator.
7. Run the application using:

   flutter run

---

## 11. Android Emulator API Configuration

The Flutter application is configured to communicate with the local XAMPP backend using:

http://10.0.2.2/bookstore_api

10.0.2.2 is used by the Android Emulator to access the host computer's localhost.

The PHP backend must therefore be running through XAMPP before using the application.

---

## 12. Physical Android Device

If testing on a physical Android device connected to the same Wi-Fi network as the development computer, replace:

10.0.2.2

with the local IP address of the computer.

For example:

http://192.168.x.x/bookstore_api

The computer and Android device must be connected to the same network.

---

## 13. Authentication

The application uses JWT-based authentication.

After successful login, the authentication token is stored locally and sent with protected API requests.

Protected operations require authentication and appropriate user roles.

---

## 14. Security

The application includes:

- Password hashing
- JWT authentication
- Role-based authorization
- Backend validation
- Protected API operations
- PDO database access
- Error handling

The backend verifies user roles before performing protected operations.

---

## 15. Important Project Notes

This project is developed for academic assessment and local demonstration.

The current application does not include an external online payment gateway.

Book images use image URLs rather than a dedicated image upload service.

For local operation, Apache and MySQL must be running through XAMPP.

---

## 16. Project Structure

OnlineBookstore_Submission/

    README.md

    database/
        bookstore_database.sql

    backend/
        api/
        config/
        database/
        helpers/

    flutter_app/
        android/
        assets/
        ios/
        lib/
        linux/
        macos/
        test/
        web/
        windows/
        pubspec.yaml
        pubspec.lock

---

## 17. Main Flutter Application Components

The Flutter application contains:

### Models

- Book
- CartItem
- Order
- User

### Providers

- AuthProvider
- CartProvider

### Services

- ApiService

### Customer Screens

- Customer Home
- Browse Books
- Book Details
- Cart
- Checkout
- Orders
- Profile

### Staff Screens

- Staff Dashboard
- Manage Books
- Book Form
- Manage Orders

### Administrator Screens

- Admin Dashboard
- Manage Users

---

## 18. Running the Complete System

The recommended startup sequence is:

1. Start XAMPP.
2. Start Apache.
3. Start MySQL.
4. Confirm bookstore_db exists in phpMyAdmin.
5. Confirm the backend is located at:

   C:\xampp\htdocs\bookstore_api

6. Start an Android Emulator.
7. Open the Flutter project in Android Studio.
8. Run:

   flutter pub get

9. Run:

   flutter run

10. Login using one of the demo accounts.

---

## 19. Troubleshooting

### API connection error

Check that:

- Apache is running.
- MySQL is running.
- The backend is inside:

  C:\xampp\htdocs\bookstore_api

- The Android Emulator is running.
- The Flutter API URL is:

  http://10.0.2.2/bookstore_api

### Database connection error

Check that:

- MySQL is running.
- Database name is bookstore_db.
- Database credentials in database.php are correct.
- bookstore_database.sql has been imported.

### Flutter dependency error

Run:

flutter pub get

Then run:

flutter clean

and:

flutter pub get

again if necessary.

---

## 20. Academic Project

This application was developed as a university assessment demonstrating mobile application development, REST API integration, database management, authentication, role-based access control, user interface design and software testing.
"# Online-Bookstore-Flutter-App" 
