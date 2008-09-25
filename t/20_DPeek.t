#!/usr/bin/perl

use strict;
use warnings;

#use Test::More tests => 1;
 use Test::More "no_plan";

BEGIN {
    use_ok "DDumper";
    plan skip_all => "Cannot load DDumper" if $@;
    }

$| = 1;
undef $,;	# Some test suite might have changed it

is (DPeek ($/),		'PVMG("\n"\0)',		'$/');
is (DPeek ($\),		'PVMG()',		'$\\');
is (DPeek ($.),		'PVMG()',		'$.');
is (DPeek ($,),		'PVMG()',		'$,');
is (DPeek ($;),		'PV("\34"\0)',		'$;');
is (DPeek ($"),		'PV(" "\0)',		'$"');
is (DPeek ($:),		'PVMG(" \n-"\0)',	'$:');
is (DPeek ($~),		'PVMG()',		'$~');
is (DPeek ($^),		'PVMG()',		'$^');
is (DPeek ($=),		'PVMG()',		'$=');
is (DPeek ($-),		'PVMG()',		'$-');
is (DPeek ($!),		'PVMG(""\0)',		'$!');
is (DPeek ($?),		'PVMG()',		'$?');
is (DPeek ($|),		'PVMG(1)',		'$|');

"abc" =~ m/(b)/;	# Don't know why these magic vars have this content
is (DPeek ($1),		'PVMG("$"\0)',		' $1');
is (DPeek ($`),		'PVMG()',		' $`');
is (DPeek ($&),		'PVMG()',		' $&');
is (DPeek ($'),		'PVMG()',		" \$'");

is (DPeek (undef),	'SV_UNDEF',		'undef');
is (DPeek (1),		'IV(1)',		'constant 1');
is (DPeek (""),		'PV(""\0)',		'constant ""');
is (DPeek (1.),		'NV(1)',		'constant 1.');
is (DPeek (\1),		'\IV(1)',		'constant \1');
is (DPeek (\\1),	'\\\IV(1)',		'constant \\\1');

is (DPeek (\@ARGV),	'\AV()',		'\@ARGV');
is (DPeek (\@INC),	'\AV()',		'\@INC');
is (DPeek (\%INC),	'\HV()',		'\%INC');
is (DPeek (*STDOUT),	'GV()',			'*STDOUT');
is (DPeek (sub {}),	'\CV(__ANON__)',	'sub {}');

{ our ($VAR, @VAR, %VAR);
  open VAR, ">VAR.txt";
  sub VAR {}
  format VAR =
.
  END { unlink "VAR.txt" };

  is (DPeek ( $VAR),	'UNDEF',		' $VAR undef');
  is (DPeek (\$VAR),	'\UNDEF',		'\$VAR undef');
  $VAR = 1;
  is (DPeek ($VAR),	'IV(1)',		' $VAR 1');
  is (DPeek (\$VAR),	'\IV(1)',		'\$VAR 1');
  $VAR = "";
  is (DPeek ($VAR),	'PVIV(""\0)',		' $VAR ""');
  is (DPeek (\$VAR),	'\PVIV(""\0)',		'\$VAR ""');
  $VAR = "\xa8";
  is (DPeek ($VAR),	'PVIV("\250"\0)',	' $VAR "\xa8"');
  is (DPeek (\$VAR),	'\PVIV("\250"\0)',	'\$VAR "\xa8"');
  SKIP: {
      $] <= 5.008001 and skip "UTF8 tests useless in this ancient perl version", 1;
      $VAR = "a\x0a\x{20ac}";
      like (DPeek ($VAR), qr'PVIV\("a\\(?:n|12)\\342\\202\\254"\\0\) \[UTF8 "a\\?n\\x{20ac}"\]',
						  ' $VAR "a\x0a\x{20ac}"');
      }
  $VAR = sub { "VAR" };
  is (DPeek ($VAR),	'\CV(__ANON__)',	' $VAR sub { "VAR" }');
  is (DPeek (\$VAR),	'\\\CV(__ANON__)',	'\$VAR sub { "VAR" }');
  $VAR = 0;

  is (DPeek (\&VAR),	'\CV(VAR)',		'\&VAR');
  is (DPeek ( *VAR),	'GV()',			' *VAR');

  is (DPeek (*VAR{GLOB}),	'\GV()',	' *VAR{GLOB}');
  is (DPeek (*VAR{SCALAR}),	'\PVIV(0)',	' *VAR{SCALAR}');
  is (DPeek (*VAR{ARRAY}),	'\AV()',	' *VAR{ARRAY}');
  is (DPeek (*VAR{HASH}),	'\HV()',	' *VAR{HASH}');
  is (DPeek (*VAR{CODE}),	'\CV(VAR)',	' *VAR{CODE}');
  is (DPeek (*VAR{IO}),		'\IO()',	' *VAR{IO}');
  is (DPeek (*VAR{FORMAT}),$]<5.008?'SV_UNDEF':'\FM()',' *VAR{FORMAT}');
  }

1;
