#!/usr/bin/perl

# Copyright PROCURA B.V. (c) 2008-2008 H.Merijn Brand

require 5.006; # <- also see postamble at the bottom for META.yml
use strict;

use ExtUtils::MakeMaker;

my %wm = (
    NAME         => "DDumper",
    ABSTRACT     => "Extended/Modified debugging utilities",
    AUTHOR       => "H.Merijn Brand <h.merijn\@xs4all.nl>",
    VERSION_FROM => "DDumper.pm",
    PREREQ_PM	 => { "DynaLoader"	=> 0,
		      "Data::Dumper"	=> 0,
		      "Test::More"	=> 0,
		      "Test::Harness"	=> 0,
		      },
    clean        => { FILES => join " ", qw(
			 Ddumper.c.gcov
			 Ddumper.gcda
			 Ddumper.gcno
			 Ddumper.xs.gcov
			 cover_db
			 valgrind.log
			 )
		      },
    );
$ExtUtils::MakeMaker::VERSION > 6.30 and $wm{LICENSE} = "perl";

my $rv = WriteMakefile (%wm);

1;

package MY;

sub postamble
{
    my $valgrind = join " ", qw(
	PERL_DESTRUCT_LEVEL=2 PERL_DL_NONLAZY=1
	    valgrind
		--suppressions=sandbox/perl.supp
		--leak-check=yes
		--leak-resolution=high
		--show-reachable=yes
		--num-callers=50
		--log-fd=3
		$(FULLPERLRUN) "-MExtUtils::Command::MM" "-e"
		    "test_harness($(TEST_VERBOSE), '$(INST_LIB)', '$(INST_ARCHLIB)')"
		    $(TEST_FILES) 3>valgrind.log
		    );

    my $min_vsn = ($] >= 5.010 && -d "xt" && ($ENV{AUTOMATED_TESTING} || 0) != 1)
	? join "\n" =>
	    'test ::',
	    '	-@env TEST_FILES="xt/*.t" make -e test_dynamic',
	    ''
	: "";
    join "\n" =>
	'cover test_cover:',
	'	ccache -C',
	'	cover -test',
	'',
	'leakcheck:',
	"	$valgrind",
	'	-@tail -5 valgrind.log',
	'',
	'leaktest:',
	q{	sandbox/leaktest $(FULLPERLRUN) "test_harness($(TEST_VERBOSE), '$(INST_LIB)', '$(INST_ARCHLIB)')" $(TEST_FILES)},
	'',
	'checkmeta:',
	'	perl sandbox/genMETA.pl -c',
	'',
	'fixmeta:	distmeta',
	'	perl sandbox/genMETA.pl',
	'',
	'tgzdist:	checkmeta fixmeta $(DISTVNAME).tar.gz distcheck',
	'	-@mv -f $(DISTVNAME).tar.gz $(DISTVNAME).tgz',
	'	-@cpants_lint.pl $(DISTVNAME).tgz',
	'	-@rm -f Debian_CPANTS.txt',
	'',
	$min_vsn;
    } # postamble
