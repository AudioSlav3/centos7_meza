<?php


/**
 * Enables or disables wiki email capabilities for all wikis, regardless of
 * of what their individual settings say.
 *
 **/
// disabled by default for now, should be enabled later for
// $mezaEnableAllWikiEmail = true;

// set a default $mezaAuthType for all wikis that don't specify one
$mezaAuthType = 'viewer-read';

// don't let nobody do no account creatin'
// $wgGroupPermissions['*']['createaccount'] = false;
// $wgGroupPermissions['user']['createaccount'] = false;
// $wgGroupPermissions['sysop']['createaccount'] = false;
// $wgGroupPermissions['bureaucrat']['createaccount'] = false;

// Don't let nobody use minor edit
// $wgGroupPermissions['*']['minoredit'] = false;
// $wgGroupPermissions['user']['minoredit'] = false;
// $wgGroupPermissions['sysop']['minoredit'] = false;
// $wgGroupPermissions['bureaucrat']['minoredit'] = false;

// $wgSMTP = array(
	// 'host'     => "mrelay.jsc.nasa.gov",
	// 'IDHost'   => "wiki-int.fit.nasa.gov",
	// 'port'     => 25,    // Port to use when connecting to the SMTP server
	// 'auth'     => false  // mrelay.jsc.nasa.gov doesn't require auth
// );


$wgNamespacesWithSubpages[NS_MAIN] = true;


// if ( in_array( $wikiId, [ 'eva','oso','robo','iss','issmerged' ] ) ) {

	/**
	 * Create groups for things like custom sidebar (this does not actually give
	 * any special rights), rights should be set with other groups
	 *
	 * NOTE: No spaces or '/' in group names
	 **/
	// $nasaSpecialGroups = [
		// 'ADCO',
		// 'BME',
		// 'CAPCOM',
		// 'Crew_Systems',
		// 'ETHOS',
		// 'FOD_EVA',
		// 'Flight_Director',
		// 'GC',
		// 'MAVRIC',
		// 'IMC',
		// 'ISO',
		// 'OPSPLAN',
		// 'OSO',
		// 'ROBO',
		// 'SPARTAN',
		// 'TOPO',
	// ];
	// foreach ( $nasaSpecialGroups as $groupName ) {
		// $wgGroupPermissions[ $groupName ] = [ 'viewpagescore' => true ];
	// }

// }

// let errybody see page scores
$wgGroupPermissions['user']['viewpagescore'] = true;
