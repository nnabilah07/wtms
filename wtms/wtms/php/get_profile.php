<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");
header("Access-Control-Allow-Methods: POST");
header("Access-Control-Max-Age: 3600");
header("Access-Control-Allow-Headers: Content-Type, Access-Control-Allow-Headers, Authorization, X-Requested-With");

include_once("dbconnect.php");

$response = ['status' => '', 'message' => '', 'data' => []];

try {
    if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
        throw new Exception('Method not allowed', 405);
    }

    if (!isset($_POST['worker_id'])) {
        throw new Exception('worker_id is required', 400);
    }

    $worker_id = $_POST['worker_id'];
    
    if (!is_numeric($worker_id)) {
        throw new Exception('worker_id must be numeric', 400);
    }

    $sql = "SELECT id, full_name, username, email, phone, address FROM workers WHERE id = ?";
    $stmt = $conn->prepare($sql);
    
    if (!$stmt) {
        throw new Exception('Database preparation failed: ' . $conn->error, 500);
    }

    $stmt->bind_param("i", $worker_id);
    
    if (!$stmt->execute()) {
        throw new Exception('Execution failed: ' . $stmt->error, 500);
    }

    $result = $stmt->get_result();
    
    if ($result->num_rows > 0) {
        $row = $result->fetch_assoc();
        $response['status'] = 'success';
        $response['data'] = [
            'id' => $row['id'],
            'full_name' => $row['full_name'],
            'username' => $row['username'],
            'email' => $row['email'],
            'phone' => $row['phone'],
            'address' => $row['address']
        ];
    } else {
        throw new Exception('Worker not found', 404);
    }

} catch (Exception $e) {
    http_response_code($e->getCode() ?: 500);
    $response['status'] = 'error';
    $response['message'] = $e->getMessage();
} finally {
    if (isset($stmt)) $stmt->close();
    $conn->close();
    echo json_encode($response);
}
?>