#!/usr/bin/perl -w

use strict;
use lib 't/lib';

use Test::More tests => 30;

use File::Spec;

use TAP::Parser::Source;
use TAP::Parser::Source::Perl;

my $test = File::Spec->catfile( 't', 'source_tests', 'source' );

my $perl = $^X;

can_ok 'TAP::Parser::Source', 'new';
my $source = TAP::Parser::Source->new;
isa_ok $source, 'TAP::Parser::Source';

can_ok $source, 'source';
eval { $source->source("$perl -It/lib $test") };
ok my $error = $@, '... and calling it with a string should fail';
like $error, qr/^Argument to &source must be an array reference/,
  '... with an appropriate error message';
ok $source->source( [ $perl, '-It/lib', '-T', $test ] ),
  '... and calling it with valid args should succeed';

can_ok $source, 'get_stream';
my $stream = $source->get_stream;

isa_ok $stream, 'TAP::Parser::Iterator::Process',
  'get_stream returns the right object';
can_ok $stream, 'next';
is $stream->next, '1..1', '... and the first line should be correct';
is $stream->next, 'ok 1', '... as should the second';
ok !$stream->next, '... and we should have no more results';

can_ok 'TAP::Parser::Source::Perl', 'new';
$source = TAP::Parser::Source::Perl->new;
isa_ok $source, 'TAP::Parser::Source::Perl', '... and the object it returns';

can_ok $source, 'source';
ok $source->source( [$test] ),
  '... and calling it with valid args should succeed';

can_ok $source, 'get_stream';
$stream = $source->get_stream;

isa_ok $stream, 'TAP::Parser::Iterator::Process',
  '... and the object it returns';
can_ok $stream, 'next';
is $stream->next, '1..1', '... and the first line should be correct';
is $stream->next, 'ok 1', '... as should the second';
ok !$stream->next, '... and we should have no more results';

# internals tests!

can_ok $source, '_switches';
ok( grep( $_ =~ /^['"]?-T['"]?$/, $source->_switches ),
    '... and it should find the taint switch'
);

# coverage test for TAP::PArser::Source

{

    # coverage for method get_steam

    my $source = TAP::Parser::Source->new();

    my @die;

    eval {
        local $SIG{__DIE__} = sub { push @die, @_ };

        $source->get_stream;
    };

    is @die, 1, 'coverage testing of get_stream';

    like pop @die, qr/No command found!/, '...and it failed as expect';
}

{

    # coverage testing for error

    my $source = TAP::Parser::Source->new();

    my $error = $source->error;

    is $error, undef, 'coverage testing for error()';

    $source->error('save me');

    $error = $source->error;

    is $error, 'save me', '...and we got the expected message';
}

{

    # coverage testing for exit

    my $source = TAP::Parser::Source->new();

    my $exit = $source->exit;

    is $exit, undef, 'coverage testing for exit()';

    $source->exit('save me');

    $exit = $source->exit;

    is $exit, 'save me', '...and we got the expected message';
}
