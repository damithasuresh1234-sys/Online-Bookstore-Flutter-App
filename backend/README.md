# Bookstore REST API (PHP + MySQL)

A plain PHP (no framework, no Composer required) REST API for the Online
Bookstore Flutter app. Designed to run on **XAMPP**.

## 1. Setup (XAMPP)

1. Copy the whole `backend` folder into your XAMPP `htdocs` directory and
   rename it to `bookstore_api`, e.g.:
   `C:\xampp\htdocs\bookstore_api\` (Windows) or `/Applications/XAMPP/htdocs/bookstore_api/` (Mac).
2. Start **Apache** and **MySQL** from the XAMPP Control Panel.
3. Open `http://localhost/phpmyadmin`, create nothing manually — instead:
   - Click **Import**, choose `database/schema.sql`, and run it.
     This creates the `bookstore_db` database, all tables, and demo data.
4. In your browser, visit:
   `http://localhost/bookstore_api/database/seed_passwords.php`
   This sets a real password for the 3 demo accounts (see below). Run it once.
5. Test the API is alive:
   `http://localhost/bookstore_api/api/books/list.php`
   You should see a JSON list of 6 seeded books.

If your MySQL root user has a password, edit `config/database.php` and set it.

## 2. Demo accounts (after running seed_passwords.php)

| Role          | Email                   | Password    |
|---------------|-------------------------|-------------|
| Administrator | admin@bookstore.com     | Password123 |
| Store Staff   | staff@bookstore.com     | Password123 |
| Customer      | customer@bookstore.com  | Password123 |

## 3. API Endpoints

### Auth (public)
| Method | Endpoint                     | Description          |
|--------|-------------------------------|-----------------------|
| POST   | /api/auth/register.php        | Register a new customer |
| POST   | /api/auth/login.php           | Login, returns JWT token |

### Books
| Method | Endpoint                    | Access          | Description |
|--------|------------------------------|-----------------|--------------|
| GET    | /api/books/list.php?search=&category= | Public | List/search books |
| GET    | /api/books/get.php?id=1     | Public          | Book details |
| POST   | /api/books/create.php       | Staff, Admin    | Add a book |
| POST   | /api/books/update.php       | Staff, Admin    | Edit a book |
| POST   | /api/books/delete.php       | Admin only      | Delete a book |

### Cart (Customer only)
| Method | Endpoint                | Description |
|--------|--------------------------|--------------|
| GET    | /api/cart/get.php        | View own cart |
| POST   | /api/cart/add.php        | Add book to cart |
| POST   | /api/cart/update.php     | Change quantity |
| POST   | /api/cart/remove.php     | Remove item |

### Orders
| Method | Endpoint                      | Access             | Description |
|--------|--------------------------------|--------------------|--------------|
| POST   | /api/orders/place.php          | Customer           | Checkout cart into an order |
| GET    | /api/orders/list.php           | All (scoped)        | Customer: own orders. Staff/Admin: all orders |
| POST   | /api/orders/update_status.php  | Staff, Admin        | Progress order status |

### Users (Admin only)
| Method | Endpoint                   | Description |
|--------|------------------------------|--------------|
| GET    | /api/users/list.php          | List all users |
| POST   | /api/users/update_role.php   | Change a user's role |

## 4. Authentication

All protected endpoints require a header:
```
Authorization: Bearer <token>
```
The token is returned by `login.php` / `register.php` and is a JWT (HS256)
signed server-side (see `helpers/JWT.php`). It encodes the user id, email,
name and role, and expires after 24 hours.

## 5. Notes for the report

- **Validation**: every endpoint validates required fields, types (numeric),
  min values, and enum membership server-side via `helpers/Validator.php`,
  in addition to Flutter's client-side form validation. This gives two
  layers of data-integrity checking as required by the brief.
- **Role-based access control**: `helpers/Auth.php` decodes the JWT and
  the `requireRole()` method rejects requests (HTTP 403) from users whose
  role isn't in the allowed list, e.g. only Admin can delete books or
  change user roles.
- **Data integrity**: placing an order runs inside a single SQL transaction
  (`api/orders/place.php`) — either every order_item row and stock
  decrement succeeds, or the whole operation rolls back.
