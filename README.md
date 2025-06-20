# Worker Task Management System (WTMS)


## Information
1. Matric Number: 298612
2. Name: NURUL NABILAH BINTI MOHAMED MAHATHIR


## Description 📝
WTMS is a Flutter-based mobile application designed to streamline how workers manage their tasks and personal information. It features secure user authentication, task tracking, submission management, and profile control. WTMS communicates with a backend PHP server connected to a MySQL database.


## Features  🔧  
### ✅ Phase 1
- **Worker Registration:** Workers can register by providing full name, email, password, phone number, and address. This data is sent to the backend via an HTTP POST request.
- **Worker Login:** Users can log in using their email and password. On successful login, the app retrieves and displays the worker's full profile.
- **Profile Management:** Workers can view their personal information (name, email, phone, address).
- **Session Persistence:** Login state is maintained using `SharedPreferences`.
- **Secure Password Storage:** Passwords are hashed with SHA1 before storing them in the database.

### 🔁 Phase 2 (Task Completion System)
- **Task List for Workers:**
  - After login, the worker retrieves a list of assigned tasks from `tbl_works`.
  - Tasks display: task ID, title, description, date assigned, due date, and status.
- **Work Completion Upload:**
  - Workers select a task and upload a completion description.
  - Submission is stored in the `tbl_submissions` table via backend API. 

### 🚀 Final Phase: Enhanced Functionality
- **📂 Submission History:**
  - Displays a list of all past submissions by the logged-in worker.
  - Shows task title, submission date, and a short preview of the submission text.
  - Optionally allows expanding to view the full submission.

-**✏️ Edit Submission**
  - Workers can tap on a submission from the history list to edit it.
  - The updated text will overwrite the existing entry in `tbl_submissions`.
  - A confirmation prompt is shown before saving.

-**🧑 Profile Update**
  - Displays the worker's current info (name, email, phone, etc.).
  - Allows editing and updating the information, except for the username.
  - Changes are saved to `tbl_users`.

-**🧭 Improved Navigation**
  - Enhanced navigation using `TabBar`, `BottomNavigationBar`, and a sidebar drawer.
  - Includes:
    - **Tasks:** Task list and submission screen
    - **History:** View and edit past submissions
    - **Profile:** View and update profile details

---


## Screens 📲  

### 1. Register Screen
- **Fields:** Full Name, Username, Email, Password (hidden), Phone Number, Address  
- **Validation:** All fields required, valid email format, password ≥ 6 characters.

### 2. Login Screen
- **Fields:** Email, Password  
- **Success:** Redirects to Profile and Task List.

### 3. Profile Screen
- **Displays:** Username *(final phase)*, Full Name, Email, Phone Number, Address  
- **Features:** Logout button, Edit Profile option

### 4. Task Screen
- **Displays:** Assigned tasks with title, description, due date, and status  
- **Tap to Submit:** Leads to submission screen

### 5. Submit Completion Screen
- **Fields:** Read-only task title, text input for completion description, submit button  
- **Function:** Sends submission to backend

### 6. Submission History Screen
- **Displays:** List of submissions  
- **Tappable:** To open and edit previous submission

---

## Tech Stack 🛠️

| Layer       | Technology             |
|-------------|------------------------|
| Frontend    | Flutter                |
| Backend     | PHP                    |
| Database    | MySQL                  |
| State Mgmt  | SharedPreferences      |
| Auth        | Custom (Email/Password)|
| Security    | SHA1 Password Hashing  |

---

## 📡 Backend API (PHP)

| API Endpoint           | Description |
|------------------------|-------------|
| `get_submissions.php`  | Input: `worker_id` → Returns list of submissions joined with task title |
| `edit_submission.php`  | Input: `submission_id`, `updated_text` → Updates submission in `tbl_submissions` |
| `get_profile.php`      | Input: `worker_id` → Returns worker profile info |
| `update_profile.php`   | Input: `worker_id`, `name`, `email`, `phone`, etc. → Updates profile info in `workers` |

## GitHub Link
https://github.com/nnabilah07/wtms.git


## YouTube Presentation 
Phase 1: https://youtu.be/lvjNx_6U49M

Phase 2: https://youtu.be/P3VvzYD8zk0 

Phase 3: https://youtu.be/XCXu88vh3ZM
