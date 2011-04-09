package Terminal::Handle;

use strict;
use warnings;

use IO::Handle;
use AnyEvent::Handle;

sub new {
    my $class = shift;

    my $self = {@_};
    bless $self, $class;

    $self->{handle} = AnyEvent::Handle->new(
        fh       => $self->{fh},
        on_error => sub {
            my $handle = shift;
            my ($is_fatal, $message) = @_;
        },
        on_eof => sub {
            my $handle = shift;

            $self->{on_eof}->($self);
        },
        on_read => sub {
            my $handle = shift;

            my $chunk = $handle->rbuf;
            $handle->rbuf = '';

            $self->{on_read}->($self, $chunk);
        }
    );

    return $self;
}

sub new_from_fd {
    my $class = shift;
    my $fd    = shift;

    my $fh = IO::Handle->new_from_fd($fd, 'w+');

    return $class->new(fh => $fh, @_);
}

sub write {
    my $self = shift;
    my ($chunk) = @_;

    $self->{handle}->push_write($chunk);

    return $self;
}

1;
