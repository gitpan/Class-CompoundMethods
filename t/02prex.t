use strict;
use warnings;
use Test;
BEGIN { plan tests => 1 }
use Class::CompoundMethods 'append_method';

my $tests = '';

append_method( 'object::method', sub { $tests .= '2'; 1 } );
object->new->method;
ok( $tests eq '12' );

sub object::new { bless [], $_[0] }
sub object::method { $tests .= '1'; 1 }