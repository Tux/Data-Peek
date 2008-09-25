/*  Copyright (c) 2007-2008 H.Merijn Brand.  All rights reserved.
 *  This program is free software; you can redistribute it and/or
 *  modify it under the same terms as Perl itself.
 */

#include <EXTERN.h>
#include <perl.h>
#include <XSUB.h>
#include "ppport.h"

SV *_DDump (SV *sv)
{
    int   err[3], n;
    char  buf[128];
    SV   *dd;
    dTHX;

    if (pipe (err)) return (NULL);

    dd = sv_newmortal ();
    err[2] = dup (2);
    close (2);
    if (dup (err[1]) == 2)
	Perl_sv_dump (aTHX_ sv);
    close (err[1]);
    close (2);
    err[1] = dup (err[2]);
    close (err[2]);

    Perl_sv_setpvn (aTHX_ dd, "", 0);
    while ((n = read (err[0], buf, 128)) > 0)
#if PERL_VERSION >= 8
	/* perl 5.8.0 did not export Perl_sv_catpvn */
	Perl_sv_catpvn_flags (aTHX_ dd, buf, n, SV_GMAGIC);
#else
	Perl_sv_catpvn       (aTHX_ dd, buf, n);
#endif
    return (dd);
    } /* _DDump */

MODULE = DDumper		PACKAGE = DDumper

PROTOTYPES: DISABLE

void
DPeek (sv)
    SV   *sv

  PPCODE:
    ST (0) = newSVpv (Perl_sv_peek (aTHX_ sv), 0);
    XSRETURN (1);
    /* XS DPeek */

void
DDump_XS (sv)
    SV   *sv

  PPCODE:
    SV   *dd = _DDump (sv);

    if (dd) {
	ST (0) = dd;
	XSRETURN (1);
	}

    XSRETURN (0);
    /* XS DDump */

#if PERL_VERSION >= 8

void
DDump_IO (io, sv, level)
    PerlIO *io
    SV     *sv
    IV      level

  PPCODE:
    Perl_do_sv_dump (aTHX_ 0, io, sv, 1, level, 1, 0);
    XSRETURN (1);
    /* XS DDump */

#endif
