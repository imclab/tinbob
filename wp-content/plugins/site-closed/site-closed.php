<?php
/*
Plugin Name: Site Closed
Description: If you activate this plugin the site will be closed adn only logged in logged in users will be able view it normaly. The page will display the content of {theme}/maintenance.php
Version:     1.0
Author:      Oakwood Creative
Plugin URI:  http://oakwood.se
Author URI:  http://oakwood.se
*/
function owc_plugin_site_closed() {
	if(!is_user_logged_in()){
		status_header('503');
		get_template_part('maintenance');
		die;
	}
}
add_action( 'send_headers', 'owc_plugin_site_closed', 0 );
?>