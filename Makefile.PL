
use strict;
use warnings;



use ExtUtils::MakeMaker 6.30;



my %WriteMakefileArgs = (
  'ABSTRACT' => 'Helper for running psgi applications with ubic and plackup',
  'AUTHOR' => 'Yury Zavarin <yury.zavarin@gmail.com>, Vyacheslav Matjukhin <mmcleric@yandex-team.ru>',
  'BUILD_REQUIRES' => {
    'Config' => '0',
    'File::Which' => '0',
    'LWP::Simple' => '0',
    'Test::More' => '0'
  },
  'CONFIGURE_REQUIRES' => {
    'ExtUtils::MakeMaker' => '6.30'
  },
  'DISTNAME' => 'Ubic-Service-Plack',
  'EXE_FILES' => [],
  'LICENSE' => 'perl',
  'NAME' => 'Ubic::Service::Plack',
  'PREREQ_PM' => {
    'Params::Validate' => '0',
    'Plack' => '0',
    'Ubic::Daemon' => '0',
    'Ubic::Service::Common' => '0'
  },
  'VERSION' => '1.13',
  'test' => {
    'TESTS' => 't/*.t'
  }
);


unless ( eval { ExtUtils::MakeMaker->VERSION(6.56) } ) {
  my $br = delete $WriteMakefileArgs{BUILD_REQUIRES};
  my $pp = $WriteMakefileArgs{PREREQ_PM};
  for my $mod ( keys %$br ) {
    if ( exists $pp->{$mod} ) {
      $pp->{$mod} = $br->{$mod} if $br->{$mod} > $pp->{$mod};
    }
    else {
      $pp->{$mod} = $br->{$mod};
    }
  }
}

delete $WriteMakefileArgs{CONFIGURE_REQUIRES}
  unless eval { ExtUtils::MakeMaker->VERSION(6.52) };

WriteMakefile(%WriteMakefileArgs);



