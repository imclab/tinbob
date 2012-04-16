<?php 
      global $template_url;
      /**
      * If $theme_dir exists, it means we reach this page via the
      * standart wordpress maintenance mode. If that is the case, none
      * of the usual wp functions (like bloginfo(), etc) will be available.
      * In that case we use $theme_dir to load any theme specific resources. 
      **/
      if( $template_url ){
        $root = $template_url;

      }
      else{
        $root = get_bloginfo('template_url');
      }
?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.1//EN" "http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd">
<html>
  <head>
    <title>TinBob</title>
    <link rel="shortcut icon" href="<?php echo $root;?>/img/favicon.png">
    <style type="text/css">
      html {
        background: url(<?php echo $root;?>/img/temp_bg.jpg) no-repeat center center fixed;
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
  </head>

  <body>
    <img src="<?php echo $root;?>/img/temp_info.png"  id="info">
  </body>

</html>
