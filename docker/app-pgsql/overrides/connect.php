<?php
$host     = getenv('DB_HOST');
$username = getenv('DB_USER');
$password = getenv('DB_PASSWORD');
$dbname   = getenv('DB_NAME');

// DSN pgsql: à la place de mysql: — seul changement par rapport à la version MySQL
$db = new PDO("pgsql:host=$host;dbname=$dbname", $username, $password);
$db->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
$db->setAttribute(PDO::ATTR_DEFAULT_FETCH_MODE, PDO::FETCH_ASSOC);
?>
