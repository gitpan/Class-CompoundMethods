use strict;
BEGIN { $^W = 1 }
use Test;
BEGIN { plan tests => 1 }
use Class::CompoundMethods 'prepend_method';

my $tests = '';

prepend_method( 'Object::method', sub { $tests .= '2'; 1 } );
Object->new->method;
ok( $tests eq '21' );

sub Object::new { bless [], $_[0] }
sub Object::method { $tests .= '1'; 1 }