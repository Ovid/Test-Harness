#!/usr/bin/perl -w

use strict;
use lib 't/lib';

use Test::More tests => 1;

use Dev::Null;

use Test::Harness;

sub _all_ok {
    my ($tot) = shift;
    return $tot->{bad} == 0
      && ( $tot->{max} || $tot->{skipped} ) ? 1 : 0;
}

{
    local $ENV{PERL_TEST_HARNESS_DUMP_TAP} = 0;

    push @INC, 'examples';

    tie *NULL, 'Dev::Null' or die $!;
    select NULL;
    my ( $tot, $failed ) = Test::Harness::execute_tests(
        tests => [
            $ENV{PERL_CORE}
            ? 'lib/sample-tests/inc_taint'
            : 't/sample-tests/inc_taint'
        ]
    );
    select STDOUT;

    ok( _all_ok($tot), 'tests with taint on preserve @INC' );
}