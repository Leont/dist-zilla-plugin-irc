package Dist::Zilla::Plugin::IRC;

use 5.020;
use warnings;

use Moose;
with 'Dist::Zilla::Role::MetaProvider';
use experimental 'signatures';
use namespace::autoclean;

use Types::Standard qw/Str/;

has host => (
	is       => 'ro',
	isa      => Str,
	required => 1,
);

has channel => (
	is       => 'ro',
	isa      => Str,
	required => 1,
);

my %host_for_network = (
	perl     => 'irc.perl.org',
	libera   => 'irc.libera.org',
	freenode => 'chat.freenode.org',
	oftc     => 'irc.oftc.net',
);

around BUILDARGS => sub($orig, $class, $args) {
	if (!$args->{host}) {
		my $host = $host_for_network{$args->{network} // 'perl'};
		$args->{host} = $host if defined $host;
	}
	return $class->$orig($args);
};

my %web_for = (
	'irc.libera.org'    => 'https://web.libera.chat/#%s',
	'chat.freenode.org' => 'http://webchat.freenode.net/?channels=%%23%s',
);

sub metadata($self) {
	my %irc;
	$irc{url} = sprintf 'irc://%s/#%s', $self->host, $self->channel;
	my $web = $web_for{$self->host};
	$irc{web} = sprintf $web, $self->channel if defined $web;

	return {
		resources => {
			x_IRC => \%irc,
		}
	};
}

1;

# ABSTRACT: Add a IRC channel resource to your dist

=head1 SYNOPSIS

 [IRC]
 channel = distzilla

=head1 DESCRIPTION

This plugin facilitates adding a link to an IRC channel to the resources.

=attr host

The hostname of the IRC channel.

=attr network

The network that is used, if any. Valid values include C<perl> (the default), C<libera>, C<freenode> and C<oftc>

This is used to give C<host> a default value, and is ignored otherwise.

=attr channel

The name of the irc channel, this is mandatory for obvious reasons.
