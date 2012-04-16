<?php
/**
 * The base configurations of the WordPress.
 *
 * This file has the following configurations: MySQL settings, Table Prefix,
 * Secret Keys, WordPress Language, and ABSPATH. You can find more information
 * by visiting {@link http://codex.wordpress.org/Editing_wp-config.php Editing
 * wp-config.php} Codex page. You can get the MySQL settings from your web host.
 *
 * This file is used by the wp-config.php creation script during the
 * installation. You don't have to use the web site, you can just copy this file
 * to "wp-config.php" and fill in the values.
 *
 * @package WordPress
 */

// ** MySQL settings - You can get this info from your web host ** //
/** The name of the database for WordPress */
define('DB_NAME', 'tinbob_com');

/** MySQL database username */
define('DB_USER', 'root');

/** MySQL database password */
define('DB_PASSWORD', 'root');

/** MySQL hostname */
define('DB_HOST', 'localhost');

/** Database Charset to use in creating database tables. */
define('DB_CHARSET', 'utf8');

/** The Database Collate type. Don't change this if in doubt. */
define('DB_COLLATE', '');

/**#@+
 * Authentication Unique Keys and Salts.
 *
 * Change these to different unique phrases!
 * You can generate these using the {@link https://api.wordpress.org/secret-key/1.1/salt/ WordPress.org secret-key service}
 * You can change these at any point in time to invalidate all existing cookies. This will force all users to have to log in again.
 *
 * @since 2.6.0
 */
define('AUTH_KEY',         'KwC)YK%|>Yl03z;+NIU%D_Rs[b9dc=J}HgRTM|5OYHTdM$6bSqeOFTN.0E&Bh@]s');
define('SECURE_AUTH_KEY',  'sSW+#5iZcu~%jM(&O`|k^!jX1X1OX>SS{Aj<wtb;qUog(E5jk|4-|gk5?JLnymgZ');
define('LOGGED_IN_KEY',    '?8g&`VUGs$Ffh13,f+L2H`tY=Ds0Ob<-4~n0rg4H/AG46-kc+D||0z=t15 b++gd');
define('NONCE_KEY',        'OD~A}%KJ+d0gz@`57L{rGfi!t+z^w~Z{x4/(APCz1@&~-fr2q9+>I_5rSc-1S$s0');
define('AUTH_SALT',        '$JpVq$ac$q?^qBHn`3KWygg.rx`;,rU_Idu)8FtvA%}opU|vYP_Ub//~(}Wd}a{6');
define('SECURE_AUTH_SALT', '#*/|<XJ:o0@dRy75[gX|`Q2V|CS(CI^uG|13a-srgjf,E0F8C*wFUmA=8Dc@_u)f');
define('LOGGED_IN_SALT',   'AOY`<2KMjMu$-rDi4bzJ49_UD`eZixYn[t-rpZrLVWNbo6D+skLZ}( }X?_~%#kS');
define('NONCE_SALT',       '+a)!k;1L<M=,64Bm6.~m=xIt)EIiVW=|.m__Cmu+}SlLic8yAQ#J~Bu`$ftbns`_');

/**#@-*/

/**
 * WordPress Database Table prefix.
 *
 * You can have multiple installations in one database if you give each a unique
 * prefix. Only numbers, letters, and underscores please!
 */
$table_prefix  = 'wp_0dd7x4_';

/**
 * WordPress Localized Language, defaults to English.
 *
 * Change this to localize WordPress. A corresponding MO file for the chosen
 * language must be installed to wp-content/languages. For example, install
 * de_DE.mo to wp-content/languages and set WPLANG to 'de_DE' to enable German
 * language support.
 */
define('WPLANG', '');

/** Absolute path to the WordPress directory. */
if ( !defined('ABSPATH') )
	define('ABSPATH', dirname(__FILE__) . '/');

/** Define WP_CONTENT_DIR to the correct directory as we are using a symlink */
define( 'WP_CONTENT_DIR', realpath( ABSPATH . '/wp-content' ) );

/**
 * Use this to check if you are on a production or development enviroment.
 * If you are on development, deploy a empty 'development' file in the root of the wordpress installation
 */
define('DEV_ENVIROMENT', file_exists( ABSPATH . 'development' ));

/**
 * This will log all errors notices and warnings to a file called debug.log in
 * wp-content (if Apache does not have write permission, you may need to create
 * the file first and set the appropriate permissions (i.e. use 666) ) 
 */
define('WP_DEBUG', true);
define('WP_DEBUG_LOG', true);
define('WP_DEBUG_DISPLAY', DEV_ENVIROMENT); // only display on development
@ini_set('display_errors',0);

/* That's all, stop editing! Happy blogging. */

/** Sets up WordPress vars and included files. */
require_once(ABSPATH . 'wp-settings.php');
?>
