<?php
/**
 * PURPOSE OF THIS FILE:
 *   This file should be used for any configuration that needs to be added at
 *   the end of LocalSettings.php. In principle, this falls into two categories:
 *
 *   1) Pretty much any MediaWiki configuration variable starting with "$wg" and
 *      in the mediawiki.org category "MediaWiki configuration settings":
 *      https://www.mediawiki.org/wiki/Category:MediaWiki_configuration_settings
 *
 *   2) Pretty much any configuration changes to extensions part of core Meza.
 *      For example, since Extension:VisualEditor comes with Meza, if you want
 *      to modify VE's settings you add them here.
 *
 *   Don't add to this file:
 *
 *   A) Configuration for extensions in MezaLocalExtensions.yml, since it's
 *      cleaner to just add those config lines into MezaLocalExtensions.yml
 *      itself.
 *
 **/


# MEDIAWIKI CONFIGURATION
# =======================

// Use patrolling to check for vandalism. If set to false, exclamation points
// will not appear in recent changes next to unpatrolled edits. Also removes
// "mark patrolled" from bottom of pages
$wgUseRCPatrol = false;


$wgEmergencyContact = str_replace( ' ','-',$wgSitename ) . '@wiki.msfc.nasa.gov';
$wgPasswordSender = $wgEmergencyContact;


array_push( $wgUrlProtocols, "file://" );


//Make wiki trust zip file (includes Microsoft files)
$wgTrustedMediaFormats[] = 'application/zip';


#
#   CURATORs: people with delete permissions for now
#
// $wgGroupPermissions['Curator'] = $wgGroupPermissions['user'];
// $wgGroupPermissions['Curator']['delete'] = true; // Delete pages
// $wgGroupPermissions['Curator']['bigdelete'] = true; // Delete pages with large histories
// $wgGroupPermissions['Curator']['suppressredirect'] = true; // Not create redirect when moving page
// $wgGroupPermissions['Curator']['browsearchive'] = true; // Search deleted pages
// $wgGroupPermissions['Curator']['undelete'] = true; // Undelete a page
// $wgGroupPermissions['Curator']['deletedhistory'] = true; // View deleted history w/o associated text
// $wgGroupPermissions['Curator']['deletedtext'] = true; // View deleted text/changes between deleted revs


#
#   MANAGERs: can edit user rights, plus used in MediaWiki:Approvedrevs-permissions
#   to allow managers to give managers the ability to approve pages (lesson plans, ESOP, etc)
#
$wgGroupPermissions['Manager'] = $wgGroupPermissions['user'];
$wgGroupPermissions['Manager']['userrights'] = true; // Edit all user rights

#
#   Sysop
#
$wgGroupPermissions['sysop']['clearreviews'] = false;

# Mediawiki now has a new interface permission required for editing common.css and common.js
// $wgGroupPermissions['sysop']['editsitecss'] = true;
// $wgGroupPermissions['sysop']['editsitejs'] = true;
// $wgGroupPermissions['sysop']['editsitejson'] = true;
// $wgGroupPermissions['sysop']['editusercss'] = true;
// $wgGroupPermissions['sysop']['edituserjs'] = true;
// $wgGroupPermissions['sysop']['edituserjson'] = true;

#
#   Server Admins: Can do scary things like clear pending reviews
#
$wgGroupPermissions['serveradmin'] = $wgGroupPermissions['user'];
$wgGroupPermissions['serveradmin']['clearreviews'] = true;

# Allow deleting individual revisions. Revisions can then be completely expunged by
# running https://www.mediawiki.org/wiki/Manual:DeleteArchivedRevisions.php
$wgGroupPermissions['serveradmin']['deletelogentry'] = true;
$wgGroupPermissions['serveradmin']['deleterevision'] = true;


#FIXME: should be core Meza
$wgGroupPermissions['user']['talk'] = true;
$wgGroupPermissions['Viewer']['talk'] = true;


$wgFileExtensions[] = 'docm';
$wgFileExtensions[] = 'xlsm';
$wgFileExtensions[] = 'zip';
$wgFileExtensions[] = 'log'; // requested for EMU log files
$wgFileExtensions[] = 'dotx'; // MS Word template files, requested by Costa Mavridis for creating???
$wgFileExtensions[] = 'kml';

// remove "this file type may contain malicious code" warning
$wgTrustedMediaFormats[] = "application/vnd.openxmlformats-officedocument.wordprocessingml.document";
$wgTrustedMediaFormats[] = "application/vnd.openxmlformats-officedocument.presentationml.presentation";
$wgTrustedMediaFormats[] = "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet";


// if ( in_array( $wikiId, [ 'robo','oso','eva' ] ) ) {
	// $wgGroupPermissions['Contributor']['edit'] = false;
	// $wgGroupPermissions['sysop']['edit'] = false;
	// $wgGroupPermissions['bureaucrat']['edit'] = false;
// }

// if wiki _is_ ISS, diff with FOD. Else, diff your wiki with ISS.
// if ( $wikiId === 'iss' ) {
	// $wgCWDwikis = [ 'iss', 'fod' ];
// }
// else {
	// $wgCWDwikis = [ 'iss', $wikiId ];
// }


# MEZA CORE EXTENSIONS CONFIGURATION
# ==================================

# Extension:WatchAnalytics
# ------------------------

# Activating Page Scores on the following namespaces:
# Main, Talk, File, File Talk, KB, KB Talk
$egWatchAnalyticsPageScoreNamespaces = array( NS_MAIN, NS_TALK, NS_FILE, NS_FILE_TALK, NS_KB, NS_KB_TALK, NS_ACTION );


# Extension:VisualEditor
# ----------------------

// Add VisualEditor signature button to main namespace
$wgExtraSignatureNamespaces = [ NS_MAIN ];

// Allow VisualEditor in talk namespace
// Note, to add custom namespaces to other wikis, do:
// $wgVisualEditorAvailableNamespaces[NS_YOUR_NS_ID] = true;
$wgVisualEditorAvailableNamespaces = [
        NS_TALK => true,
        "_merge_strategy" => "array_plus"
];


# Extension:WhoIsWatching
# -----------------------

# Give all logged in users full access.
$wgGroupPermissions['user']['addpagetoanywatchlist'] = true;
$wgGroupPermissions['user']['seepagewatchers'] = true;


# Extension:HeaderFooter
# ----------------------

# Load footers asynchronously after page load. Keep headers synchronous
$egHeaderFooterEnableAsyncHeader = false;
$egHeaderFooterEnableAsyncFooter = true;

# We attempted to enable the parser cache, but it had no effect. Both CACHE_DB
# and CACHE_MEMCACHED were attempted. Both showed the same response time on the
# KMS server over hundreds of evenly-spaced hits. Hitting the same page
# repeatedly appeared to actually be slower with both CACHE_DB and
# CACHE_MEMCACHED than with CACHE_NONE.
#
# The Meza default for this is CACHE_NONE. This was done because there had been
# some previous issues with loading the footer (Extension:HeaderFooter) or
# loading something to do with SMW. Tests on 25-Sep-2018 indicated there were no
# such issues. Ref: https://github.com/enterprisemediawiki/meza/issues/244
#
# For now go back to Meza default of CACHE_NONE. Further testing of this should
# be done at a later time, to at least determine _why_ it had no effect.
// $wgParserCacheType = CACHE_DB;


# Extension:StringFunctionsEscaped
# --------------------------------

// Issue #429: Need to bump up defaults for Extension:StringFunctions(Escaped)
$wgPFStringLengthLimit = 5000;
$wgStringFunctionsLimitSearch = 5000;
$wgStringFunctionsLimitReplace = 5000;


# Extension:BatchUserRights
# -------------------------

$wgBatchUserRightsGrantableGroups = array( 'bot', 'sysop','Viewer', 'Contributor' );


# Extension:CirrusSearch
# ----------------------

// Search cross-wiki
// if ( $wikiId !== 'fod' ) {
	// $wgCirrusSearchEnableCrossProjectSearch = true;
	// $wgCirrusSearchWikiToNameMap = [
		// 'fod' => 'wiki_fod',
	// ];
	// $wgCirrusSearchInterwikiSources = [
		// 'fod' => 'wiki_fod_content_first',
	// ];
// }

# Extension: PageForms
# --------------------
// The default value is true which breaks autocomplete with concepts
// The default max number of autocompletion values is 1000
$wgPageFormsUseDisplayTitle = false;
$wgPageFormsMaxAutocompleteValues = 5000;
$wgPageFormsHeightForMinimizingInstances = -1;


# Extension:SemanticMediaWiki
# ---------------------------

$smwgNamespacesWithSemanticLinks[NS_TEMPLATE] = true;

// https://www.semantic-mediawiki.org/wiki/Help:$maxRecursionDepth
// don't format like this: $maxRecursionDepth = 5;
SMWResultPrinter::$maxRecursionDepth = 5;

# Special:TransferPages
# ---------------------
# Disabling this for all until the tool is ready to be used

# strip transferpages rights from EVERYONE
// foreach( $wgGroupPermissions as $group => &$permissions ) {
  // $permissions['transferpages'] = false;
// }

# first create a group for the privileged few, inheriting from user
$wgGroupPermissions['transformers'] = $wgGroupPermissions['user'];

# explicitly add transferpages back to just these privileged few
$wgGroupPermissions['transformers']['transferpages'] = true;

# Extension:SemanticResultFormats
# -------------------------------
// For format=calendar
// Sets first day of the week for the calendar to Monday
$srfgFirstDayOfWeek = 'Monday';
