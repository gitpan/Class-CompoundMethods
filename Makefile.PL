use ExtUtils::MakeMaker;

WriteMakefile(
    'NAME'		=> 'Class::CompoundMethods',
    'VERSION_FROM'	=> 'lib/Class/CompoundMethods.pm',
    ($] >= 5.005 ?
      (ABSTRACT_FROM => 'lib/Class/CompoundMethods.pm',
       AUTHOR     => 'Joshua b. Jore <jjore@cpan.org>') : ()),
);
