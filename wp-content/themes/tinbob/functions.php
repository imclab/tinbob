<?php 
 // Add "Featured image" feature to posts
add_theme_support( 'post-thumbnails', array( 'post' ) );

	if(!function_exists('getPageContent'))
	{
		function getPageContent($pageId)
		{
			if(!is_numeric($pageId))
			{
				return;
			}
			global $wpdb;
			$sql_query = 'SELECT DISTINCT * FROM ' . $wpdb->posts .
			' WHERE ' . $wpdb->posts . '.ID=' . $pageId;
			$posts = $wpdb->get_results($sql_query);
			if(!empty($posts))
			{
				foreach($posts as $post)
				{
					return nl2br($post->post_content);
				}
			}
		}
	}

?>