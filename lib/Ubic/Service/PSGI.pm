package Ubic::Service::PSGI;
BEGIN {
  $Ubic::Service::PSGI::VERSION = '1.11';
}

use strict;
use warnings;

use base qw(Ubic::Service::Plack);

=head1 NAME

Ubic::Service::PSGI - deprecated module, see Ubic::Service::Plack instead

=head1 VERSION

version 1.11

=head1 DESCRIPTION

This package got renamed into L<Ubic::Service::Plack> and will be removed soon.

=cut

sub defaults {
    return (
        env => 'deployment',
    );
}

1;