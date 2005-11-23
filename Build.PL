use Module::Build;
Module::Build->new(
    license         => 'perl',
    create_readmore => 'Do it now. Do it harder.',
    sign            => 1,
    dist_author     => '"Joshua ben Jore" <jjore@cpan.org>',

    module_name => 'Class::CompoundMethods',
    requires    => {

        # This stuff comes with perl anyway.
        strict   => 0,
        vars     => 0,
        Exporter => 0,
        B        => 0,
    },
)->create_build_script();

