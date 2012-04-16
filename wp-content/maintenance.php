<?php
$protocol = $_SERVER["SERVER_PROTOCOL"];
if ( 'HTTP/1.1' != $protocol && 'HTTP/1.0' != $protocol )
	$protocol = 'HTTP/1.0';
header( "$protocol 503 Service Unavailable", true, 503 );
header( 'Content-Type: text/html; charset=utf-8' );

# Try to manually connect to WP database, find the current theme and if there is a maintence.php file there, laod it
$link = @mysql_connect( DB_HOST, DB_USER, DB_PASSWORD, new_link );
if( $link ){
	$db = @mysql_select_db( DB_NAME, $link );
	if( $db ){
		mysql_close( $link );
		require_once(ABSPATH . 'wp-includes/wp-db.php');
		$wpdb = new wpdb( DB_USER, DB_PASSWORD, DB_NAME, DB_HOST );
		
		$template = $wpdb->get_results(
			"SELECT
				wp_options.option_value
			FROM
				wp_options
			WHERE
				wp_options.option_name = 'template'"
		);
		if( count( $template ) ){
			global $template_dir, $template_url;
			$template_ref = '/themes/' . $template[0]->option_value;
			$template_url = '/wp-content' . $template_ref;
			$template_dir = WP_CONTENT_DIR . $template_ref;

			if ( file_exists( $template_dir . '/maintenance.php' ) ) {
				require_once( $template_dir . '/maintenance.php' );
				die();
			}
		}	
	}		
}

# Ok... no maintence file found, display the default!

?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
    <title>Maintenance</title>

</head>
<body>

    <h1>Briefly unavailable for scheduled maintenance. Check back in a minute.</h1>
</body>
</html>
<?php die(); ?>