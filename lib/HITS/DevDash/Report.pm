package HITS::DevDash::Report;
use perl5i::2;
use Dancer ':syntax';
use Dancer::Plugin::REST;
use Dancer::Plugin::Database;
use MIME::Base64;

our $VERSION = '0.1';
prefix '/report';
set serializer => 'JSON';

# XXX NOTE templateId - should work of userToken or what ever that is replaced with

# XXX 
# 	- List of previously run reports - including currently running
# 	- Single report by ID - show results of a single report
#	- Request run report (optional - report ID, normally chosen by current Use Case)

get '/:templateId' => sub {
	my $id = params->{templateId};
	$id =~ s/[^0-9]//g;
	my $report = params->{report} || "TimeTable";
	$report = "$report/in.pl";
	if (!$id || !$report) {
		die "No valid id or report requested";
	}

	# TODO - Have these created on request
	# 	- Created entries go into a database
	# 	- You can then view new or old entries, new ones not completed will
	# 	have another status

	my $d = config->{hits}{report_dir};

	system("export PERL5LIB=$d/lib/; perl $d/bin/report $id $d/$report > /tmp/$$.pl 2> /tmp/$$.err");

	my $in = do "/tmp/$$.pl";
	if ($@) {
		die "Failed to load /tmp/$$.pl - $@";
	}
	return $in;
};

true;
