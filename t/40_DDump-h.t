#!/usr/bin/perl

use strict;
use warnings;

use Test::More tests => 1;

BEGIN {
    use_ok "DDumper";
    plan skip_all => "Cannot load DDumper" if $@;
    }

1;
