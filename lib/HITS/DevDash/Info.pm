package HITS::DevDash::Info;
use perl5i::2;
use Dancer ':syntax';
use Dancer::Plugin::REST;
use Dancer::Plugin::Database;
use MIME::Base64;
use lib '../sif-au-perl/lib';
use lib '/home/scottp/nsip/sif-au-perl/lib';
use SIF::AU;

our $VERSION = '0.1';
prefix '/info';
set serializer => 'mutable';

get '/' => sub {
	# TODO - API definition
};

get '/:userToken' => sub {
	# TODO - Show list for this ID (most recent 25, add params later)
	my $sth = database->prepare(q{
		SELECT 
			*
		FROM
			SIF3_APP_TEMPLATE
		WHERE
			USER_TOKEN = ?
	});

	# XXX What about other data
	#	hits / Vendor information like apps and title

	# XXX AHHH all the Field name changes, userToken, USER_TOKEN !

	$sth->execute(params->{userToken});
	my $data = $sth->fetchrow_hashref // {};
	return {
		info => {
			# XXX These names are wrong too - what is the right name?
			#	Check XML Environment as convention?
			template => $data->{ENV_TEMPLATE_ID},
			password => $data->{PASSWORD},
			instanceId => $data->{APP_TEMPLATE_ID},
			appTemplateId => $data->{APP_TEMPLATE_ID},
			authMethod => $data->{AUTH_METHOD},
			userToken => $data->{USER_TOKEN},
			applicationKey => $data->{APPLICATION_KEY},
			solutionId => $data->{SOLUTION_ID},
		}
	};
};

true;
