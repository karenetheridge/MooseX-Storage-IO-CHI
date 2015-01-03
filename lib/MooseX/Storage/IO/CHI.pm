package MooseX::Storage::IO::CHI;

use strict;
use 5.008_005;
our $VERSION = '0.01';

use CHI;
use MooseX::Role::Parameterized;
use namespace::autoclean;

parameter key_attr => (
    isa      => 'Str',
    required => 1,
);

parameter cache_attr => (
    isa     => 'Str',
    default => 'cache',
);

parameter cache_args => (
    isa     => 'HashRef',
    default => sub{{}},
);

parameter cache_args_method => (
    isa     => 'Str',
    default => 'cache_args',
);

parameter cache_builder_method => (
    isa     => 'Str',
    default => 'build_cache',
);

role {
    my $p = shift;

    my $cache_attr           = $p->cache_attr;
    my $cache_builder_method = $p->cache_builder_method;
    my $cache_args_method    = $p->cache_args_method;

    method $cache_builder_method => sub {
        my $class = ref $_[0] || $_[0];
        my $cache_args  = $class->$cache_args_method();
        return CHI->new(%$cache_args);
    };

    method $cache_args_method => sub {
        return $p->cache_args
    };

    has $cache_attr => (
        is      => 'ro',
        isa     => 'CHI::Driver',
        lazy    => 1,
        traits  => [ 'DoNotSerialize' ],
        default => sub { shift->$cache_builder_method },
    );

    method store => sub {
        my ( $self, %args ) = @_;
        my $cache = delete $args{cache} || $self->$cache_attr;
        my $key_attr = $p->key_attr;
        my $cachekey = $self->$key_attr;
        my $data;
        if ($self->can('freeze')) {
            $data = $self->freeze;
        } else {
            $data = $self->pack;
        }
        $cache->set($cachekey, $data, \%args);
    };

    method load => sub {
        my ( $class, $cachekey, %args ) = @_;
        my $cache  = delete $args{cache} || $class->$cache_builder_method;
        my $inject = $args{inject}       || {};

        my $packed = $cache->get($cachekey);
        return undef unless $packed;

        return $class->unpack({
            %$packed,
            %$inject,
            $cache_attr => $cache,
        });
    };
};

1;
__END__

=encoding utf-8

=head1 NAME

MooseX::Storage::IO::CHI - Blah blah blah

=head1 SYNOPSIS

  use MooseX::Storage::IO::CHI;

=head1 DESCRIPTION

MooseX::Storage::IO::CHI is

=head1 AUTHOR

Steve Caldwell E<lt>scaldwell@gmail.comE<gt>

=head1 COPYRIGHT

Copyright 2015- Steve Caldwell

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 SEE ALSO

=cut
