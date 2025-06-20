<?php
error_reporting(0); // Disable error reporting for security
header("Access-Control-Allow-Origin: *"); // Allow requests from all origins
header("Access-Control-Allow-Headers: *");
header("Access-Control-Allow-Methods: GET, POST, OPTIONS");
header("Content-Type: application/json; charset=UTF-8");

error_reporting(E_ALL);
ini_set('display_errors', 1);

include_once("dbconnect.php");

// Check if POST request is received
if ($_SERVER['REQUEST_METHOD'] != 'POST') {
    $response = array('status' => 'failed', 'message' => 'Invalid request method');
    sendJsonResponse($response);
    die;
}

// Get POST data
$name = $_POST['name'] ?? '';
$username = $_POST['username'] ?? '';
$email = $_POST['email'] ?? '';
$password = $_POST['password'] ?? '';
$phone = $_POST['phone'] ?? '';
$address = $_POST['address'] ?? '';

// Sanitize inputs to prevent SQL injection
$name = mysqli_real_escape_string($conn, $name);
$username = mysqli_real_escape_string($conn, $username);
$email = mysqli_real_escape_string($conn, $email);
$phone = mysqli_real_escape_string($conn, $phone);
$address = mysqli_real_escape_string($conn, $address);

// Hash the password using sha1
$hashedPassword = sha1($password);

// Check for required fields
if (empty($name) || empty($email) || empty($password)) {
    $response = array('status' => 'failed', 'message' => 'Missing required fields');
    sendJsonResponse($response);
    exit;
}

if (strlen($username) < 4) {
    sendJsonResponse(['status' => 'failed', 'message' => 'Username must be at least 4 characters']);
    exit;
}

// Check for existing username
$sqlcheckUsername = "SELECT id FROM workers WHERE username = '$username'";
$resUsername = mysqli_query($conn, $sqlcheckUsername);
if (mysqli_num_rows($resUsername) > 0) {
    sendJsonResponse(['status' => 'failed', 'message' => 'Username already exists']);
    exit;
}

// Check if email already exists in the workers table
$sqlcheck = "SELECT * FROM workers WHERE email = '$email'";
$result = mysqli_query($conn, $sqlcheck);
if (mysqli_num_rows($result) > 0) {
    $response = array('status' => 'failed', 'message' => 'Email already registered');
    sendJsonResponse($response);
    exit;
}

// Insert new worker into 'workers' table
$sqlinsert = "INSERT INTO workers (full_name, username, email, password, phone, address)
              VALUES ('$name', '$username', '$email', '$hashedPassword', '$phone', '$address')";

try {
    if ($conn->query($sqlinsert) === TRUE) {
        $response = array('status' => 'success', 'message' => 'Worker registered successfully');
        sendJsonResponse($response);
    } else {
        $response = array('status' => 'failed', 'message' => 'Error registering worker');
        sendJsonResponse($response);
    }
} catch (Exception $e) {
    $response = array('status' => 'failed', 'message' => 'Exception occurred: ' . $e->getMessage());
    sendJsonResponse($response);
    die;
}

// Close the database connection
$conn->close();

// Function to send a JSON response
function sendJsonResponse($sentArray)
{
    header('Content-Type: application/json');
    echo json_encode($sentArray);
}

?>
