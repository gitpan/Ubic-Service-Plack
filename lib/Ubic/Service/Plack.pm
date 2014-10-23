package Ubic::Service::Plack;
BEGIN {
  $Ubic::Service::Plack::VERSION = '1.13';
}

use strict;
use warnings;

# ABSTRACT: Helper for running psgi applications with ubic and plackup


use base qw(Ubic::Service::Common);

use Params::Validate qw(:all);
use Plack;

use Ubic::Daemon qw(:all);
use Ubic::Service::Common;


my $plackup_command = $ENV{'UBIC_SERVICE_PLACKUP_BIN'} || 'plackup';

sub new {
    my $class = shift;

    my $params = validate(@_, {
        server      => { type => SCALAR },
        app         => { type => SCALAR },
        app_name    => { type => SCALAR },
        server_args => { type => HASHREF, default => {} },
        user        => { type => SCALAR, optional => 1 },
        status      => { type => CODEREF, optional => 1 },
        port        => { type => SCALAR, regex => qr/^\d+$/, optional => 1 },
        ubic_log    => { type => SCALAR, optional => 1 },
        stdout      => { type => SCALAR, optional => 1 },
        stderr      => { type => SCALAR, optional => 1 },
        pidfile     => { type => SCALAR, optional => 1 },
    });

    $params->{pidfile} ||= "/tmp/$params->{app_name}.pid";
    return bless $params => $class;
}

sub pidfile {
    my $self = shift;
    return $self->{pidfile};
}

sub bin {
    my $self = shift;

    my @cmd = split(/\s+/, $plackup_command);

    my %args = (
        server => $self->{server},
        ($self->{port} ? (port => $self->{port}) : ()),
        $self->defaults,
        %{$self->{server_args}},
    );
    for my $key (keys %args) {
        my $cmd_key = (length $key == 1) ? '-' : '--';
        $cmd_key .= $key;
        my $v = $args{$key};
        next unless defined $v;
        if (ref $v eq 'ARRAY') {
            for my $value (@$v) {
                push @cmd, $cmd_key, $value;
            }
        }
        else {
            push @cmd, $cmd_key, $v;
        }
    }
    push @cmd, $self->{app};
    return \@cmd;
}

sub start_impl {
    my $self = shift;

    my $daemon_opts = { bin => $self->bin, pidfile => $self->pidfile, term_timeout => 5 };
    for (qw/ubic_log stdout stderr/) {
        $daemon_opts->{$_} = $self->{$_} if defined $self->{$_};
    }
    start_daemon($daemon_opts);
    return;
}

sub stop_impl {
    my $self = shift;
    return stop_daemon($self->pidfile, { timeout => 7 });
}

sub status_impl {
    my $self = shift;
    my $running = check_daemon($self->pidfile);
    return 'not running' unless ($running);
    if ($self->{status}) {
        return $self->{status}->();
    } else {
        return 'running';
    }
}

sub user {
    my $self = shift;
    return $self->{user} if defined $self->{user};
    return $self->SUPER::user;
};

sub timeout_options {
    return { start => { trials => 15, step => 0.1 }, stop => { trials => 15, step => 0.1 } };
}

sub port {
    my $self = shift;
    # we should leave only one of these, but I can't decide which one -- mmcleric
    return $self->{port} if defined $self->{port};
    return $self->{server_args}{port};
}


sub defaults {
    return ();
}


1;

__END__
=pod

=head1 NAME

Ubic::Service::Plack - Helper for running psgi applications with ubic and plackup

=head1 VERSION

version 1.13

=head1 SYNOPSIS

    use Ubic::Service::Plack;
    return Ubic::Service::Plack->new({
        server => "FCGI",
        server_args => { listen => "/tmp/app.sock",
                         nproc  => 5 },
        app      => "/var/www/app.psgi",
        app_name => 'app',
        status   => sub { ... },
        port     => 4444,
        ubic_log => '/var/log/app/ubic.log',
        stdout   => '/var/log/app/stdout.log',
        stderr   => '/var/log/app/stderr.log',
        user     => "www-data",
    });

=head1 DESCRIPTION

This service is a common ubic wrap for psgi applications. It uses plackup for running these applications.

=head1 NAME

Ubic::Service::Plack - ubic service base class for psgi applications

=head1 VERSION

version 1.13

=head1 METHODS

=over

=item C<new($params)>

Parameters (mandatory if not specified otherwise):

=over

=item I<server>

Server name from Plack::Server::* or Plack::Handler::* namespace.
You can pass this param in both variants, for example 'Plack::Handler::FCGI' or just 'FCGI'.

=item I<server_args> (optional)

Hashref with options that will passed to concrete Plack server specified by C<server> param. See concrete server docimentation for possible options.
You can also pass here such options as 'env' to override defaults. In this case you must use long option names ('env' insted of 'E').

=item I<app>

Path to .psgi app.

=item I<app_name>

Name of your application (uses for constructing path for storing pid-file of your app).

=item I<status> (optional)

Coderef to special function, that will check status of your application.

=item I<port> (optional)

Port on which your application works. Ubic-ping will use this info for HTTP status checking of your application.

=item I<ubic_log> (optional)

Path to ubic log.

=item I<stdout> (optional)

Path to stdout log of plackup.

=item I<stderr> (optional)

Path to stderr log of plackup.

=item I<user> (optional)

User name. If specified, real and effective user identifiers will be changed before execing any psgi applications.

=item I<pidfile> (optional)

Pidfile for C<Ubic::Daemon> module.

If not specified, it will be derived from I<app_name>.

=back

=back

=item C<pidfile()>

Get pidfile name.

=item C<bin()>

Get command-line with all arguments in the arrayref form.

=for Pod::Coverage defaults

=head1 FUTURE DIRECTIONS

Some kind of basic HTTP/socket (depending on server type) ping in status phase would be handy.

=head1 AUTHORS

=over 4

=item *

Yury Zavarin <yury.zavarin@gmail.com>

=item *

Vyacheslav Matjukhin <mmcleric@yandex-team.ru>

=back

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2011 by Yandex LLC.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut

