#!/pro/bin/perl

use strict;
use warnings;

use Getopt::Long qw(:config bundling nopermute);
my $check = 0;
my $opt_v = 0;
GetOptions (
    "c|check"		=> \$check,
    "v|verbose:1"	=> \$opt_v,
    ) or die "usage: $0 [--check]\n";

my $version;
open my $pm, "<", "Peek.pm" or die "Cannot read Peek.pm";
while (<$pm>) {
    m/^.VERSION\s*=\s*"?([-0-9._]+)"?\s*;\s*$/ or next;
    $version = $1;
    last;
    }
close $pm;

my @yml;
while (<DATA>) {
    s/VERSION/$version/o;
    push @yml, $_;
    }

if ($check) {
    use YAML::Syck;
    use Test::YAML::Meta::Version;
    my $h;
    my $yml = join "", @yml;
    eval { $h = Load ($yml) };
    $@ and die "$@\n";
    $opt_v and print Dump $h;
    my $t = Test::YAML::Meta::Version->new (yaml => $h);
    $t->parse () and die join "\n", $t->errors, "";

    use Parse::CPAN::Meta;
    eval { Parse::CPAN::Meta::Load ($yml) };
    $@ and die "$@\n";

    print "Checking if 5.008 is still OK as minimal version for examples\n";
    use Test::MinimumVersion;
    # All other minimum version checks done in xt
    all_minimum_version_ok ("5.008", { paths => [ "examples" ]});
    }
elsif ($opt_v) {
    print @yml;
    }
else {
    my @my = glob <*/META.yml>;
    @my == 1 && open my $my, ">", $my[0] or die "Cannot update META.yml\n";
    print $my @yml;
    close $my;
    chmod 0644, glob <*/META.yml>;
    }

__END__
--- #YAML:1.0
name:                    Data::Peek
version:                 VERSION
abstract:                Modified and extended debugging facilities
license:                 perl
author:              
    - H.Merijn Brand <h.m.brand@xs4all.nl>
generated_by:            Author
distribution_type:       module
provides:
    Data::Peek:
        file:            Peek.pm
        version:         VERSION
requires:     
    perl:                5.008
    DynaLoader:          0
    Data::Dumper:        0
recommends:
    perl:                5.014001
    Perl::Tidy:          0
    Test::More:          0.98
configure_requires:
    ExtUtils::MakeMaker: 0
build_requires:
    perl:                5.008
test_requires:
    Test::Harness:       0
    Test::More:          0.88
    Test::NoWarnings:    0
resources:
    license:             http://dev.perl.org/licenses/
    repository:          http://repo.or.cz/w/Data-Peek.git
meta-spec:
    version:             1.4
    url:                 http://module-build.sourceforge.net/META-spec-v1.4.html
