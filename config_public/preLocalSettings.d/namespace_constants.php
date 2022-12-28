<?php

/**
 * Define constants for namespaces ACROSS ALL WIKIS even if the namespace is
 * ONLY USED ON SOME WIKIS. This is to prevent conflicts if a wiki ever wants
 * to have the same namespace as another wiki or if wikis merge.
 *
 * The new namespace MUST be an even integer. Its corresponding talk (AKA
 * discussion) namespace MUST be the following odd integer.
 *
 **/
 
// Define constants for my additional namespaces.
define("NS_ACCESSCONTROLGROUP", 730); // This MUST be even.
define("NS_ACCESSCONTROLGROUP_TALK", 731); // This MUST be the following odd integer.

// Console Handbook
define( "NS_CHB", 3000 );
define( "NS_CHB_TALK", 3001 );

// Some other Handbook
define( "NS_HB", 3002 );
define( "NS_HB_TALK", 3003 );

// KB namespace
define( "NS_KB", 4200 );
define( "NS_KB_TALK", 4201 );

// IR namespace
define( "NS_IR", 4202 );
define( "NS_IR_TALK", 4203 );

// PAR namespace
define( "NS_PAR", 4204 );
define( "NS_PAR_TALK", 4205 );

// FR namespace
define( "NS_FR", 4206 );
define( "NS_FR_TALK", 4207 );

// SODF namespace
define( "NS_SODF", 4208 );
define( "NS_SODF_TALK", 4209 );

// PODF namespace
define( "NS_PODF", 4210 );
define( "NS_PODF_TALK", 4211 );

// Action namespace
define( "NS_ACTION", 4212 );
define( "NS_ACTION_TALK", 4213 );

// Label namespace
define( "NS_LABEL", 4214 );
define( "NS_LABEL_TALK", 4215 );

// RoundTable namespaces for wikidump
define( "NS_ROUNDTABLE_LOG", 8080 );
define( "NS_ROUNDTABLE_LOG_TALK", 8081 );

define( "NS_ROUNDTABLE_ACTION_ITEM", 8082 );
define( "NS_ROUNDTABLE_ACTION_ITEM_TALK", 8083 );

define( "NS_ROUNDTABLE_TAKEAWAY", 8084 );
define( "NS_ROUDNTABLE_TAKEAWAY_TALK", 8085 );

define( "NS_ROUNDTABLE_FAILURE", 8086 );
define( "NS_ROUDNTABLE_FAILURE_TALK", 8087 );
