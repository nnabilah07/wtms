<?php
header('Content-Type: application/json');
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST, GET, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type");

// Handle preflight OPTIONS request
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit();
}

error_reporting(E_ALL);
ini_set('display_errors', 1);

require_once 'dbconnect.php';

$response = ['status' => 'error', 'message' => ''];

try {
    $rawInput = file_get_contents('php://input');
    file_put_contents('debug.log', "RAW JSON INPUT: $rawInput\n", FILE_APPEND);
    file_put_contents('debug.log', "REQUEST METHOD: {$_SERVER['REQUEST_METHOD']}\n", FILE_APPEND);

    if (!$rawInput) {
        throw new Exception("No JSON input received", 400);
    }

    $input = json_decode($rawInput, true);

    if (json_last_error() !== JSON_ERROR_NONE) {
        throw new Exception("Invalid JSON input: " . json_last_error_msg(), 400);
    }

    $required = ['work_id', 'worker_id', 'submission_text'];
    foreach ($required as $field) {
        if (empty($input[$field])) {
            throw new Exception("Missing required field: $field", 400);
        }
    }

    $stmt = $conn->prepare("INSERT INTO tbl_submissions (work_id, worker_id, submission_text) VALUES (?, ?, ?)");
    if (!$stmt) {
        throw new Exception('Database preparation failed: ' . $conn->error, 500);
    }

    $stmt->bind_param("iis", $input['work_id'], $input['worker_id'], $input['submission_text']);
    $success = $stmt->execute();

    if ($success) {
        $updateStmt = $conn->prepare("UPDATE tbl_works SET status = 'completed' WHERE id = ?");
        $updateStmt->bind_param("i", $input['work_id']);
        $updateStmt->execute();
        $updateStmt->close();

        $response = [
            'status' => 'success',
            'message' => 'Work submitted successfully',
            'submission_id' => $stmt->insert_id
        ];
    } else {
        throw new Exception('Failed to submit work: ' . $stmt->error, 500);
    }

} catch (Exception $e) {
    http_response_code($e->getCode() ?: 500);
    $response['message'] = $e->getMessage();
} finally {
    if (isset($stmt)) $stmt->close();
    $conn->close();
    file_put_contents('response.log', print_r($response, true), FILE_APPEND);
    echo json_encode($response);
}
?>
