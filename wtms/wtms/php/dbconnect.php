<?php

$servername = "localhost";
$workername   = "root";
$password   = "";
$dbname     = "wtms_db";

// Create connection
$conn = new mysqli($servername, $workername, $password, $dbname);

// Check connection
if ($conn->connect_error) {
    die("Connection failed: " . $conn->connect_error);
}

// Set character set to UTF-8
$conn->set_charset("utf8");

?>
