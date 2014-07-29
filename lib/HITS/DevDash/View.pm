package HITS::Identity;
use perl5i::2;
use Dancer ':syntax';
use Dancer::Plugin::REST;
use Dancer::Plugin::Database;
use MIME::Base64;

our $VERSION = '0.1';
prefix '/view';
set serializer => 'JSON';

# List tables
get '/' => sub {
	my $ret = {};
	foreach my $t (database->tables) {
		$t =~ s/^.+\.//;
		$t =~ s/'//g;
		$t =~ s/`//g;
		if ($t ne 'XMLAudit') {
			$ret->{$t} = {
				href => uri_for('view/' . $t) . '',
			};
		}
	}
	return {
		table => $ret,
	};
};

# List data
get '/:id' => sub {
	# TODO - Add some href links & allow configurable limits, filters and sorting
	my $sth = database->prepare('SELECT * FROM ' . params->{id} . ' LIMIT 250');
	info('SELECT * FROM ' . params->{id} . ' LIMIT 250');
	$sth->execute;
	return {
		data => $sth->fetchall_arrayref({}),
	};
};

true;
