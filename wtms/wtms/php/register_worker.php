<?php
error_reporting(0); // Disable error reporting for security
header("Access-Control-Allow-Origin: *"); // Allow requests from all origins
header("Access-Control-Allow-Headers: access");
header("Access-Control-Allow-Methods: POST");
header("Content-Type: application/json; charset=UTF-8");

include_once("dbconnect.php");

// Check if POST request is received
if (!isset($_POST)) {
    $response = array('status' => 'failed', 'data' => null);
    sendJsonResponse($response);
    die;
}

// Get POST data
$name = $_POST['name'] ?? '';
$email = $_POST['email'] ?? '';
$password = $_POST['password'] ?? '';
$phone = $_POST['phone'] ?? '';
$address = $_POST['address'] ?? '';

// Sanitize inputs to prevent SQL injection
$name = mysqli_real_escape_string($conn, $name);
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

// Check if email already exists in the workers table
$sqlcheck = "SELECT * FROM workers WHERE email = '$email'";
$result = mysqli_query($conn, $sqlcheck);
if (mysqli_num_rows($result) > 0) {
    $response = array('status' => 'failed', 'message' => 'Email already registered');
    sendJsonResponse($response);
    exit;
}

// Insert new worker into 'workers' table
$sqlinsert = "INSERT INTO workers (full_name, email, password, phone, address) 
              VALUES ('$name', '$email', '$hashedPassword', '$phone', '$address')";

try {
    if ($conn->query($sqlinsert) === TRUE) {
        $response = array('status' => 'success', 'data' => null);
        sendJsonResponse($response);
    } else {
        $response = array('status' => 'failed', 'data' => null);
        sendJsonResponse($response);
    }
} catch (Exception $e) {
    $response = array('status' => 'failed', 'data' => null);
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
