use strict;
BEGIN { $^W = 1 }
use Test;
BEGIN { plan tests => 1 }
use Class::CompoundMethods 'append_method';

my $tests = '';

append_method( 'Object::method', sub { $tests .= '2'; 1 } );
Object->new->method;
ok( $tests eq '12' );

sub Object::new { bless [], $_[0] }
sub Object::method { $tests .= '1'; 1 }