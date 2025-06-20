<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");
header("Access-Control-Allow-Methods: POST, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type, Access-Control-Allow-Headers, Authorization, X-Requested-With");

// Handle OPTIONS request for CORS preflight
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit();
}

include_once("dbconnect.php");

// Enable error logging
error_reporting(E_ALL);
ini_set('display_errors', 1);

$response = ['status' => '', 'message' => ''];

try {
    if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
        throw new Exception('Method not allowed', 405);
    }

    // Get raw input
    $rawInput = file_get_contents('php://input');
    error_log("Received raw input: " . $rawInput);

    $input = json_decode($rawInput, true);

    if ($input === null && json_last_error() !== JSON_ERROR_NONE) {
        throw new Exception('Invalid JSON: ' . json_last_error_msg(), 400);
    }

    // Verify required fields
    $required_fields = ['worker_id', 'workerFullName', 'workerEmail', 'workerPhone'];
    foreach ($required_fields as $field) {
        if (!isset($input[$field])) {
            throw new Exception("$field is required", 400);
        }
        if (empty($input[$field])) {
            throw new Exception("$field cannot be empty", 400);
        }
    }

    $worker_id = $input['worker_id'];
    $name = $input['workerFullName'];
    $email = $input['workerEmail'];
    $phone = $input['workerPhone'];
    $address = $input['workerAddress'] ?? '';

    // Validate email format
    if (!filter_var($email, FILTER_VALIDATE_EMAIL)) {
        throw new Exception('Invalid email format', 400);
    }

    // ✅ Check if email already exists for another worker
    $checkEmailStmt = $conn->prepare("SELECT id FROM workers WHERE email = ? AND id != ?");
    if (!$checkEmailStmt) {
        error_log("❌ Email check prepare failed: " . $conn->error);
        throw new Exception('Database preparation failed when checking email: ' . $conn->error, 500);
    }

    $checkEmailStmt->bind_param("si", $email, $worker_id);
    $checkEmailStmt->execute();
    $checkResult = $checkEmailStmt->get_result();

    if ($checkResult->num_rows > 0) {
        throw new Exception('Email already in use by another worker', 400);
    }

    // ✅ Proceed to update
    $sql = "UPDATE workers SET full_name = ?, email = ?, phone = ?, address = ? WHERE id = ?";
    error_log("Preparing SQL: " . $sql);

    $stmt = $conn->prepare($sql);
    if (!$stmt) {
        error_log("❌ Update prepare failed: " . $conn->error);
        throw new Exception('Database preparation failed during update: ' . $conn->error, 500);
    }

    $stmt->bind_param("ssssi", $name, $email, $phone, $address, $worker_id);

    if (!$stmt->execute()) {
        throw new Exception('Execution failed: ' . $stmt->error, 500);
    }

    $response['status'] = 'success';
    $response['message'] = 'Profile updated successfully';

} catch (Exception $e) {
    $response['status'] = 'error';
    $response['message'] = $e->getMessage() . ' (Code: ' . $e->getCode() . ')';
    error_log("❌ Error: " . $e->getMessage());
    echo json_encode($response); // Output immediately
    exit();
} finally {
    if (isset($stmt)) $stmt->close();
    if (isset($checkEmailStmt)) $checkEmailStmt->close();
    $conn->close();
    echo json_encode($response);
    error_log("✅ Response: " . json_encode($response));
}
?>
