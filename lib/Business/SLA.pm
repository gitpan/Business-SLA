package Business::SLA;

use strict;
use warnings;
use Business::Hours;

	use vars qw ($VERSION);
	$VERSION     = 0.01;

########################################### main pod documentation begin ##

=head1 NAME

Business::SLA - 

=head1 SYNOPSIS

  use Business::SLA;

  my $SLAObj = new Business::SLA;

  $SLAObj->Add('2 real hours', ( 'RealMinutes' => 120, 
				 'BusinessMinutes' => undef, ));

  $SLAObj->Add('1 business hour', ( 'RealMinutes' => 0, 
				    'BusinessMinutes' => 60, ));

  $SLAObj->Add('next business minute', ( 'RealMinutes' => 0, 
					 'BusinessMinutes' => 0, ));

  $SLAObj->SetInHoursDefault('2 real hours');
  $SLAObj->SetOutOfHoursDefault('1 business hour');


=head1 DESCRIPTION

This module is a simple tool for handling operations related to
Service Level Agreements.


=head1 SUPPORT

Send email  to bug-business-sla@rt.cpan.org


=head1 AUTHOR

    Linda Julien
    Best Practical Solutions, LLC 
    leira@bestpractical.com
    http://www.bestpractical.com

=head1 COPYRIGHT

This program is free software; you can redistribute
it and/or modify it under the same terms as Perl itself.

The full text of the license can be found in the
LICENSE file included with this module.


=head1 SEE ALSO

perl(1), L<Business::Hours>.

=cut

############################################# main pod documentation end ##

sub new {
	my $class = shift;

	my $self = bless ({}, ref ($class) || $class);

	return ($self);
}

=head2 SetBusinessHours

Sets the Business::Hours object for this object.

Takes a Business::Hours object.

=begin testing

use_ok  (Business::Hours);
use_ok  (Business::SLA);

my $sla = new Business::SLA;
is(ref($sla), 'Business::SLA');

my $bizhours = Business::Hours->new();
$sla->SetBusinessHours($bizhours);

is($sla->BusinessHours, $bizhours, "Returned same Business Hours");

=end testing

=cut

sub SetBusinessHours {
    my $self = shift;
    my $bizhours = shift;

    $self->{'business_hours'} = $bizhours;

    return;
}

=head2 BusinessHours

Returns the Business::Hours object.

=cut

sub BusinessHours {
    my $self = shift;

    return $self->{'business_hours'};
}

=head2 SetInHoursDefault

Sets the default SLA for times inside of business hours.

Takes a string which is the hash key for the desired SLA.

=begin testing


my $sla = new Business::SLA;

my $val = "aaa";

$sla->SetInHoursDefault($val);

is($sla->InHoursDefault, $val, "Returned same InHoursDefault");

=end testing

=cut

sub SetInHoursDefault {
    my $self = shift;
    my $sla = shift;;

    $self->{'in_hours_default'} = $sla;
}

=head2 InHoursDefault

Returns the default SLA for times inside of business hours.

=cut

sub InHoursDefault {
    my $self = shift;

    return $self->{'in_hours_default'};
}

=head2 SetOutOfHoursDefault

Sets the default SLA for times outside of business hours.

Takes a string which is the hash key for the desired SLA.

=begin testing


my $sla = new Business::SLA;

my $val = "aaa";

$sla->SetOutOfHoursDefault($val);

is($sla->OutOfHoursDefault, $val, "Returned same OutOfHoursDefault");

=end testing

=cut

sub SetOutOfHoursDefault {
    my $self = shift;
    my $sla = shift;;

    $self->{'out_of_hours_default'} = $sla;
}

=head2 OutOfHoursDefault

Returns the default SLA for times outside of business hours.

=cut

sub OutOfHoursDefault {
    my $self = shift;

    return $self->{'out_of_hours_default'};
}


=begin testing


my $sla = new Business::SLA;

my $bizhours = Business::Hours->new();

# pick a date that's during business hours
$starttime = 0;
($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime($starttime);
while ($wday == 0  || $wday == 6) {
    $starttime += ( 24 * 60 * 60);
    ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime($starttime);
}
while ( $hour < 9 || $hour >= 18 ) {
    $starttime += ( 4 * 60);
    ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime($starttime);
}

# with Business::Hours set
$sla->SetBusinessHours($bizhours);
is($sla->IsInHours($starttime), 1, "Time is in business hours");

# with Business::Hours unset
$sla->SetBusinessHours(undef);
is($sla->IsInHours($starttime), 1, "Time is in business hours");

# pick a date that's not during business hours
$starttime = 0;
($xsec,$xmin,$xhour,$xmday,$xmon,$xyear,$xwday,$xyday,$xisdst) = localtime($starttime);
while ( $xwday != 0 ) {
    $starttime += ( 24 * 60 * 60);
    ($xsec,$xmin,$xhour,$xmday,$xmon,$xyear,$xwday,$xyday,$xisdst) = localtime($starttime);
}

# with Business::Hours set
$sla->SetBusinessHours($bizhours);
is($sla->IsInHours($starttime), 0, "Time is in business hours");

# with Business::Hours unset
$sla->SetBusinessHours(undef);
is($sla->IsInHours($starttime), 1, "Time is in business hours");

=end testing

=head2 IsInHours

Returns 1 if the date passed in is in business hours, and 0 otherwise.
If no business hours have been set, returns 1 by default.

Takes a date in Unix time format (number of seconds since the epoch).

=cut

sub IsInHours {
    my $self = shift;
    my $date = shift;

    # if no business hours are set, by definition we're in hours
    if ( !(defined $self->BusinessHours()) ) {
	return 1;
    }

    if ($self->BusinessHours()->first_after($date) != $date) { 
	return 0;
    }

    return 1;
}

=head2 SLA

Returns the SLA for the specified time.

Takes a date in Unix time format (number of seconds since the epoch).

=begin testing


my $sla = new Business::SLA;

# set the defaults
my $inhoursval = "aaa";
$sla->SetInHoursDefault($inhoursval);

my $outofhoursval = "bbb";
$sla->SetOutOfHoursDefault($outofhoursval);

my $bizhours = Business::Hours->new();

# pick a date that's during business hours
$starttime = 0;
($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime($starttime);
while ($wday == 0  || $wday == 6) {
    $starttime += ( 24 * 60 * 60);
    ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime($starttime);
}
while ( $hour < 9 || $hour >= 18 ) {
    $starttime += ( 4 * 60);
    ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime($starttime);
}

# with Business::Hours set
$sla->SetBusinessHours($bizhours);
is($sla->SLA($starttime), $inhoursval, "Got correct SLA value");

# with Business::Hours unset
$sla->SetBusinessHours(undef);
is($sla->SLA($starttime), $inhoursval, "Got correct SLA value");

# pick a date that's not during business hours
$starttime = 0;
($xsec,$xmin,$xhour,$xmday,$xmon,$xyear,$xwday,$xyday,$xisdst) = localtime($starttime);
while ( $xwday != 0 ) {
    $starttime += ( 24 * 60 * 60);
    ($xsec,$xmin,$xhour,$xmday,$xmon,$xyear,$xwday,$xyday,$xisdst) = localtime($starttime);
}

# with Business::Hours set
$sla->SetBusinessHours($bizhours);
is($sla->SLA($starttime), $outofhoursval, "Got correct SLA value");

# with Business::Hours unset
$sla->SetBusinessHours(undef);
is($sla->SLA($starttime), $inhoursval, "Got correct SLA value");

=end testing

=cut

sub SLA {
    my $self = shift;
    my $date = shift;

    if ($self->IsInHours($date)) {
	return $self->InHoursDefault();
    } else {
	return $self->OutOfHoursDefault();
    }

}

=head2 Add

Adds an SLA value.  Takes a string (the hash key) and a hash.

=begin testing

# add is tested in AddBusinessMinutes/AddRealMinutes

=end testing

=cut

sub Add {
    my $self = shift;
    my $sla = shift;

    my %hash = @_;

    $self->{'hash'}->{$sla} = \%hash;

    return;
}

=head2 AddRealMinutes

The number of real minutes to add for the specified SLA.

Takes the hash key for the SLA.

=begin testing


my $sla = new Business::SLA;

$sla->Add('aaa', ( 'RealMinutes' => 120, 
		   'BusinessMinutes' => 60, ));

is($sla->AddRealMinutes('aaa'), 120, 
   "Got real minutes for added SLA");

=end testing

=cut

sub AddRealMinutes {
    my $self = shift;
    my $sla = shift;

    return undef unless defined $sla;

    my $minutes;
    if ($self->{'hash'} && $self->{'hash'}->{$sla}) {
	$minutes = $self->{'hash'}->{$sla}->{'RealMinutes'};
    } else {
	$minutes = undef;
    }

    return $minutes;
}

=head2 AddBusinessMinutes

The number of business minutes to add for the specified SLA.

Takes the hash key for the SLA.

=begin testing


my $sla = new Business::SLA;

$sla->Add('aaa', ( 'RealMinutes' => 120, 
		   'BusinessMinutes' => 60, ));

# with no business minutes set
is($sla->AddBusinessMinutes('aaa'), undef, 
   "Got business minutes for added SLA without Business Hours");

my $bizhours = Business::Hours->new();
$sla->SetBusinessHours($bizhours);

# with no business minutes set
is($sla->AddBusinessMinutes('aaa'), 60, 
   "Got business minutes for added SLA with Business Hours");

=end testing

=cut

sub AddBusinessMinutes {
    my $self = shift;
    my $sla = shift;

    return undef unless defined $sla;

    if (!$self->BusinessHours) {
	return undef;
    }

    my $minutes;
    if ($self->{'hash'} && $self->{'hash'}->{$sla}) {
	$minutes = $self->{'hash'}->{$sla}->{'BusinessMinutes'};
    } else {
	$minutes = undef;
    }

    return $minutes;
}

=head2 Starts

Returns the starting time, given an SLA and a date.

Takes a date in Unix time format (number of seconds since the epoch)
and the hash key for the SLA.

=begin testing


my $sla = new Business::SLA;

$sla->Add('aaa', ( 'RealMinutes' => 10, 
		   'BusinessMinutes' => undef, ));

my $time = time();

is($sla->Starts($time, 'aaa'), $time, "Get starting time");

=end testing

=cut

sub Starts {
    my $self = shift;
    my $date = shift;
    my $sla = shift;

    if (defined $self->AddBusinessMinutes($sla)) {
	return $self->BusinessHours()->first_after($date);
    } else {
	return $date;
    }
}

=head2 Due

Returns the due time, given an SLA and a date.

Takes a date in Unix time format (number of seconds since the epoch)
and the hash key for the SLA.

=begin testing


my $sla = new Business::SLA;

$sla->Add('aaa', ( 'RealMinutes' => 10, 
		   'BusinessMinutes' => undef, ));

my $time = time();

is($sla->Due($time, 'aaa'), $time + (10 * 60), "Get starting time");

=end testing

=cut

sub Due {
    my $self = shift;
    my $date = shift;
    my $sla = shift;

    # find start time
    my $due = $self->Starts($date);

    # don't add business minutes unless we have some set
    if (defined $self->AddBusinessMinutes($sla)) {
	my $bh = $self->BusinessHours();
	$due = $bh->add_seconds($due, 
				60 * $self->AddBusinessMinutes($sla));
    }

    $due += (60 * $self->AddRealMinutes($sla));

    return $due;

}

1;
