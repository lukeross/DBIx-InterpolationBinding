#!/usr/bin/perl -w

package SQL::InterpolationBinding;

use 5.005;
use strict;
use vars qw($VERSION @ISA @EXPORT $DEBUG);

use overload	'""'	=> \&_convert_object_to_string,
		'.'	=> \&_append_item_to_object;

require Exporter;
@ISA = qw(Exporter);
@EXPORT = qw(dbi_exec);

$VERSION = '0.01';

$DEBUG = 0;

sub import {
	overload::constant 'q' => \&_prepare_object_from_string;
	SQL::InterpolationBinding->export_to_level(1, @_);
}

sub dbi_exec {
	my $dbi = shift;
	my $sql = shift;

	if (ref $sql) {
		# We have a fake string
		unshift @_, @{ $sql->{bind_params} };
		$sql = $sql->{sql_string}
	}

	print "prepare($sql)\nexecute(@_)\n" if $DEBUG;
	my $sth = $dbi->prepare($sql) or return;
	$sth->execute($sql, @_) or return;
	return $sth;
}

sub _prepare_object_from_string {
	my (undef, $string, $mode) = @_;
	return $string unless ($mode eq "qq");
	my $self = {
		string => $string,
		sql_string => $string,
		bind_params => [ ]
	};
	return bless $self, "SQL::InterpolationBinding";
}

sub _convert_object_to_string {
	my $self = shift;
	return $self->{string};
}

sub _append_item_to_object {
	my ($self, $string, $flipped) = @_;

	my $new_hash = { %$self };
	if (ref $string) {
		# We're adding another constant
		if ($flipped) {
			$new_hash->{sql_string} = $string->{sql_string} . $new_hash->{sql_string};
			$new_hash->{string} = $string->{string} . $new_hash->{string};
			unshift @{ $new_hash->{bind_params} }, @{ $string->{bind_params} };
		} else {
			$new_hash->{sql_string} .= $string->{sql_string};
			$new_hash->{string} .= $string->{string};
			push @{ $new_hash->{bind_params} }, @{ $string->{bind_params} };
		}
	} else {
		# We're interpolating
		if ($flipped) {
			$new_hash->{sql_string} = "?" . $new_hash->{sql_string};
			$new_hash->{string} = $string . $new_hash->{string};
			unshift @{ $new_hash->{bind_params} }, $string;
		} else {
			$new_hash->{sql_string} .= "?";
			$new_hash->{string} .= $string;
			push @{ $new_hash->{bind_params} }, $string;
		}
	}
	return bless $new_hash, ref($self);
}

1;
__END__

=head1 NAME

SQL::InterpolationBinding - Perl extension for blah blah blah

=head1 SYNOPSIS

  use SQL::InterpolationBinding;
  blah blah blah

=head1 DESCRIPTION

Stub documentation for SQL::InterpolationBinding, created by h2xs. It looks like the
author of the extension was negligent enough to leave the stub
unedited.

Blah blah blah.

=head2 EXPORT

None by default.



=head1 SEE ALSO

Mention other useful documentation such as the documentation of
related modules or operating system documentation (such as man pages
in UNIX), or any relevant external documentation such as RFCs or
standards.

If you have a mailing list set up for your module, mention it here.

If you have a web site set up for your module, mention it here.

=head1 AUTHOR

Luke Ross, E<lt>lukeross@localdomainE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2006 by Luke Ross

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.5 or,
at your option, any later version of Perl 5 you may have available.


=cut
