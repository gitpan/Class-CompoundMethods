use Test;
BEGIN { plan tests => 1; $^W = 1 }
END { ok($loaded) }
use Class::CompoundMethods qw(append_method prepend_method method_list);
$loaded++;
