use ExtUtils::MakeMaker;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
WriteMakefile(
    NAME         => 'Business::SLA',
    VERSION_FROM => 'lib/Business/SLA.pm', # finds $VERSION
    AUTHOR       => 'Linda Julien <leira@bestpractical.com>',
    PREREQ_PM	=> { Test::Inline => 0,
    		     Business::Hours => 0
		     },
    ABSTRACT     => '',
);

               {
                   package MY;
                   sub top_targets {
                       my($self) = @_;
                       my $out = "POD2TEST_EXE = pod2test\n";

                       $out .= $self->SUPER::top_targets(@_);
                       $out =~ s/^(pure_all\b.*)/$1 testifypods/m;

                       $out .= "\n\ntestifypods : \n";

                       foreach my $pod (keys %{$self->{MAN1PODS}},
                                        keys %{$self->{MAN3PODS}})
                       {
                           (my $test = $pod) =~ s/\.(pm|pod)$//;
                           $test =~ s|/|-|g;
                           $test =~ s/^lib\W//;
                           $test =~ s/\W/-/;
                           $test = "embedded-$test.t";
                           $out .= "\t$self->{NOECHO}\$(POD2TEST_EXE) ".
                                   "$pod t/$test\n";
                       }

                       return $out;
                   }
               }

