# NAME

Data::Peek - A collection of low-level debug facilities

# SYNOPSIS

    use Data::Peek;

    print DDumper \%hash;    # Same syntax as Data::Dumper
    DTidy { ref => $ref };

    print DPeek \$var;
    my ($pv, $iv, $nv, $rv, $magic) = DDual ($var [, 1]);
    print DPeek for DDual ($!, 1);
    print DDisplay ("ab\nc\x{20ac}\rdef\n");
    print DHexDump ("ab\nc\x{20ac}\rdef\n");

    my $dump = DDump $var;
    my %hash = DDump \@list;
    DDump \%hash;

    my %hash = DDump (\%hash, 5);  # dig 5 levels deep

    my $dump;
    open my $fh, ">", \$dump;
    DDump_IO ($fh, \%hash, 6);
    close $fh;
    print $dump;

    # Imports
    use Data::Peek qw( :tidy VNR DGrow triplevar );
    my $x = ""; DGrow ($x, 10000);
    my $tv = triplevar ("\N{GREEK SMALL LETTER PI}", 3, "3.1415");
    DDsort ("R");
    DDumper [ $x ]; # use of :tidy makes DDumper behave like DTidy

# DESCRIPTION

Data::Peek started off as `DDumper` being a wrapper module over
[Data::Dumper](https://metacpan.org/pod/Data%3A%3ADumper), but grew out to be a set of low-level data
introspection utilities that no other module provided yet, using the
lowest level of the perl internals API as possible.

## DDumper ($var, ...)

Not liking the default output of Data::Dumper, and always feeling the need
to set `$Data::Dumper::Sortkeys = 1;`, and not liking any of the default
layouts, this function is just a wrapper around Data::Dumper::Dumper with
everything set as I like it.

    $Data::Dumper::Sortkeys = 1;
    $Data::Dumper::Indent   = 1;

If `Data::Peek` is `use`d with import argument `:tidy`, the result is
formatted according to [Perl::Tidy](https://metacpan.org/pod/Perl%3A%3ATidy), see [DTidy](https://metacpan.org/pod/DTidy) below, otherwise the
result is further beautified to meet my needs:

    * quotation of hash keys has been removed (with the disadvantage
      that the output might not be parseable again).
    * arrows for hashes are aligned at 16 (longer keys don't align)
    * closing braces and brackets are now correctly aligned

In void context, `DDumper` `warn`'s.

Example

    $ perl -MDP \
      -e'DDumper { ape => 1, foo => "egg", bar => [ 2, "baz", undef ]};'

    {   ape              => 1,
        bar              => [
            2,
            'baz',
            undef
            ],
        foo              => 'egg'
        };

## DTidy ($var, ...)

`DTidy` is an alternative to `DDumper`, where the output of `DDumper`
is formatted using `Perl::Tidy` (if available) according to your
`.perltidyrc` instead of the default behavior, maybe somewhat like (YMMV):

    $ perl -MDP=:tidy \
      -we'DDumper { ape => 1, foo => "egg", bar => [ 2, "baz", undef ]};'
    {   'ape' => 1,
        'bar' => [2, 'baz', undef],
        'foo' => 'egg'
        }

If `Data::Peek` is `use`d with import argument `:tidy`, this is the
default output method for `DDumper`.

If [Perl::Tidy](https://metacpan.org/pod/Perl%3A%3ATidy) is not available, `DTidy` will fallback to `DDumper`.

This idea was shamelessly copied from John McNamara's [Data::Dumper::Perltidy](https://metacpan.org/pod/Data%3A%3ADumper%3A%3APerltidy).

## DDsort ( 0 | 1 | R | N | NR | V | VR | VN | VNR )

Set the hash sort algorithm for DDumper. The default is to sort by key value.

    0   - Do not sort
    1   - Sort by key
    R   - Reverse sort by key
    N   - Sort by key numerical
    NR  - Sort by key numerical descending
    V   - Sort by value
    VR  - Reverse sort by value
    VN  - Sort by value numerical
    VNR - Reverse sort by value numerical

These can also be passed to import:

    $ perl -MDP=VNR \
      -we'DDumper { foo => 1, bar => 2, zap => 3, gum => 13 }'
    {   gum              => 13,
        zap              => 3,
        bar              => 2,
        foo              => 1
        };
    $ perl -MDP=V \
      -we'DDumper { foo => 1, bar => 2, zap => 3, gum => 13 }'
    {   foo              => 1,
        gum              => 13,
        bar              => 2,
        zap              => 3
        };

## DPeek

## DPeek ($var)

Playing with `sv_dump`, I found `Perl_sv_peek`, and it might be very
useful for simple checks. If `$var` is omitted, uses $\_.

Example

    print DPeek "abc\x{0a}de\x{20ac}fg";

    PV("abc\nde\342\202\254fg"\0) [UTF8 "abc\nde\x{20ac}fg"]

In void context, `DPeek` prints to `STDERR` plus a newline.

## DDisplay

## DDisplay ($var)

Show the PV content of a scalar the way perl debugging would have done.
UTF-8 detection is on, so this is effectively the same as returning the
first part the `DPeek` returns for non-UTF8 PV's or the second part for
UTF-8 PV's. `DDisplay` returns the empty string for scalars that no
have a valid PV.

Example

    print DDisplay "abc\x{0a}de\x{20ac}fg";

    "abc\nde\x{20ac}fg"

In void context, `DDisplay` uses `warn` to display the result.

## DHexDump

## DHexDump ($var)

## DHexDump ($var, $length)

Show the (stringified) content of a scalar as a hex-dump.  If `$var`
is omitted, `$_` is dumped. Returns `undef` or an empty list if
`$var` (or `$_`) is undefined. If `$length` is given and is lower than
the length of the stringified `$var`, only &lt;$length> bytes are dumped.

In void context, the dump is done to STDERR. In scalar context, the
complete dump is returned as a single string. In list context, the dump
is returned as lines.

Example

    print DHexDump "abc\x{0a}de\x{20ac}fg";

    0000  61 62 63 0a 64 65 e2 82  ac 66 67                 abc.de...fg

## my ($pv, $iv, $nv, $rv, $hm) = DDual ($var \[, $getmagic\])

DDual will return the basic elements in a variable, guaranteeing that no
conversion takes place. This is very useful for dual-var variables, or
when checking is a variable has defined entries for a certain type of
scalar. For each String (PV), Integer (IV), Double (NV), and Reference (RV),
the current value of `$var` is returned or undef if it is not set (yet).
The 5th element is an indicator if `$var` has magic, which is **not** invoked
in the returned values, unless explicitly asked for with a true optional
second argument.

Example

    print DPeek for DDual ($!, 1);

In void context, DDual does the equivalent of

    { my @d = DDual ($!, 1);
      print STDERR
        DPeek ($!), "\n",
        "  PV: ", DPeek ($d[0]), "\n",
        "  IV: ", DPeek ($d[1]), "\n",
        "  NV: ", DPeek ($d[2]), "\n",
        "  RV: ", DPeek ($d[3]), "\n";
      }

## my $len = DGrow ($pv, $size)

Fastest way to preallocate space for a PV scalar. Returns the allocated
length. If $size is smaller than the already allocated space, it will
not shrink.

    cmpthese (-2, {
        pack => q{my $x = ""; $x = pack "x20000"; $x = "";},
        op_x => q{my $x = ""; $x = "x"  x 20000;  $x = "";},
        grow => q{my $x = ""; DGrow ($x,  20000); $x = "";},
        });

              Rate  op_x  pack  grow      5.8.9    5.10.1    5.12.4    5.14.2
    op_x   62127/s    --  -59%  -96%   118606/s  119730/s  352255/s  362605/s
    pack  152046/s  145%    --  -91%   380075/s  355666/s  347247/s  387349/s
    grow 1622943/s 2512%  967%    --  2818380/s 2918783/s 2672340/s 2886787/s

## my $tp = triplevar ($pv, $iv, $nv)

When making `DDual` I wondered if it were possible to create triple-val
scalar variables. [Scalar::Util](https://metacpan.org/pod/Scalar%3A%3AUtil) already gives us `dualvar`, that creates
you a scalar with different numeric and string values that return different
values in different context. Not that `triplevar` would be very useful,
compared to `dualvar`, but at least this shows that it is possible.

`triplevar` is not exported by default.

Example:

    DDual Data::Peek::triplevar ("\N{GREEK SMALL LETTER PI}", 3, 3.1415);

    PVNV("\317\200"\0) [UTF8 "\x{3c0}"]
      PV: PV("\317\200"\0) [UTF8 "\x{3c0}"]
      IV: IV(3)
      NV: NV(3.1415)
      RV: SV_UNDEF

## DDump (\[$var \[, $dig\_level\]\])

A very useful module when debugging is `Devel::Peek`, but is has one big
disadvantage: it only prints to STDERR, which is not very handy when your
code wants to inspect variables at a low level.

Perl itself has `sv_dump`, which does something similar, but still prints
to STDERR, and only one level deep.

`DDump` is an attempt to make the innards available to the script level
with a reasonable level of compatibility. `DDump` is context sensitive.

In void context, it behaves exactly like `Perl_sv_dump`.

In scalar context, it returns what `Perl_sv_dump` would have printed.

The default for the first argument is `$_`.

In list context, it returns a hash of the variable's properties. In this mode
you can pass an optional second argument that determines the depth of digging.

Example

    print scalar DDump "abc\x{0a}de\x{20ac}fg"

    SV = PV(0x723250) at 0x8432b0
      REFCNT = 1
      FLAGS = (PADBUSY,PADMY,POK,pPOK,UTF8)
      PV = 0x731ac0 "abc\nde\342\202\254fg"\0 [UTF8 "abc\nde\x{20ac}fg"]
      CUR = 11
      LEN = 16

    my %h = DDump "abc\x{0a}de\x{20ac}fg";
    print DDumper \%h;

    {   CUR              => '11',
        FLAGS            => {
            PADBUSY          => 1,
            PADMY            => 1,
            POK              => 1,
            UTF8             => 1,
            pPOK             => 1
            },
        LEN              => '16',
        PV               => '0x731ac0 "abc\\nde\\342\\202\\254fg"\\0 [UTF8 "abc\\nde\\x{20ac}fg"]',
        REFCNT           => '1',
        sv               => 'PV(0x723250) at 0x8432c0'
        };

    my %h = DDump {
        ape => 1,
        foo => "egg",
        bar => [ 2, "baz", undef ],
        }, 1;
    print DDumper \%h;

    {   FLAGS            => {
            PADBUSY          => 1,
            PADMY            => 1,
            ROK              => 1
            },
        REFCNT           => '1',
        RV               => {
            PVIV("ape")      => {
                FLAGS            => {
                    IOK              => 1,
                    PADBUSY          => 1,
                    PADMY            => 1,
                    pIOK             => 1
                    },
                IV               => '1',
                REFCNT           => '1',
                sv               => 'IV(0x747020) at 0x843a10'
                },
            PVIV("bar")      => {
                CUR              => '0',
                FLAGS            => {
                    PADBUSY          => 1,
                    PADMY            => 1,
                    ROK              => 1
                    },
                IV               => '1',
                LEN              => '0',
                PV               => '0x720210 ""',
                REFCNT           => '1',
                RV               => '0x720210',
                sv               => 'PVIV(0x7223e0) at 0x843a10'
                },
            PVIV("foo")      => {
                CUR              => '3',
                FLAGS            => {
                    PADBUSY          => 1,
                    PADMY            => 1,
                    POK              => 1,
                    pPOK             => 1
                    },
                IV               => '1',
                LEN              => '8',
                PV               => '0x7496c0 "egg"\\0',
                REFCNT           => '1',
                sv               => 'PVIV(0x7223e0) at 0x843a10'
                }
            },
        sv               => 'RV(0x79d058) at 0x843310'
        };

## DDump\_IO ($io, $var \[, $dig\_level\])

A wrapper function around perl's internal `Perl_do_sv_dump`, which
makes `Devel::Peek` completely superfluous.

Example

    my $dump;
    open my $eh, ">", \$dump;
    DDump_IO ($eh, { 3 => 4, ape => [5..8]}, 6);
    close $eh;
    print $dump;

    SV = RV(0x79d9e0) at 0x843f00
      REFCNT = 1
      FLAGS = (TEMP,ROK)
      RV = 0x741090
        SV = PVHV(0x79c948) at 0x741090
          REFCNT = 1
          FLAGS = (SHAREKEYS)
          IV = 2
          NV = 0
          ARRAY = 0x748ff0  (0:7, 2:1)
          hash quality = 62.5%
          KEYS = 2
          FILL = 1
          MAX = 7
          RITER = -1
          EITER = 0x0
            Elt "ape" HASH = 0x97623e03
            SV = RV(0x79d9d8) at 0x8440e0
              REFCNT = 1
              FLAGS = (ROK)
              RV = 0x741470
                SV = PVAV(0x7264b0) at 0x741470
                  REFCNT = 2
                  FLAGS = ()
                  IV = 0
                  NV = 0
                  ARRAY = 0x822f70
                  FILL = 3
                  MAX = 3
                  ARYLEN = 0x0
                  FLAGS = (REAL)
                    Elt No. 0
                    SV = IV(0x7467c8) at 0x7c1aa0
                      REFCNT = 1
                      FLAGS = (IOK,pIOK)
                      IV = 5
                    Elt No. 1
                    SV = IV(0x7467b0) at 0x8440f0
                      REFCNT = 1
                      FLAGS = (IOK,pIOK)
                      IV = 6
                    Elt No. 2
                    SV = IV(0x746810) at 0x75be00
                      REFCNT = 1
                      FLAGS = (IOK,pIOK)
                      IV = 7
                    Elt No. 3
                    SV = IV(0x746d38) at 0x7799d0
                      REFCNT = 1
                      FLAGS = (IOK,pIOK)
                      IV = 8
            Elt "3" HASH = 0xa400c7f3
            SV = IV(0x746fd0) at 0x7200e0
              REFCNT = 1
              FLAGS = (IOK,pIOK)
              IV = 4

# INTERNALS

`DDump` uses an XS wrapper around `Perl_sv_dump` where the STDERR is
temporarily caught to a pipe. The internal XS helper functions are not
meant for user space

## DDump\_XS (SV \*sv)

Base interface to internals for `DDump`.

# BUGS

Windows and AIX might be using a build where not all symbols that were
supposed to be exported in the public API are not. `Perl_pv_peek` is
one of them.

Not all types of references are supported.

No idea how far back this goes in perl support, but Devel::PPPort has
proven to be a big help.

# SEE ALSO

[Devel::Peek](https://metacpan.org/pod/Devel%3A%3APeek), [Data::Dumper](https://metacpan.org/pod/Data%3A%3ADumper), [Data::Dump](https://metacpan.org/pod/Data%3A%3ADump), [Devel::Dumpvar](https://metacpan.org/pod/Devel%3A%3ADumpvar),
[Data::Dump::Streamer](https://metacpan.org/pod/Data%3A%3ADump%3A%3AStreamer), [Data::Dumper::Perltidy](https://metacpan.org/pod/Data%3A%3ADumper%3A%3APerltidy), [Perl::Tidy](https://metacpan.org/pod/Perl%3A%3ATidy).

# AUTHOR

H.Merijn Brand <hmbrand@cpan.org>

# COPYRIGHT AND LICENSE

Copyright (C) 2008-2025 H.Merijn Brand

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.
