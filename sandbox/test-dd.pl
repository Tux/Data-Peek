#!/pro/bin/perl

use strict;
use warnings;

use Data::Dumper;

sub DDumper
{
    my ($f, @a) = @_;

#   $Data::Dumper::Sortkeys  = $_sortkeys;
    $Data::Dumper::Indent    = $f & 0x01;
    $Data::Dumper::Quotekeys = $f & 0x02;
#   $Data::Dumper::Deparse   = $f & 0x04;
    $Data::Dumper::Terse     = $f & 0x08;
#   $Data::Dumper::Useqq     = $f & 0x10;

    printf "0x%02x\n", $f;
    my $s = Data::Dumper::Dumper @_;
    return $s;
    } # DDumper

my %hash = (
    SV  => 1,
    GLB => *STDERR,
    IO  => *{$::{STDERR}}{IO},
    FMT => *{$::{STDOUT}}{FORMAT},
    );

DDumper $_, \%hash for 0 .. 0x1f;
