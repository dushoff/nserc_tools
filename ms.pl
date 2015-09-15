use strict;

my %files;

undef $/;

# What is input file type?
my $inftype = $ARGV[0];
$inftype =~ s/.*\.//;

# Read files into file hash:
foreach my $fn (@ARGV){
	open F, $fn;
	$fn =~ /[^.]*$/;
	$files{$&} .= <F>;
}

# Process format file
$files{fmt} =~ s/^\s+//;
my (%spec, %com, @rule, @hot);
foreach (split /\n+/, $files{fmt}){
	next if /^#/;
	if (s/^!//){
		die ("Unrecognized special line $_") unless s/^\s*(\S+)\s+//;
		my $tag = $1;
		$spec{$tag}=$_;
		$spec{$tag} =~ s/\n/\n/g;
		$spec{$tag} =~ s/\t/\t/g;
	} elsif (s/^\*\s*//){
		s/[\[\]()]/\\$&/gs;
		my @ln = /(\S+)\s+(\S+)\s+(.*)/;
		die ("Unrecognized rule line $_") unless (@ln == 3);
		push @rule, \@ln;
	} elsif (s/^\+\s*//){
		my @ln = /(\S+)\s+(.+)/;
		die ("Unrecognized hot line $_") unless (@ln == 2);
		push @hot, \@ln;
	}else {
		die ("Unrecognized format line $_") unless s/^\s*(\S+)\s*//;
		$com{$1}=$_;
	}
}

# Top of template file
my @tmp = split(/----------------------+\s+/, $files{tmp});
print $tmp[0];

# Split input file
$files{$inftype} =~ s/.*$spec{START}//s if defined $spec{START};
$files{$inftype} =~ s/$spec{END}.*//s if defined $spec{END};
my @tex;
if (defined $spec{SLIDESEP}){
	@tex = split (/$spec{SLIDESEP}/,$files{$inftype});
} else {
	@tex = ($files{$inftype});
	# $tex[0] = $files{$inftype};
}

## Process slides
foreach(@tex){
	my @slide;
	my $level=0;

	# Skip slides that start with NULL command 
	next if defined $spec{NULL} and /^\s*$spec{NULL}/;

	# LAST command 
	last if defined $spec{END} and /^\s*$spec{END}/;

	#Slides that start with ! are not slides (allows cross-slide commands)
	my $slide=1 unless s/^[\n]*!//;

	# Don't choke on non-blank blank lines
	s/\n[\s]+\n/\n\n/g;

	# Split into paragraphs
	foreach (split(/\n{2,}/, $_)){

		# Leading newlines bad
		s/\n*//;

		## still good stuff in /home/dushoff/papers/zcold/academic/norms//paper/text.pl

		my $lev=0;

		# Find "command" word
		/(\s*)([\w*]*)/;
		my $lead = $1;

		# Look up commands
		my $pat = "";
		if (defined $com{$2}){
			$pat = $com{$2};
			s/\s*[\w*]+[ 	]*//;
		} elsif (defined $com{NOCOMM}){
			$pat = $com{NOCOMM};
		}

		# Replace lines by appropriate patterns
		if ($pat){
			my $str = $_;
			$_ = $lead.$pat;

			#Expand escapes before pattern expansion
			s/\\n /\n/gs;
			s/\\n\b/\n/gs;
			s/\\t /\t/gs;
			s/\\t\b/\t/gs;

			$str =~ s/%/@#/gs;
			while (/%/){
				# print "\nPat: $pat\n Str: $str\n";

				# Replace %% with whole remaining string
				if (/^[^%]*%%/){
					s/%%/$str/g;
					$str = "";
				}

				# %! eats whole remaining string
				elsif (/^[^%]*%!/){
					s/%!//gs;
					$str = "";
				}

				# %| gets next sentence (use | to avoid period)
				elsif (/^[^%]*%[|]/){
					$str =~ s/^([^|.!?]*[|.!?])\s*// or 
						die "%| doesn't match $str";
					my $p = $1;
					$p =~ s/[|]$//;
					s/%[|]/$p/;
				}

				# %: gets to period (or whole paragraph)
				elsif (/^[^%]*%:/){
					$str =~ s/: *([^.]*)\.*\s*// or 
						die "%: doesn't match $str";
					my $p = $1;
					s/%:/$p/;
				}

				# %_ gets current line (not required to exist)
				elsif (/^[^%]*%_/){
					$str =~ s/^([^\n]*)\n//;
					my $p = $1;
					s/%_/$p/;
				}

				# %^ optionally takes next word
				elsif (/^[^%]*%\^/){
					$str =~ s/\s*(\S*)\s*//;
					my $p = $1;
					s/%\^/$p/;
				}

				# Otherwise, % requires next word
				else{
					$str =~ s/\s*([^\s|]+)\s*//
						or die "% doesn't match $str in $_\n";
					my $p = $1;
					s/%/$p/;
				}
			}
		}
		redo if /^\s*\^/;
		s/@#/%/gs;
		
		# Leading tabs
		s/\s+$//;
		next if /^$/;
		if (defined $spec{TAB}){
			$lev++ while s/^$spec{TAB}//;
			while ($level<$lev){
				push @slide, $spec{BIZ} if defined $spec{BIZ};
				$level++;
				die ("Too many tabs on line $_") 
					if $level<$lev;
			}
		}


		while ($level>$lev){
			push @slide, $spec{EIZ} if defined $spec{EIZ};
			$level--;
		}
		s/^/$spec{ITEM} / unless $level==0;

		#Hot changes
		foreach my $hp (@hot){
			s/$hp->[0]/$hp->[1]/gs;
		}

		foreach my $rp (@rule){
			while (/$rp->[0]([^$rp->[1]]*)$rp->[1]/){
				my ($text, $rep) = ($1, $rp->[2]);	
				$rep =~ s/%/$text/;
				s/$rp->[0]([^$rp->[1]]*)$rp->[1]/$rep/;
			}
		}

		# push @slide, "$_";
		push @slide, "$_" unless /^$/;
	}
	# End of paragraph loop
	
	while ($level>0){
		push @slide, $spec{EIZ} if defined $spec{EIZ};
		$level--;
	}

	next if (@slide==0); # Don't print blank slide (if you can help it)

	# To do: allow different OFS (also, optional OFS)
	print join ("\n\n", @slide);
}

# Bottom of template file
print "\n$tmp[1]";
