requires   "Data::Dumper";
requires   "XSLoader";

recommends "Data::Dumper"             => "2.192";
recommends "Perl::Tidy"               => "20170521";

suggests   "Perl::Tidy"               => "20260826";

on "configure" => sub {
    requires   "ExtUtils::MakeMaker";

    recommends "ExtUtils::MakeMaker"      => "7.22";

    suggests   "ExtUtils::MakeMaker"      => "7.78";
    };

on "test" => sub {
    requires   "Test::More"               => "0.90";
    requires   "Test::Warnings";

    recommends "Test::More"               => "1.302224";
    };
