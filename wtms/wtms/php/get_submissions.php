<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json");
header("Access-Control-Allow-Methods: POST");
header("Access-Control-Allow-Headers: Content-Type, Authorization");

include_once("dbconnect.php");

$response = ['status' => '', 'message' => '', 'data' => []];

try {
    if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
        throw new Exception('Method not allowed', 405);
    }

    // Try JSON input
    $input = json_decode(file_get_contents("php://input"), true);

    // Fallback to POST form
    if (empty($input)) {
        $input = $_POST;
    }

    if (!isset($input['worker_id'])) {
        throw new Exception('worker_id is required');
    }

    $worker_id = $input['worker_id'];

    if (!is_numeric($worker_id)) {
        throw new Exception('worker_id must be numeric');
    }

    $sql = "SELECT s.id, s.submission_text, s.submitted_at as submission_date, w.title 
            FROM tbl_submissions s 
            JOIN tbl_works w ON s.work_id = w.id 
            WHERE s.worker_id = ? 
            ORDER BY s.submitted_at DESC";

    $stmt = $conn->prepare($sql);
    if (!$stmt) {
        throw new Exception('Prepare failed: ' . $conn->error);
    }

    $stmt->bind_param("i", $worker_id);
    $stmt->execute();

    $result = $stmt->get_result();
    $data = [];

    while ($row = $result->fetch_assoc()) {
        $data[] = [
            'id' => $row['id'],
            'title' => $row['title'],
            'submission_text' => $row['submission_text'],
            'submission_date' => $row['submission_date'],
        ];
    }

    $response['status'] = 'success';
    $response['data'] = $data;

} catch (Exception $e) {
    http_response_code(400);
    $response['status'] = 'error';
    $response['message'] = $e->getMessage();
} finally {
    if (isset($stmt)) $stmt->close();
    $conn->close();
    echo json_encode($response);
}
?>
