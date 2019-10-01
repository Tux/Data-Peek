#!/pro/bin/perl

use 5.18.2;
use warnings;

use Data::Peek;
use Encode qw( from_to );

my $ascii = pack "C*" => 0..255;

DHexDump $ascii;

my $ebcdic = $ascii;
from_to ($ebcdic, "latin1", "cp1047");

DHexDump $ebcdic;

my @ascii  = unpack "C*" => $ascii;
my @ebcdic = unpack "C*" => $ebcdic;

for (0..255) {
    my $ba = $ascii[$_];
    my $be = $ebcdic[$_];
    my $ca = chr $ba;
    my $ce = chr $be;
    my $pa = $ba >= 0x20 && $ba < 0x7F ? $ca : ".";
    my $pe = $be >= 0x20 && $be < 0x7F ? $ce : ".";
    printf "%3d %02x %s %02x %s %02x %s\n",
	$_, $_, $pa, $ba, $pe, $be, $ba == $be ? "==" : "";
    }
