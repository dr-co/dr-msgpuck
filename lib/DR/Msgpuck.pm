use 5.014002;
use strict;
use warnings;

package DR::Msgpuck::Bool;


use overload
    bool        => sub { ${ $_[0] } },
    int         => sub { ${ $_[0] } },
    '!'         => sub { $_[0]->new(!${ $_[0] }) },
    '""'        => sub { ${ $_[0] } },
;

sub TO_JSON {
    my ($self) = @_;
    $$self ? 'true' : 'false';
}

sub TO_MSGPACK {
    my ($self) = @_;
    pack 'C', $$self ? 0xC3 : 0xC2;
}

sub new {
    my ($class, $v) = @_;
    $v = $v ? 1 : 0;
    bless \$v => ref($class) || $class;
}

package DR::Msgpuck::True;
use base 'DR::Msgpuck::Bool';

sub new {
    my ($class) = @_;
    $class->SUPER::new(1);
}

package DR::Msgpuck::False;
use base 'DR::Msgpuck::Bool';

sub new {
    my ($class) = @_;
    $class->SUPER::new(0);
}


package DR::Msgpuck;
require Exporter;
use AutoLoader qw(AUTOLOAD);

our @ISA = qw(Exporter);
our @EXPORT_OK = qw(msgpack msgunpack msgunpack_utf8);
our @EXPORT = @EXPORT_OK;
our $VERSION = '0.01';

require XSLoader;
XSLoader::load('DR::Msgpuck', $VERSION);

1;
__END__

=head1 NAME

DR::Msgpuck - Perl bindings for
L<msgpuck|https://github.com/tarantool/msgpuck>.

=head1 SYNOPSIS

    use DR::Msgpuck;
    my $blob = msgpack { a => 'b', c => 'd' };
    my $object = msgunpack $blob;

    # all $object's string are utf8
    my $object = msgunpack_utf8 $blob;

=head1 DESCRIPTION


L<msgpuck|https://github.com/tarantool/msgpuck> is a simple
and efficient L<msgpack|https://github.com/msgpack/msgpack/blob/master/spec.md>
binary serialization library in a self-contained header file.

=head2 Boolean

Msgpack protocol provides C<true>/C<false> values.
They are unpacks to L<DR::Msgpuck::True> and L<DR::Msgpuck::False> instances.

=head2 Injections

If You have an object that can msgpack by itself, provide method C<TO_MSGPACK>
in it. Example:

    package MyExt;
    sub new {
        my ($class, $value) = @_;
        bless \$value => ref($class) || $class;
    }

    sub TO_MSGPACK {
        my ($self) = @_;
        pack 'CC', 0xA1, substr $$self, 0, 1;
    }


    package main;
    use MyStr;

    my $object = {
        a   => 'b',
        c   => 'd',
        e   => MyExt->new('f')
    };
    my $blob = msgpack($object);
    ...

=head1 AUTHOR

Dmitry E. Oboukhov, E<lt>unera@debian.orgE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2016 by Dmitry E. Oboukhov

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.10.0 or,
at your option, any later version of Perl 5 you may have available.


=cut
