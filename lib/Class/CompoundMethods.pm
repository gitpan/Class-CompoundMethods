package Class::CompoundMethods;

use 5.006;
use strict;
use warnings;
use vars qw(@ISA @EXPORT_OK $VERSION %METHODS);

require Exporter;

@ISA = qw(Exporter);
@EXPORT_OK = qw(append_method prepend_method method_list);
$VERSION = '0.01';

sub method_list {
    my $method_name = shift;
    return () unless exists $METHODS{$method_name};
    return $METHODS{$method_name}{'targets'};
}

sub prepend_method {
    my $method_name = shift;
    my $method_to_install = shift;

    return x_method(
        method_name => $method_name,
        method_to_install  => $method_to_install,
	add_method => sub { unshift @{$_[0]}, $_[1] },
        existing_method => sub { unshift @{$_[0]}, $_[1] } );
}

sub append_method {
    my $method_name = shift;
    my $method_to_install = shift;

    return x_method(
        method_name => $method_name,
        method_to_install  => $method_to_install,
	add_method => sub { push @{$_[0]}, $_[1] },
        existing_method => sub { unshift @{$_[0]}, $_[1] } );
}

sub x_method {
    my %p = @_;
    my $method_name = $p{'method_name'};
    my $method_to_install = $p{'method_to_install'};
    my $add_method = $p{'add_method'};
    my $existing_method = $p{'existing_method'};
    no strict 'refs';
    no warnings 'redefine';

    # If the method name isn't qualified then I assume it exists in the
    # caller's package.
    unless ($method_name =~ /::/) {
        $method_name = caller(1) . "::$method_name";
    }

    # If I was given a method name then fetch the code
    # reference from the named slot
    unless (ref $method_to_install ) {
        # If the method is not qualified with a package name then grab the
        # method from the caller's own package.
        unless ($method_to_install =~ /::/) {
            $method_to_install = caller(1) . "::$method_to_install";
        }
        
        # symref
        $method_to_install = \&{$method_to_install};
    }

    # Track the list of references to install
    unless (exists $METHODS{$method_name}) {
        $METHODS{$method_name} = { targets => [],
                                   hook    => undef };
    }
    my $methods_to_call = $METHODS{$method_name}{'targets'};
    my $hook_method     = $METHODS{$method_name}{'hook'};

    # If the pre-existing method isn't in the local cache then copy it over
    # first. (be sure to ignore the hook method too)
    if (*{$method_name}{CODE} and
        not( grep $_ == *{$method_name}{CODE},
             grep defined(), @$methods_to_call, $hook_method ) ) {
        $existing_method->( $methods_to_call, *{$method_name}{CODE} );
    }

    $add_method->( $methods_to_call, $method_to_install );

    # Install the new methods
    if (*{$method_name}{CODE}) {
        # Already existing method
        *{$method_name} = sub {
            $_[0]->$_( @_[1 .. $#_] ) for @$methods_to_call;
        };
    } else {
        # Single method - no special calling
        *{$method_name} = $method_to_install;
    }

    # Keep a copy of the installed hook so it can be ignored later.
    $METHODS{$method_name}{'hook'} = *{$method_name}{CODE};

    # Return the method as a convenience (for who knows what, I don't know)
    return *{$method_name}{CODE};
}

1;
__END__

=head1 NAME

Class::CompoundMethods - Create methods from components

=head1 SYNOPSIS

  use Class::CompoundMethods 'append_method';

  # This installs both versioning_hook and auditing_hook into the
  # method Object::pre_insert.
  for my $hook (qw(versioning auditing)) {
      append_method( 'Object::pre_insert', "${hook}_hook" );
  }

  sub versioning_hook { ... }
  sub auditing_hook { ... }

=head1 DESCRIPTION

This allows you to install more than one method into a single method name.
I created this so I could install both versioning and auditing hooks into
another module's object space. So instead of creating a single larger method
which incorporates the functionality of both hooks I created
C<Class::CompoundMethods::append_method> to install a wrapper method as needed.

If only one method is ever installed into a space, it is installed directly
with no wrapper. If you install more than one then C<append_method> creates a
wrapper which calls each of the specified methods in turn.

=head1 PUBLIC METHODS

=over 4

=item append_method

 append_method( $method_name, $method );                

This function takes two parameters - the fully qualified name of the method
to install into and the method to install.

C<$method_name> must be the fully qualified method name. This means that for
the method C<pre_insert> of a C<Foo::Bar> object you must pass in

C<'Foo::Bar::pre_insert'>.

C<$method> may be either a code reference or the fully qualified name of the
method to use.

=back

=head2 EXAMPLES

=over 4

=item Example 1

 use Class::CompoundMethods 'append_method';

 # This installs both versioning_hook and auditing_hook into the
 # method Object::pre_insert.
 for my $hook (qw(versioning auditing)) {
     append_method( 'Object::pre_insert', "${hook}_hook" );
 }

 sub versioning_hook { ... }
 sub auditing_hook { ... }

=item Example 2

 use Class::CompoundMethods 'append_method';

 my @versioned_tables = ( .... );
 my @audited_tables = ( .... );


 for my $table_list ( { tables => \ @versioned_tables,
                        prefix => 'versioned' },
                      { tables => \ @audited_tables,
                        prefix => 'audited' } ) {
     my $tables = $table_list->{'tables'};
     my $prefix = $table_list->{'prefix'};

     for my $table ( @$tables ) {
         for my $hook ( qw[pre_insert pre_update pre_delete]) {

             my $method_name = "GreenPartyDB::Database::${table}::${hook}";
             my $method_inst = __PACKAGE__ . "::${prefix}_${hook}";
             append_method( $method_name, $method_inst );

         }
     }
 }

 sub versioned_pre_insert { ... }
 sub versioned_pre_update { ... }
 sub versioned_pre_delete { ... }
 sub audited_pre_insert { ... }
 sub audited_pre_update { ... }
 sub audited_pre_delete { ... }

=back

=head2 EXPORT

This class optionally exports the C<append_method> function.

=head1 COPYRIGHT & LICENSE

Copyright (c) 2003 Joshua b. Jore
All rights reserved.
This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=head1 AUTHOR

Joshua b. Jore <jjore@cpan.org>

=head1 SEE ALSO

RFC Class::AppendMethods http://www.perlmonks.org/index.pl?node_id=252199

Installing chained methods http://www.perlmonks.org/index.pl?node_id=251908

=cut
