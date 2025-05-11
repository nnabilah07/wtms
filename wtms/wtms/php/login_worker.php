<?php
error_reporting(0); // Disable error reporting for security
header("Access-Control-Allow-Origin: *"); // Allow requests from all origins
header("Access-Control-Allow-Headers: access");
header("Access-Control-Allow-Methods: POST");
header("Content-Type: application/json; charset=UTF-8");

include_once("dbconnect.php");

// Check if POST request is received
if (!isset($_POST)) {
    $response = array('status' => 'failed', 'message' => 'Invalid request');
    sendJsonResponse($response);
    die;
}

// Get POST data
$email = $_POST['email'] ?? '';
$password = $_POST['password'] ?? '';

// Sanitize email to prevent SQL injection
$email = mysqli_real_escape_string($conn, $email);

// Check for required fields
if (empty($email) || empty($password)) {
    $response = array('status' => 'failed', 'message' => 'Missing required fields');
    sendJsonResponse($response);
    exit;
}

// Validate email and password
$sql = "SELECT * FROM workers WHERE email = '$email'";
$result = mysqli_query($conn, $sql);

if ($result->num_rows > 0) {
    $row = $result->fetch_assoc();
    $hashedPassword = $row['password']; // Get the hashed password from the database

    // Compare the provided password with the hashed password
    if (sha1($password) == $hashedPassword) {
        $response = array(
            'status' => 'success',
            'message' => 'Login successful',
            'data' => $row // Return the full worker details
        );
        sendJsonResponse($response);
    } else {
        $response = array('status' => 'failed', 'message' => 'Invalid credentials');
        sendJsonResponse($response);
    }
} else {
    // Update error message for email not found
    $response = array('status' => 'failed', 'message' => 'Email not found');
    sendJsonResponse($response);
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
