<?php

# Protect against web entry
if ( !defined( 'MEDIAWIKI' ) ) {
	exit;
}


/**
 *  TABLE OF CONTENTS
 *
 *    1) WIKI-SPECIFIC SETUP
 *    2) DEBUG
 *    3) PATH SETUP
 *    4) EMAIL
 *    5) DATABASE SETUP
 *    6) GENERAL CONFIGURATION
 *    7) PERMISSIONS
 *    8) EXTENSION SETTINGS
 *    9) LOAD OVERRIDES
 *
 **/


/**
 *  1) WIKI-SPECIFIC SETUP
 *
 *  Acquire the intended wiki either from the REQUEST_URI (for web requests) or
 *  from the WIKI environment variable (for command line scripts)
 **/

require '/opt/.deploy-meza/config.php';

if( $wgCommandLineMode ) {

	$mezaWikiEnvVarName='WIKI';

	// get $wikiId from environment variable
	$wikiId = getenv( $mezaWikiEnvVarName );

}
else {

	// get $wikiId from URI
	$uriParts = explode( '/', $_SERVER['REQUEST_URI'] );
	$wikiId = strtolower( $uriParts[1] ); // URI has leading slash, so $uriParts[0] is empty string

}





// get all directory names in /wikis, minus the first two: . and ..
$wikis = array_slice( scandir( "$m_htdocs/wikis" ), 2 );


if ( ! in_array( $wikiId, $wikis ) ) {

	// handle invalid wiki
	die( "No sir, I ain't heard'a no wiki that goes by the name \"$wikiId\"\n" );

}

// Set an all-wiki auth type, which individual wikis can override
$mezaAuthType = 'anon-read';

#
# PRE LOCAL SETTINGS
#
#    (1) Load all PHP files in preLocalSettings.d for all wikis
foreach ( glob("$m_deploy/public/preLocalSettings.d/*.php") as $filename) {
    require_once $filename;
}
#    (2) Load all PHP files in preLocalSettings.d for this wiki
foreach ( glob("$m_deploy/public/wikis/$wikiId/preLocalSettings.d/*.php") as $filename) {
    require_once $filename;
}




















/**
 *  2) DEBUG
 *
 *  Options to enable debug are below. The lowest-impact solution should be
 *  chosen. Options are listed from least impact to most impact.
 *    1) Add to the URI you're requesting `requestDebug=true` to enable debug
 *       for just that request.
 *    2) Set `$mezaCommandLineDebug = true;` for debug on the command line.
 *       This is the default, which can be overriden in preLocalSettings_allWiki.php.
 *    3) Set `$mezaDebug = array( "NDC\Your-ndc", ... );` in a wiki's preLocalSettings.php
 *       to enable debug for just specific users on a single wiki.
 *    4) Set `$mezaDebug = true;` in a wiki's preLocalSettings.php to enable debug for all
 *       users of a single wiki.
 *    5) Set `$mezaForceDebug = true;` to turn on debug for all users and wikis
 **/
$mezaCommandLineDebug = True; // don't we always want debug on command line?
$mezaForceDebug = False;


if ( $mezaForceDebug ) {
	$debug = true;
}

elseif ( $wgCommandLineMode && $mezaCommandLineDebug ) {
	$debug = true;
}

elseif ( $GLOBALS['mezaDebug'] === true ) {
	$debug = true;
}

// Check if $mezaDebug is an array, and if so check if the requesting user is
// in the array.
elseif ( ! $wgCommandLineMode
	&& is_array( $GLOBALS['mezaDebug'] )
	&& in_array( $_SERVER["REMOTE_USER"], $GLOBALS['mezaDebug'] )
) {
	$debug = true;
}

elseif ( isset( $_GET['requestDebug'] ) ) {
	$debug = true;
}

else {
	$debug = false;
}


if ( $debug ) {

	// turn error logging on
	error_reporting( -1 );
	ini_set( 'display_errors', 1 );
	ini_set( 'log_errors', 1 );

	// Output errors to log file
	ini_set( 'error_log', "$m_meza_data/logs/php/php_errors.log" );


	// Displays debug data at the bottom of the content area in a formatted
	// list below a horizontal line.
	$wgShowDebug = true;

	// A more elaborative debug toolbar with interactive panels.
	$wgDebugToolbar = true;

	// Uncaught exceptions will print a complete stack trace to output (instead
	// of just to logs)
	$wgShowExceptionDetails = true;

	// SQL statements are dumped to the $wgDebugLogFile (if set) /and/or to
	// HTML output (if $wgDebugComments is true)
	$wgDebugDumpSql  = true;

	// If on, some debug items may appear in comments in the HTML output.
	$wgDebugComments = false;

	// The file name of the debug log, or empty if disabled. wfDebug() appends
	// to this file.
	$wgDebugLogFile = "/opt/data-meza/logs/mw-debug.log";

	// If true, show a backtrace for database errors.
	$wgShowDBErrorBacktrace = true;

	// Shows the actual query when errors occur (in HTML, I think. Not logs)
	$wgShowSQLErrors = true;

}

// production: no error reporting
else {

	error_reporting(0);
	ini_set("display_errors", 0);

}









/**
 *  3) PATH SETUP
 *
 *
 **/

// ref: https://www.mediawiki.org/wiki/Manual:$wgServer
//   From section #Autodetection:
//     "When $wgServer is not set, the default value is calculated
//     automatically. Some web servers end up returning silly defaults or
//     internal names which aren't what you want..."
//
// Depending on proxy setup (particularly for Varnish/Squid caching) may need
// to set $wgInternalServer:
// ref: https://www.mediawiki.org/wiki/Manual:$wgInternalServer
$wgServer = 'https://10.255.252.201';

// https://www.mediawiki.org/wiki/Manual:$wgScriptPath
$wgScriptPath = "/$wikiId";

// https://www.mediawiki.org/wiki/Manual:$wgUploadPath
$wgUploadPath = "$wgScriptPath/img_auth.php";

// https://www.mediawiki.org/wiki/Manual:$wgUploadDirectory
$wgUploadDirectory = "/opt/data-meza/uploads/$wikiId";

// https://www.mediawiki.org/wiki/Manual:$wgLogo
$wgLogo = "/wikis/$wikiId/config/logo.png";

// https://www.mediawiki.org/wiki/Manual:$wgFavicon
$wgFavicon = "/wikis/$wikiId/config/favicon.ico";


// https://www.mediawiki.org/wiki/Manual:$wgMetaNamespace
$wgMetaNamespace = str_replace( ' ', '_', $wgSitename );

// @todo: handle auth type from preLocalSettings.php
// @todo: handle debug from preLocalSettings_allWikis.php

// From MW web install: Uncomment this to disable output compression
# $wgDisableOutputCompression = true;

$wgScriptExtension = ".php";

## The relative URL path to the skins directory
$wgStylePath = "$wgScriptPath/skins";
$wgResourceBasePath = $wgScriptPath;









/**
 *  4) EMAIL
 *
 *  Email configuration
 **/
if ( isset( $mezaEnableWikiEmail ) && $mezaEnableWikiEmail ) {
	$wgEnableEmail = true;
}
else {
	$wgEnableEmail = false;
}

## UPO means: this is also a user preference option
$wgEnableUserEmail = $wgEnableEmail; # UPO
$wgEnotifUserTalk = $wgEnableEmail; # UPO
$wgEnotifWatchlist = $wgEnableEmail; # UPO
$wgEmailAuthentication = $wgEnableEmail;

$wgPasswordSender = 'admin@example.com';
$wgEmergencyContact = 'admin@example.com';










/**
 *  5) DATABASE SETUP
 *
 *
 **/
$mezaDatabaseServers = array( 'localhost' );


$mezaDatabasePassword = 'DummyPasw0rd$';
$mezaDatabaseUser = 'wiki_app_user';
$mezaThisServer = 'localhost';

// even though using $wgDBservers method below, keep $wgDBname per warning in:
// https://www.mediawiki.org/wiki/Manual:$wgDBservers
$wgDBname = isset( $mezaCustomDBname ) ? $mezaCustomDBname : "wiki_$wikiId";

// first server in list, master, gets a value of 1. If it's the only server, it
// will get 100% of the load. If there is one slave, it will get a value of 10
// and thus will take ~90% of the read-load (master will take ~10%). If there
// are X slaves, master will take 1/(1+10X) of the load. This causes master to
// get very little of the load, but in the case that all the slaves fail master
// still is configured to pick up the entirety of the read-load.
//
// FIXME #821: Make load configurable.
$databaseReadLoadRatio = 1;

$wgDBservers = array();
foreach( $mezaDatabaseServers as $databaseServer ) {
	if ( $databaseServer === $mezaThisServer ) {
		$databaseServer = 'localhost';
	}
	$wgDBservers[] = array(
		'host' => $databaseServer,
		'dbname' => $wgDBname,
		'user' => $mezaDatabaseUser,
		'password' => $mezaDatabasePassword,
		'type' => "mysql",
		'flags' => $debug ? DBO_DEFAULT | DBO_DEBUG : DBO_DEFAULT,
		'load' => $databaseReadLoadRatio,
	);
	$databaseReadLoadRatio = 10; // every server after the first gets the same loading
}


# MySQL specific settings
$wgDBprefix = "";

# MySQL table options to use during installation or update
$wgDBTableOptions = "ENGINE=InnoDB, DEFAULT CHARSET=binary";

# Experimental charset support for MySQL 5.0.
$wgDBmysql5 = false;


/**
 *  If a primewiki is defined then every wiki will use that wiki db for certain
 *  tables. The shared `interwiki` table allows users to use the same interwiki
 *  prefixes across all wikis. The `user` and `user_properties` tables make all
 *  wikis have the same set of users and user properties/preferences. This does
 *  not affect the user groups, so a user can be a sysop on one wiki and just a
 *  user on another.
 *
 *  To enable a primewiki add the `primary_wiki_id` variable to the config with
 *  the value being the wiki ID of the prime wiki (e.g. the 1st part of the URL
 *  after the domain, e.g. https://example.com/<wiki_id>)
 *
 *  In order for this to work properly the wikis need to have been created with
 *  a single user table in mind. If you're starting a new wiki farm then you're
 *  all set. If you're importing wikis which didn't previously have shared user
 *  tables, then you'll need to use the unifyUserTables.php script. Please test
 *  this script extensively before use. Unifying user tables is complicated.
 **/
$wgSharedDB = 'wiki_poic';
$wgSharedTables = array(
	'user',            // default
	'user_properties', // default
	'interwiki',       // additional
);





/**
 *  6) GENERAL CONFIGURATION
 *
 *
 *
 **/
// proxy setup
$wgUseSquid = true;
$wgUsePrivateIPs = true;
$wgSquidServersNoPurge = array(
	'127.0.0.1',	);

// memcached settings
$wgMainCacheType = CACHE_MEMCACHED;
// If parser cache set to CACHE_MEMCACHED, templates used to format SMW query
// results in generic footer don't work. This is a limitation of
// Extension:HeaderFooter which may or may not be able to be worked around.
$wgParserCacheType = CACHE_NONE;
$wgMessageCacheType = CACHE_MEMCACHED;
$wgMemCachedServers = array(
    '127.0.0.1:11211',);

// memcached is setup and will work for sessions with meza, unless you use
// SimpleSamlPhp. Previous versions of meza had this set to CACHE_NONE, but
// MW 1.27 requires a session cache. Setting this to CACHE_MEMCACHED as it
// is the ultimate goal. A separate branch contains pulling PHP from the
// IUS repository, which should simplify integrating PHP and memcached in a
// way that SimpleSamlPhp likes. So this may be temporarily breaking for
// SAML, but MW 1.27 may be breaking for SAML anyway due to changes in
// AuthPlugin/AuthManager.
$wgSessionCacheType = CACHE_MEMCACHED;

## To enable image uploads, make sure the 'images' directory
## is writable, then set this to true:
$wgEnableUploads = true;
$wgMaxUploadSize = 1024*1024*100; // 100 MB
$wgUseImageMagick = true;
$wgImageMagickConvertCommand = "/usr/bin/convert";

# InstantCommons allows wiki to use images from http://commons.wikimedia.org
$wgUseInstantCommons = false;

## If you use ImageMagick (or any other shell command) on a
## Linux server, this will need to be set to the name of an
## available UTF-8 locale
$wgShellLocale = "en_US.utf8";

## If you want to use image uploads under safe mode,
## create the directories images/archive, images/thumb and
## images/temp, and make them all writable. Then uncomment
## this, if it's not already uncommented:
$wgHashedUploadDirectory = true;

## Set $wgCacheDirectory to a writable directory on the web server
## to make your wiki go slightly faster. The directory should not
## be publically accessible from the web.
#$wgCacheDirectory = "$IP/cache";

# Site language code, should be one of the list in ./languages/Names.php
$wgLanguageCode = "en";

# https://www.mediawiki.org/wiki/Manual:$wgSecretKey
$wgSecretKey = "N0wkwuang5kVsZ7ie3h5ure6N5M6Dvc22TFBX9adPJjBbA31vnGA1Xz4tP7jIjrC";

## For attaching licensing metadata to pages, and displaying an
## appropriate copyright notice / icon. GNU Free Documentation
## License and Creative Commons licenses are supported so far.
$wgRightsPage = ""; # Set to the title of a wiki page that describes your license/copyright
$wgRightsUrl = "";
$wgRightsText = "";
$wgRightsIcon = "";

# Path to the GNU diff3 utility. Used for conflict resolution.
$wgDiff3 = "/usr/bin/diff3";

## Default skin: you can change the default skin. Use the internal symbolic
## names, ie 'vector', 'monobook': see MezaCoreSkins.yml for choices.
$wgDefaultSkin = "vector";

# Enabled skins.
# The following skins were automatically enabled:
# wfLoadSkin( 'Vector' );
#
# No need to call wfLoadSkin() as this is handled automatically

// allows users to remove the page title.
// https://www.mediawiki.org/wiki/Manual:$wgRestrictDisplayTitle
$wgRestrictDisplayTitle = false;


/**
 * Directory for caching data in the local filesystem. Should not be accessible
 * from the web. Meza's usage of this is for localization cache
 *
 * Note: if multiple wikis share the same localisation cache directory, they
 * must all have the same set of extensions.
 *
 * Refs:
 *  - mediawiki/includes/DefaultSettings.php
 *  - https://www.mediawiki.org/wiki/Localisation#Caching
 *  - https://www.mediawiki.org/wiki/Manual:$wgCacheDirectory
 *  - https://www.mediawiki.org/wiki/Manual:$wgLocalisationCacheConf
 */
$wgCacheDirectory = "/opt/data-meza/cache/$wikiId";







/**
 *
 * Take from LocalSettingsAdditions
 *
 **/

// opens external links in new window
$wgExternalLinkTarget = '_blank';

// added this line to allow linking. specifically to Imagery Online.
$wgAllowExternalImages = true;
$wgAllowImageTag = false;

$wgVectorUseSimpleSearch = true;

//$wgDefaultUserOptions['useeditwarning'] = 1;

// disable page edit warning (edit warning affect Semantic Forms)
$wgVectorFeatures['editwarning']['global'] = false;

$wgDefaultUserOptions['rememberpassword'] = 1;

// users watch pages by default (they can override in settings)
$wgDefaultUserOptions['watchdefault'] = 1;
$wgDefaultUserOptions['watchmoves'] = 1;
$wgDefaultUserOptions['watchdeletion'] = 1;
$wgDefaultUserOptions['watchcreations'] = 1;

// fixes login issue for some users (login issue fixed in MW version 1.18.1 supposedly)
$wgDisableCookieCheck = true;

#Set Default Timezone
$wgLocaltimezone = 'America/Chicago';
$oldtz = getenv("TZ");
putenv("TZ=$wgLocaltimezone");


$wgMaxImageArea = 1.25e10; // Images on [[Snorkel]] fail without this
// $wgMemoryLimit = 500000000; //Default is 50M. This is 500M.


// Increase from default setting for large form
// See https://www.mediawiki.org/wiki/Extension_talk:Semantic_Forms/Archive_April_to_June_2012#Error:_Backtrace_limit_exceeded_during_parsing
// If set to 10million, errors are seen when using Edit with form on mission pages like 41S
// ini_set( 'pcre.backtrack_limit', 10000000 ); //10million
ini_set( 'pcre.backtrack_limit', 1000000000 ); //1 billion


// Allowed file types
$wgFileExtensions = array(
	'aac',
	'bmp',
	'docx',
	'gif',
	'jpg',
	'jpeg',
	'mpp',
	'mp3',
	'msg',
	'odg',
	'odp',
	'ods',
	'odt',
	'pdf',
	'png',
	'pptx',
	'ps',
	'svg',
	'tiff',
	'txt',
	'xlsx',
	'zip'
);

// Tell Universal Language Selector not to try to guess language based upon IP
// address. This (a) isn't likely needed in enterprise use cases and (b) fails
// anyway due to outdated URLs or firewall rules.
$wgULSGeoService = false;

$wgNamespacesWithSubpages[NS_MAIN] = true;

$wgUseRCPatrol = false;





/**
 *  7) PERMISSIONS
 *
 *
 *
 **/
# Prevent new user registrations except by sysops
$wgGroupPermissions['*']['createaccount'] = false;


if ( ! isset( $mezaAuthType ) ) {
	$mezaAuthType = 'anon-read'; // default: require creation by sysop
}
if ( $mezaAuthType === 'anon-edit' ) {

    // allow anonymous read
    $wgGroupPermissions['*']['read'] = true;
    $wgGroupPermissions['user']['read'] = true;

    // allow anonymous write
    $wgGroupPermissions['*']['edit'] = true;
    $wgGroupPermissions['user']['edit'] = true;

}

else if ( $mezaAuthType === 'anon-read' ) {

    // allow anonymous read
    $wgGroupPermissions['*']['read'] = true;
    $wgGroupPermissions['user']['read'] = true;

    // do not allow anonymous write (must be registered user)
    $wgGroupPermissions['*']['edit'] = false;
    $wgGroupPermissions['user']['edit'] = true;

}

else if ( $mezaAuthType === 'user-edit' ) {

    // no anonymous
    $wgGroupPermissions['*']['read'] = false;
    $wgGroupPermissions['*']['edit'] = false;

    // users read and write
    $wgGroupPermissions['user']['read'] = true;
    $wgGroupPermissions['user']['edit'] = true;

}

else if ( $mezaAuthType === 'user-read' ) {

    // no anonymous
    $wgGroupPermissions['*']['read'] = false;
    $wgGroupPermissions['*']['edit'] = false;

    // users read NOT write, but can talk
    $wgGroupPermissions['user']['read'] = true;
    $wgGroupPermissions['user']['edit'] = false;
    $wgGroupPermissions['user']['talk'] = true;

    $wgGroupPermissions['Contributor'] = $wgGroupPermissions['user'];
    $wgGroupPermissions['Contributor']['edit'] = true;

}

else if ( $mezaAuthType === 'viewer-read' ) {

    // no anonymous or ordinary users
    $wgGroupPermissions['*']['read'] = false;
    $wgGroupPermissions['*']['edit'] = false;
    $wgGroupPermissions['user']['read'] = false;
    $wgGroupPermissions['user']['edit'] = false;

    // create the Viewer group with read permissions
    $wgGroupPermissions['Viewer'] = $wgGroupPermissions['user'];
    $wgGroupPermissions['Viewer']['read'] = true;
    $wgGroupPermissions['Viewer']['talk'] = true;

    // also explicitly give sysop read since you otherwise end up with
    // a chicken/egg situation prior to giving people Viewer
    $wgGroupPermissions['sysop']['read'] = true;

    // Create a contributors group that can edit
    $wgGroupPermissions['Contributor'] = $wgGroupPermissions['user'];
    $wgGroupPermissions['Contributor']['edit'] = true;

}

else if ( $mezaAuthType === 'ndc-edit' ) {

    // no anonymous or ordinary users
    $wgGroupPermissions['*']['read'] = false;
    $wgGroupPermissions['*']['edit'] = false;
    $wgGroupPermissions['user']['read'] = false;
    $wgGroupPermissions['user']['edit'] = false;

    // create the NDC group with read permissions
    $wgGroupPermissions['ndc'] = $wgGroupPermissions['user'];
    $wgGroupPermissions['ndc']['read'] = true;
    $wgGroupPermissions['ndc']['talk'] = true;
	$wgGroupPermissions['ndc']['edit'] = true;

    // also explicitly give sysop read since you otherwise end up with
    // a chicken/egg situation prior to giving people NDC
    $wgGroupPermissions['sysop']['read'] = true;

}

else if ( $mezaAuthType === 'project-edit' ) {

    // no anonymous or ordinary users
    $wgGroupPermissions['*']['read'] = false;
    $wgGroupPermissions['*']['edit'] = false;
    $wgGroupPermissions['user']['read'] = false;
    $wgGroupPermissions['user']['edit'] = false;

    // create the PROJECT group with read permissions
    $wgGroupPermissions['project'] = $wgGroupPermissions['user'];
    $wgGroupPermissions['project']['read'] = true;
    $wgGroupPermissions['project']['talk'] = true;
	$wgGroupPermissions['project']['edit'] = true;

    // also explicitly give sysop read since you otherwise end up with
    // a chicken/egg situation prior to giving people PROJECT
    $wgGroupPermissions['sysop']['read'] = true;

}
else if ( $mezaAuthType === 'cadre-edit' ) {

    // no anonymous or ordinary users
    $wgGroupPermissions['*']['read'] = false;
    $wgGroupPermissions['*']['edit'] = false;
    $wgGroupPermissions['user']['read'] = false;
    $wgGroupPermissions['user']['edit'] = false;

    // create the CADRE group with read permissions
    $wgGroupPermissions['cadre'] = $wgGroupPermissions['user'];
    $wgGroupPermissions['cadre']['read'] = true;
    $wgGroupPermissions['cadre']['talk'] = true;
	$wgGroupPermissions['cadre']['edit'] = true;

    // also explicitly give sysop read since you otherwise end up with
    // a chicken/egg situation prior to giving people CADRE
    $wgGroupPermissions['sysop']['read'] = true;

}



/**
 *  8) EXTENSION SETTINGS
 *
 *  Extensions defined in meza core and meza local yaml files, which are used to  *  load the extensions via Git or Composer, and which generate the PHP files
 *  below.
 */

require_once "/opt/.deploy-meza/Extensions.php";


/**
 * Extension:CirrusSearch
 *
 * CirrusSearch cluster(s) are defined based upon Ansible hosts file and thus
 * cannot be easily added to base-extensions.yml. As such, CirrusSearch config
 * is included directly in LocalSettings.php.j2
 */
$wgSearchType = 'CirrusSearch';
$wgCirrusSearchClusters['default'] = [];
$wgCirrusSearchClusters['default'][] = 'localhost';
$wgCirrusSearchWikimediaExtraPlugin['id_hash_mod_filter'] = true;


/**
 * Extension:VisualEditor
 *
 * Parsoid servers are defined based upon Ansible hosts file and thus
 * cannot be easily added to MezaCoreExtensions.yml. As such, VisualEditor config
 * is included directly in LocalSettings.php.j2
 */

/**
 * HTTP_X_FORWARDED_FOR (XFF) is set by HAProxy when users request pages via
 * the load balancer. Users always access via the load balancer. Parsoid may or
 * may not access via the load balancer (it will if Parsoid is not on the same
 * server as the one and only load balancer). In order to allow Parsoid to
 * access MediaWiki with full permissions, grant access to server if:
 *
 *   No XFF (e.g. is a request internal to the server) and REMOTE_ADDR is local
 *   - or -
 *   Yes XFF and XFF is a parsoid server
 *
 * Refs:
 * https://www.mediawiki.org/wiki/Talk:Parsoid/Archive#Running_Parsoid_on_a_.22private.22_wiki_-_AccessDeniedError
 * https://www.mediawiki.org/wiki/Extension:VisualEditor#Linking_with_Parsoid_in_private_wikis
 **/
// initially assume we're not granting special rights
$grantParsoidReadWrite = false;

// if X-Forwarded-For HTTP header exists
if ( isset( $_SERVER['HTTP_X_FORWARDED_FOR'] ) ) {

	$parsoidServers = array(
				'localhost',
			);

	// if request originated at a Parsoid server
	if ( in_array( $_SERVER['HTTP_X_FORWARDED_FOR'], $parsoidServers ) ) {
		$grantParsoidReadWrite = true;
	}

}

// no X-Forwarded-For HTTP Header
else if ( isset( $_SERVER['REMOTE_ADDR'] ) ) {

	// if remote address is this server
	if ( $_SERVER['REMOTE_ADDR'] === 'localhost' || $_SERVER['REMOTE_ADDR'] === '127.0.0.1' ) {
		$grantParsoidReadWrite = true;
	}

}

// if the logic above resulted in granting access
if ( $grantParsoidReadWrite ) {
	$wgGroupPermissions['*']['read'] = true;
	$wgGroupPermissions['*']['edit'] = true;
}

// Enable by default for everybody
$wgDefaultUserOptions['visualeditor-enable'] = 1;

// Don't allow users to disable it
$wgHiddenPrefs[] = 'visualeditor-enable';

// OPTIONAL: Enable VisualEditor's experimental code features
#$wgDefaultUserOptions['visualeditor-enable-experimental'] = 1;



$wgVirtualRestConfig['modules']['parsoid'] = array(


	// One and only Parsoid server is localhost
	'url' => 'http://127.0.0.1:8000',







	// domain here is not really the domain. It needs to be unique to each wiki
	// and both domain and prefix must match settings in Parsoid's settings in
	// /etc/parsoid/localsettings.js
	// ref:
	// https://www.mediawiki.org/wiki/Parsoid/Setup#Multiple_wikis_sharing_the_same_parsoid_service
	'domain' => $wikiId,
	'prefix' => $wikiId
);

// Define which namespaces will use VE
// Per the docs, https://www.mediawiki.org/wiki/Extension:VisualEditor#Changing_active_namespaces
// This is done a little differently in VE than in core or other extensions.
// For VE, we use an array, keyed by the (string) canonical name of the namespace
// and a (boolean) value for enabled or not

// $wgContentNamespaces gets added automatically.

// finally, it should be mentioned that the Extension Registry is what provides for the
// merge strategy

$wgVisualEditorAvailableNamespaces = [
    "User" => true,
    "Project" => true,
    "Help" => true,
    "_merge_strategy" => "array_plus"
];

// quickly add a namespace, without figuring out what the merge strategy is
// $wgVisualEditorAvailableNamespaces[] = NS_CUSTOM;
// $wgVisualEditorAvailableNamespaces[] = NS_PROJECT;



/**
 *  9) LOAD POST LOCAL SETTINGS
 *
 *     Items to override standard config
 *
 *
 **/
#    (1) Load all PHP files in postLocalSettings.d for all wikis
foreach ( glob("$m_deploy/public/postLocalSettings.d/*.php") as $filename) {
    require_once $filename;
}
#    (2) Load all PHP files in postLocalSettings.d for this wiki
foreach ( glob("$m_deploy/public/wikis/$wikiId/postLocalSettings.d/*.php") as $filename) {
    require_once $filename;
}
