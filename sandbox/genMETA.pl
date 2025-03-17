#!/pro/bin/perl

use strict;
use warnings;

use Getopt::Long qw(:config bundling nopermute);
GetOptions (
    "c|check"		=> \ my $check,
    "u|update!"		=> \ my $update,
    "v|verbose:1"	=> \(my $opt_v = 0),
    ) or die "usage: $0 [--check]\n";

use lib "sandbox";
use genMETA;
my $meta = genMETA->new (
    from    => "Peek.pm",
    verbose => $opt_v,
    );

$meta->from_data (<DATA>);
$meta->security_md ($update);
$meta->gen_cpanfile ();

if ($check) {
    $meta->check_encoding ();
    $meta->check_required ();
    $meta->check_minimum ([ "examples" ]);
    $meta->done_testing ();
    }
elsif ($opt_v) {
    $meta->print_yaml ();
    }
else {
    $meta->fix_meta ();
    }

__END__
--- #YAML:1.0
name:                    Data-Peek
version:                 VERSION
abstract:                Modified and extended debugging facilities
license:                 perl
author:
    - H.Merijn Brand <hmbrand@cpan.org>
generated_by:            Author
distribution_type:       module
provides:
    Data::Peek:
        file:            Peek.pm
        version:         VERSION
requires:
    perl:                5.008001
    XSLoader:            0
    Data::Dumper:        0
configure_requires:
    ExtUtils::MakeMaker: 0
configure_recommends:
    ExtUtils::MakeMaker: 7.22
configure_suggests:
    ExtUtils::MakeMaker: 7.72
build_requires:
    perl:                5.008001
test_requires:
    Test::More:          0.90
    Test::Warnings:      0
recommends:
    Data::Dumper:        2.189
    Perl::Tidy:          0
test_recommends:
    Test::More:          1.302209
resources:
    license:             http://dev.perl.org/licenses/
    repository:          https://github.com/Tux/Data-Peek
    bugtracker:          https://github.com/Tux/Data-Peek/issues
    IRC:                 irc://irc.perl.org/#csv
meta-spec:
    version:             1.4
    url:                 http://module-build.sourceforge.net/META-spec-v1.4.html
