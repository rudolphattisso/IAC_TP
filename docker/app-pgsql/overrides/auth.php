<?php
    if (isset($_POST['US_login']) and isset($_POST['US_password'])) {
        session_start();
        include 'connect.php';

        ini_set('display_errors', '1');

        // SHA2(?, 256) est une fonction MySQL qui n'existe pas en PostgreSQL.
        // On hache le mot de passe côté PHP — résultat identique, compatible tous SGBD.
        $hashed = hash('sha256', $_POST['US_password']);

        $sql = "SELECT * FROM utilisateurs WHERE US_login = ? AND US_password = ?";
        $stmt = $db->prepare($sql);
        $stmt->bindParam(1, $_POST['US_login']);
        $stmt->bindParam(2, $hashed);
        $stmt->execute();
        $res = $stmt->fetchAll(PDO::FETCH_ASSOC);
        if (!empty($res)) {
            if ( count($res) > 0) {
                $utilisateur = $res[0];
                // PostgreSQL retourne les noms de colonnes en minuscules
                $_SESSION['login'] = $utilisateur['us_login'];
                header("Location: home.php");
            } else {
                header("Location: index.php");
            }
        } else {
            header("Location: BADUSER.html");
        }
    }
?>
