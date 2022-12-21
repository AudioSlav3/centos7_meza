<?php
$filename = $argv[1];
$wiki = $argv[2];

echo "Filename: $filename\n";
echo "Wiki: $wiki\n";

if ( php_sapi_name() !== 'cli' ) {
    echo "This script is only accessible via command line";
    exit();
}

 $original = $filename;

//
// Do some checks to make sure everything passed correctly.
//

//
// Create temp directory 

echo "Creating directory $wiki\n";
echo shell_exec( "mkdir $wiki" );

echo "Creating logo...\n";
echo shell_exec( "convert $original -resize 160x160 $wiki/logo.png" );

echo "Creating favicon...\n";
echo shell_exec( "convert $wiki/logo.png  -bordercolor white -border 0 " .
 // "-clone 0 -resize 16x16 " .
 // "-clone 0 -resize 24x24 " .
 // "-clone 0 -resize 32x32 " .
 // "-clone 0 -resize 48x48 " .
 // "-clone 0 -resize 64x64 " .
 // "-clone 0 -resize 72x72 " .
 "-clone 0 -resize 128x128 " .
 "-delete 0 -alpha off -colors 256 $wiki/favicon.ico" );
 ?>