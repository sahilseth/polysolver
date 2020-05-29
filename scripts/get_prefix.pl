#!/usr/bin/perl

$t=$ARGV[0];

@f = split(/\//,$t);

$t1 = $f[$#f];

$index = index($t1,".tar.gz");

$t2 = substr($t1,0,$index);

print "$t2";

