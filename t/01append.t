use strict;
BEGIN { $^W = 1 }
use Test;
BEGIN { plan tests => 4 }
use Class::CompoundMethods 'append_method';
use vars '$tests';

sub by_qname { $tests .= '1'; }
sub by_name { $tests .= '2'; }
my $by_ref = sub { $tests .= '3'; };
my $o = Object->new;

append_method( 'Object::method', __PACKAGE__.'::by_qname' );
$tests = '';
$o->method;
ok( $tests eq '1' );

append_method( 'Object::method', 'by_name' );
$tests = '';
$o->method;
ok( $tests eq '12' );

append_method( 'Object::method', $by_ref );
$tests = '';
$o->method;
ok( $tests eq '123' );

{
    package Object;
    ::append_method( 'method', sub { $::tests .= '4' } );
    $::tests = '';
    $o->method;
    ::ok( $::tests eq '1234' );
}

sub Object::new { bless [], $_[0] }
