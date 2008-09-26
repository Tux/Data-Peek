#!/pro/bin/perl

use strict;
use warnings;

BEGIN { unshift @INC, qw( blib/lib blib/arch ) }

use DDumper;
use Data::Dumper;
   $Data::Dumper::Sortkeys = 1;
   $Data::Dumper::Indent   = 1;

my ($use_perlio, $dump_hash) = (@ARGV, 0, 0);
$dump_hash or $DDumper::has_perlio = $DDumper::has_perlio = $use_perlio;

my $var = "";
foreach my $ref ("", "\\") {
    foreach my $in (
	    'undef', 0, 1,
	    '""', '"\xa8"', '"ab\x0a\x{20ac}"',
	    ) {
	eval "\$var = $ref$in;";
	my $dump;
	if ($dump_hash) {
	    my %hash = DDump  ($var);
	       $dump = Dumper (\%hash);
	    }
	else {
	       $dump = DDump  ($var);
	    }
	$dump =~ s/\b0x[0-9a-f]+\b/0x****/g;
	$dump =~ s/\bab(\\n|\\12|n)/ab\\n/g;
	$dump =~ s/\b(REFCNT'?\s+=>?\s*) ('?)[0-9]{4,}\2/$1 $2-1$2/g;
	print "$ref$in\n--\n$dump==\n";
	}
    }
