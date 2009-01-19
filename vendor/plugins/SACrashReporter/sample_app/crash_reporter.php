<?php

$to = 'me@example.com';
$from = 'noreply@example.com';

$subject = '[CRASH LOG] ' . $_POST['app_name'];
$divider = "\n\n=========================================================================\n\n";
$message = "\n" . $_POST['crash_log'] . $divider . $_POST['comment'];

$headers = 'From: ' . $from . "\r\n" .
           'Reply-To: ' . $from . "\r\n" .
           "Content-Transfer-Encoding: 8bit\r\n" .
           "Content-Type: text/plain; charset=UTF-8\r\n" .
           'X-Mailer: PHP/' . phpversion();

mail($to, $subject, $message, $headers);

?>