<?php
// Set headers first to ensure proper content type
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");
header("Access-Control-Allow-Methods: POST");
header("Access-Control-Max-Age: 3600");
header("Access-Control-Allow-Headers: Content-Type, Access-Control-Allow-Headers, Authorization, X-Requested-With");

// Include database connection
include_once("dbconnect.php");

// Initialize response array
$response = [
    'status' => '',
    'message' => '',
    'data' => []
];

try {
    // Check request method
    if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
        throw new Exception('Method not allowed', 405);
    }

    // Get and validate worker_id
    if (!isset($_POST['worker_id'])) {
        throw new Exception('worker_id is required', 400);
    }

    $worker_id = $_POST['worker_id'];
    
    // Validate worker_id is numeric
    if (!is_numeric($worker_id)) {
        throw new Exception('worker_id must be numeric', 400);
    }

    // Prepare and execute query
    $sql = "SELECT * FROM tbl_works WHERE assigned_to = ?";
    $stmt = $conn->prepare($sql);
    
    if (!$stmt) {
        throw new Exception('Database preparation failed: ' . $conn->error, 500);
    }

    $stmt->bind_param("i", $worker_id);
    
    if (!$stmt->execute()) {
        throw new Exception('Execution failed: ' . $stmt->error, 500);
    }

    $result = $stmt->get_result();
    $tasks = [];

    while ($row = $result->fetch_assoc()) {
        // Ensure consistent data types
        $row['id'] = (string)$row['id']; // Convert ID to string
        $row['assigned_to'] = (string)$row['assigned_to']; // Convert to string
        $tasks[] = $row;
    }

    $response['status'] = 'success';
    $response['data'] = $tasks;

} catch (Exception $e) {
    http_response_code($e->getCode() ?: 500);
    $response['status'] = 'error';
    $response['message'] = $e->getMessage();
} finally {
    // Close statement if it exists
    if (isset($stmt)) {
        $stmt->close();
    }
    
    // Close connection
    $conn->close();
    
    // Output JSON response
    echo json_encode($response);
}
?>