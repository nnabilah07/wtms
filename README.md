# Worker Task Management System (WTMS)

## Information
1. Matric Number: 298612
2. Name: NURUL NABILAH BINTI MOHAMED MAHATHIR

## Description 📝
WTMS is a **Flutter-based mobile application** that allows workers to manage tasks and profiles effectively. The app provides features such as worker registration, login, and profile management. It connects to a backend **PHP server** with a **MySQL database** for data management.

## Features  🔧  
### ✅ Phase 1
- **Worker Registration:** Workers can register by providing full name, email, password, phone number, and address. This data is sent to the backend via an HTTP POST request.
- **Worker Login:** Users can log in using their email and password. On successful login, the app retrieves and displays the worker's full profile.
- **Profile Management:** Workers can view and manage their personal information (name, email, phone, address).
- **Session Persistence:** Login state is maintained using `SharedPreferences`.
- **Secure Password Storage:** Passwords are hashed with SHA1 before storing them in the database.

### 🔁 Phase 2 (Task Completion System)
- **Task List for Workers:**
  - After login, the worker retrieves a list of assigned tasks from `tbl_works`.
  - Tasks display: task ID, title, description, date assigned, due date, and status.
- **Work Completion Upload:**
  - Workers select a task and upload a completion description.
  - Submission is stored in the `tbl_submissions` table via backend API. 

## Screens 📲  

### 1. Registration Screen
- **Fields:** Full Name, Email, Password (hidden), Phone Number, Address  
- **Validation:** All fields required, valid email format, password ≥ 6 characters.

### 2. Login Screen
- **Fields:** Email, Password  
- **Success:** Redirects to Profile and Task List.

### 3. Profile Screen
- **Displays:** Worker ID, Full Name, Email, Phone, Address  
- **Features:** Logout button.

### 4. Task Screen *(Phase 2)*
- **Displays:** List of tasks assigned to the logged-in worker.  
- **Shows:** Title, description, due date, status.

### 5. Submit Completion Screen *(Phase 2)*
- **Fields:** Pre-filled (read-only) task title, a text input: “What did you complete?”, and a submit button.  
- **Function:** Sends the submission to the backend.  

## Tech Stack 🛠️
- **Frontend**: Flutter
- **Backend**: PHP, MySQL
- **State Management**: SharedPreferences for session management.
- **Password Hashing**: SHA1 for secure password storage

## GitHub Link
https://github.com/nnabilah07/wtms.git

## YouTube Presentation 
Phase 1: YouTube Presentation Link: https://youtu.be/lvjNx_6U49M
Phase 2:
