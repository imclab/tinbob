
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.1//EN" "http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd">
<html>
  <head>
    <title>TinBob</title>
    <link rel="shortcut icon" href="<?php bloginfo('stylesheet_directory');?>/img/favicon.png">
    <style type="text/css">
      html {
        background: url(<?php bloginfo('template_url');?>/temp/bg.jpg) no-repeat center center fixed;
        -webkit-background-size: cover;
        -moz-background-size: cover;
        -o-background-size: cover;
        background-size: cover;
      }

      #info {
        position: fixed;
        left: 20px;
        bottom: 20px;
      }
      

    </style>
    <?php wp_head(); ?>
  </head>

  <body>
    <img src="<?php bloginfo('template_url');?>/temp/info.png"  id="info">
    <?php wp_footer(); ?>
  </body>

</html>
