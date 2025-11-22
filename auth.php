<?php
require_once 'config_mysql.php';

function requireAuth() {
    // Check if user is logged in via session or API token
    if (!isset($_SESSION['user_id']) && !isset($_SERVER['HTTP_AUTHORIZATION'])) {
        http_response_code(401);
        echo json_encode(['success' => false, 'message' => 'Authentication required']);
        exit;
    }

    // For API calls, verify token (simplified - in production use JWT)
    if (isset($_SERVER['HTTP_AUTHORIZATION'])) {
        $auth_header = $_SERVER['HTTP_AUTHORIZATION'];
        if (strpos($auth_header, 'Bearer ') === 0) {
            $token = substr($auth_header, 7);
            // Verify token against database (simplified)
            $user_id = verifyToken($token);
            if (!$user_id) {
                http_response_code(401);
                echo json_encode(['success' => false, 'message' => 'Invalid token']);
                exit;
            }
            return $user_id;
        }
    }

    return $_SESSION['user_id'] ?? null;
}

function verifyToken($token) {
    global $conn;
    // Simplified token verification - in production use proper JWT
    $sql = "SELECT UserID FROM UserSessions WHERE SessionToken = ? AND ExpiresAt > NOW()";
    $stmt = mysqli_prepare($conn, $sql);
    mysqli_stmt_bind_param($stmt, "s", $token);
    mysqli_stmt_execute($stmt);
    $result = mysqli_stmt_get_result($stmt);
    $row = mysqli_fetch_assoc($result);
    mysqli_stmt_close($stmt);
    return $row ? $row['UserID'] : false;
}

function generateToken($user_id) {
    global $conn;
    $token = bin2hex(random_bytes(32));
    $expires = date('Y-m-d H:i:s', strtotime('+24 hours'));

    $sql = "INSERT INTO UserSessions (UserID, SessionToken, ExpiresAt) VALUES (?, ?, ?)";
    $stmt = mysqli_prepare($conn, $sql);
    mysqli_stmt_bind_param($stmt, "iss", $user_id, $token, $expires);
    mysqli_stmt_execute($stmt);
    mysqli_stmt_close($stmt);

    return $token;
}
?>
