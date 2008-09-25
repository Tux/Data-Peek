#!/bin/sh

for p in perl5.6.2 \
	 perl5.8.0  perl5.8.7 perl5.8.8 \
	 perl5.10.0 perl5.10.x \
	 bleadperl ; do

    ( $p Makefile.PL
      make
      ) >/dev/null 2>&1

    ( echo 'format foo ='
      echo '.'
      echo 'print " $]  \t", q(*foo{FORMAT}:), DPeek (*foo{FORMAT});'
      ) > test.pl
    $p -Iblib/lib -Iblib/arch -MDDumper -l test.pl
    rm test.pl

    ( make distclean
      ) >/dev/null 2>&1
    done
