<?php

// Below are namespaces which Extension:ApprovedRevs enables for approvals by
// default. NASA wikis do not want entire namespaces requiring approvals. As
// such, disable all of them explicitly.
$egApprovedRevsEnabledNamespaces = [
	NS_MAIN     => false,
	NS_USER     => false,
	NS_PROJECT  => false,
	NS_TEMPLATE => false,
	NS_HELP     => false,
	NS_FILE     => false,
];
