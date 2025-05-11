# Worker Task Management System (WTMS)

## INFORMATION
1. Matric Number: 298612
2. Name: NURUL NABILAH BINTI MOHAMED MAHATHIR
   
## Description
WTMS is a Flutter-based mobile application that allows workers to manage tasks and profiles effectively. The app provides features such as worker registration, login, and profile management. It connects to a backend PHP server with a MySQL database for data management.

## Features
**Worker Registration**: Workers can register by providing full name, email, password, phone number, and address. This data is sent to the backend via an HTTP POST request.

**Worker Login**: Users can log in using their email and password. On successful login, the app retrieves and displays the worker's full profile.

**Profile Management**: After logging in, users can view and manage their profile, which includes personal information like name, email, phone number, and address.

**Session Persistence**: SharedPreferences is used to maintain the user’s login state, so the worker stays logged in until they log out.

**Secure Password Storage**: Passwords are securely hashed using SHA1 before storing them in the database.

## Screens
**1. Registration Screen**:
      -Fields: Full Name, Email, Password (hidden), Phone Number, Address
      -Validation: All fields are required, email format is validated, and password must be at least 6 characters.

**2. Login Screen**:
      -Fields: Email, Password
      -On successful login, worker data is passed and displayed on the Profile Screen.

**3. Profile Screen**:
      -Displays: Worker ID, Full Name, Email, Phone Number, Address
      -Includes a logout button.

## Tech Stack
- **Frontend**: Flutter
- **Backend**: PHP, MySQL
- **State Management**: SharedPreferences for session management.
- **Password Hashing**: SHA1 for secure password storage

## GitHub Link
   git clone https://github.com/nnabilah07/wtms.git

## YouTube Presentation Link
