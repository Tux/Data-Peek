#!/usr/bin/perl

use strict;
$^W = 1;	# use warnings core since 5.6

use Test::More tests => 1;

BEGIN {
    use_ok "DDumper";
    plan skip_all => "Cannot load DDumper" if $@;
    }

1;
