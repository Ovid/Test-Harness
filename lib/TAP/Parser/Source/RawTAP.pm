package TAP::Parser::Source::RawTAP;

use strict;
use vars qw($VERSION @ISA);

use TAP::Parser::Source ();
use TAP::Parser::IteratorFactory ();

@ISA = qw(TAP::Parser::Source);

=head1 NAME

TAP::Parser::Source::RawTAP - Stream output from raw TAP in a scalar ref.

=head1 VERSION

Version 3.18

=cut

$VERSION = '3.18';

=head1 SYNOPSIS

  use TAP::Parser::Source::RawTAP;
  my $source = TAP::Parser::Source::RawTAP->new;
  my $stream = $source->source (\"1..1\nok 1\n" )->get_stream;

=head1 DESCRIPTION

Takes raw TAP and converts into an iterator.

=head1 METHODS

=head2 Class Methods

=head3 C<new>

 my $source = TAP::Parser::Source::RawTAP->new;

Returns a new C<TAP::Parser::Source::RawTAP> object.

=cut

# new() implementation supplied by parent class

##############################################################################

=head2 Instance Methods

=head3 C<raw_source>

 my $raw_source = $source->raw_source;
 $source->raw_source( \$raw_tap );

Getter/setter for the raw_source.  C<croaks> if it doesn't get a scalar or
array ref.

=cut

sub raw_source {
    my $self = shift;
    if ( @_ ) {
	my $ref = ref $_[0];
	if (! defined( $ref )) {
	    ; # fall through
	} elsif ($ref eq 'SCALAR') {
	    my $scalar_ref = shift;
	    return $self->SUPER::raw_source([ split "\n" => $$scalar_ref ]);
	} elsif ($ref eq 'ARRAY') {
	    return $self->SUPER::raw_source( shift );
	}
	$self->_croak('Argument to &raw_source must be a scalar or array reference');
    }
    return $self->SUPER::raw_source;
}

##############################################################################

=head3 C<get_stream>

 my $stream = $source->get_stream( $iterator_maker );

Returns a L<TAP::Parser::Iterator> for this TAP stream.

=cut

sub get_stream {
    my ( $self, $factory ) = @_;
    return $factory->make_iterator( $self->raw_source );
}

1;

=head1 SUBCLASSING

Please see L<TAP::Parser/SUBCLASSING> for a subclassing overview.

=head1 SEE ALSO

L<TAP::Object>,
L<TAP::Parser>,
L<TAP::Parser::Source>,
L<TAP::Parser::Source::Executable>,
L<TAP::Parser::Source::Perl>

=cut