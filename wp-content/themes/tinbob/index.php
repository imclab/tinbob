<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" <?php language_attributes(); ?>>

<head profile="http://gmpg.org/xfn/11">
	<meta http-equiv="Content-Type" content="<?php bloginfo('html_type'); ?>; charset=<?php bloginfo('charset'); ?>" />
	
	<?php if (is_single() || is_page()) {?>
		<meta name="description" content="<?php $post->post_excerpt?>"/>
	<?php } elseif (is_home()) {?>
		<meta name="description" content="<?php get_bloginfo('description')?>"/>
	<?php } ?>
	
	<title><?php wp_title('-', true, 'right'); ?><?php bloginfo('name'); ?></title>
	<link rel="shortcut icon" href="<?php bloginfo('stylesheet_directory');?>/img/favicon.png">
	<script type="text/javascript" src="http://ajax.googleapis.com/ajax/libs/swfobject/2.2/swfobject.js"></script>
	<script type="text/javascript" src="<?php bloginfo('stylesheet_directory');?>/js/swfaddress.js"></script>
	<script type="text/javascript" src="<?php bloginfo('stylesheet_directory');?>/js/swffit.js"></script>
	
	<?php if (is_single() || is_page()) $branchPath=parse_url(get_permalink($wp_query->post->ID), PHP_URL_PATH);
	else $branchPath="/";?>
	
	<script type="text/javascript">
	var params = {
		allowscriptaccess: "always",
		bgcolor: "#000000"
	};
	var flashvars = {
		domain: "<?php bloginfo('url')?>",
		branch: "<?php echo $branchPath;?>"
	};
	var attributes = {
		id: "flashcontent",
		name: "flashcontent"
	};
	swfobject.embedSWF("<?php bloginfo('template_url');?>/Main.swf", "flashcontent", "900", "600", "10.1.0", "<?php bloginfo('template_url');?>/expressInstall.swf", flashvars, params, attributes);
	swffit.fit("flashcontent");
	</script>
	<?php wp_head(); ?>
</head>

<body>
<div id="flashcontent">
	<div id="alternateContent">
		<h1><a href="<?php bloginfo('url'); ?>/"><?php bloginfo('name'); ?></a></h1>
		<?php if (have_posts()) : while (have_posts()) : the_post(); ?>
		<h2><a href="<?php the_permalink() ?>" rel="bookmark"><?php the_title(); ?></a></h2>
		<h3>Description:</h3>
		<p><?php the_content() ?></p>
		<h3>Media:</h3>
		<?php echo "<img src=\"".get_post_meta($post->ID, "thumbnail", true)."\" alt=\"".get_the_title()."\" title=\"".get_the_title()."\"/>";?>
		<?php endwhile;?>
		<?php else :?><h2>404 Page not found</h2>
		<?php endif; ?>
	</div>
	<div id="noflash">
		<p>If you enable Flash and JavaScript this page will look cool!</p>
	</div>
</div>

<?php wp_footer(); ?>
</body>
</html>