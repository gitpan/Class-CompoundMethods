use strict;
BEGIN { $^W = 1 }
use Test;
BEGIN { plan tests => 2 }
use Class::CompoundMethods qw(append_method method_list);
use vars '$tests';

sub by_qname { 1 }
sub by_name { 1 }
my $by_ref = sub { 1 };

sub object::method { 1 }
append_method( 'object::method', __PACKAGE__.'::by_qname' );
append_method( 'object::method', 'by_name' );
append_method( 'object::method', $by_ref );

my $m = method_list('object::method');
ok( 4 == @$m );
ok( 4 == grep UNIVERSAL::isa($_,'CODE'), @$m );
