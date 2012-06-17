package Net::Graphite;
use strict;
use warnings;
use Carp qw/confess/;
use IO::Socket::INET;

$Net::Graphite::VERSION = '0.01';

our $TEST = 0;

sub new {
    my $class = shift;
    return bless {
        host => '127.0.0.1',
        port => 2003,
        # path
        @_,
    }, $class;
}

sub send {
    my $self = shift;
    my $value;
    $value = shift if @_ % 2;

    my %args = @_;
    $value = $args{value} unless defined $value;
    my $path = $args{path} || $self->{path};
    my $time = $args{time} || time;

    my $plaintext = "$path $value $time\n";

    unless ($Net::Graphite::TEST) {
        my $socket = IO::Socket::INET->new(
            PeerHost => $self->{host},
            PeerPort => $self->{port},
            Proto => 'tcp',
        ) or confess "Error creating socket: $!";

        print $socket $plaintext;
        $socket->close();
    }

    return $plaintext;
}

1;
__END__

=pod

=head1 NAME

Net::Graphite - Interface to Graphite

=head1 SYNOPSIS

  use Net::Graphite;
  my $graphite = Net::Graphite->new(
      host => '127.0.0.1',   # default
      port => 2003,          # default
      path => 'foo.bar.baz', # optional
  );
  $graphite->send(6);        # default time is "now"

 OR

  my $graphite = Net::Graphite->new(
      host => '127.0.0.1',   # default
      port => 2003,          # default
  );
  $graphite->send(
      path => 'foo.bar.baz',
      value => 6,
      time => time(),
  );

=head1 DESCRIPTION

Interface to Graphite which doesn't depend on AnyEvent.

=head1 SEE ALSO

AnyEvent::Graphite

http://graphite.wikidot.com/

=head1 AUTHOR

Scott Lanning E<lt>slanning@cpan.orgE<gt>

=cut
