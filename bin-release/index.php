
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.1//EN" "http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd">
<html>
  <head>
    <title>TinBob</title>
    <style type="text/css">
      html, body {
        height: 100%;
        width: 100%;
        padding: 0;
        margin: 0;
      }

      #full-screen-background-image {
        z-index: -999;
        min-height: 100%;
        min-width: 900px;
        width: 100%;
        height: auto;
        position: fixed;
        top: 0;
        left: 0;
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
    <img src="<?php bloginfo('template_url');?>/temp/bg.jpg" id="full-screen-background-image">
    <img src="<?php bloginfo('template_url');?>/temp/info.png"  id="info">
    <?php wp_footer(); ?>
  </body>

</html>
