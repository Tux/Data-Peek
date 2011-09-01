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

use YAML::Syck;
use JSON;

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
    print STDERR "Check required and recommended module versions ...\n";
    BEGIN { $V::NO_EXIT = $V::NO_EXIT = 1 } require V;
    my %vsn = map { m/^\s*([\w:]+):\s+([0-9.]+)$/ ? ($1, $2) : () } @yml;
    delete @vsn{qw( perl version )};
    for (sort keys %vsn) {
	$vsn{$_} eq "0" and next;
	my $v = V::get_version ($_);
	$v eq $vsn{$_} and next;
	printf STDERR "%-35s %-6s => %s\n", $_, $vsn{$_}, $v;
	}

    print STDERR "Checking generated YAML ...\n";
    use Test::YAML::Meta::Version;
    my $h;
    my $yml = join "", @yml;
    eval { $h = Load ($yml) };
    $@ and die "$@\n";
    $opt_v and print Dump $h;
    my $t = Test::YAML::Meta::Version->new (yaml => $h);
    $t->parse () and
	die join "\n", "Test::YAML::Meta reported failure:", $t->errors, "";

    use Parse::CPAN::Meta;
    eval { Parse::CPAN::Meta::Load ($yml) };
    $@ and die "$@\n";

    my $req_vsn = $h->{requires}{perl};
    print "Checking if $req_vsn is still OK as minimal version for examples\n";
    use Test::MinimumVersion;
    # All other minimum version checks done in xt
    all_minimum_version_ok ($req_vsn, { paths => [ "examples" ]});
    }
elsif ($opt_v) {
    print @yml;
    }
else {
    my @my = glob <*/META.yml>;
    my $yf = $my[0];
    @my == 1 && open my $my, ">", $yf or die "Cannot update $yf\n";
    print $my @yml;
    close $my;

    $yf =~ s/yml$/json/;
    my $jsn = Load ("@yml");
    $jsn->{"meta-spec"} = {
	version	=> "2.0",
	url	=> "https://metacpan.org/module/CPAN::Meta::Spec?#meta-spec",
	};
    open $my, ">", $yf or die "Cannot update $yf\n";
    print $my JSON->new->utf8 (1)->pretty (1)->encode ($jsn);

    chmod 0644, glob "*/META.*";
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
