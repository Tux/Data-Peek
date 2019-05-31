requires	"Data::Dumper";
requires	"DynaLoader";

recommends	"Data::Dumper",	"2.174";
recommends	"Perl::Tidy";

on "configure" => sub {
    requires	"ExtUtils::MakeMaker";
    };

on "test" => sub {
    requires	"Test::More";
    requires	"Test::Warnings";

    recommends	"Test::More",	"1.302164";
    };
