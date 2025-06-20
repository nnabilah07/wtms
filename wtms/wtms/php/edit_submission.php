<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");
header("Access-Control-Allow-Methods: POST");
header("Access-Control-Max-Age: 3600");
header("Access-Control-Allow-Headers: Content-Type, Access-Control-Allow-Headers, Authorization, X-Requested-With");

include_once("dbconnect.php");

$response = ['status' => '', 'message' => ''];

try {
    $input = json_decode(file_get_contents('php://input'), true);
    
    if (!isset($input['submission_id']) || !isset($input['updated_text'])) {
        throw new Exception('Missing required fields', 400);
    }

    $stmt = $conn->prepare("UPDATE tbl_submissions SET submission_text = ? WHERE id = ?");
    $stmt->bind_param("si", $input['updated_text'], $input['submission_id']);
    
    if (!$stmt->execute()) {
        throw new Exception('Update failed: ' . $stmt->error, 500);
    }

    $response['status'] = 'success';
    $response['message'] = 'Submission updated successfully';

} catch (Exception $e) {
    http_response_code($e->getCode() ?: 500);
    $response['status'] = 'error';
    $response['message'] = $e->getMessage();
} finally {
    $conn->close();
    echo json_encode($response);
}
?>