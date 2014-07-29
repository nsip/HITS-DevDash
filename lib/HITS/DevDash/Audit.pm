package HITS::Identity;
use perl5i::2;
use Dancer ':syntax';
use Dancer::Plugin::REST;
use Dancer::Plugin::Database;
use MIME::Base64;
use lib '../sif-au-perl/lib';
use lib '/home/scottp/nsip/sif-au-perl/lib';
use SIF::AU;

=head1 DATABASE

+------------------+---------------+------+-----+---------+----------------+
| Field            | Type          | Null | Key | Default | Extra          |
+------------------+---------------+------+-----+---------+----------------+
| id               | bigint(20)    | NO   | PRI | NULL    | auto_increment |
| requestTime      | datetime      | YES  |     | NULL    |                |
| responseTime     | datetime      | YES  |     | NULL    |                |
| clientIp         | varchar(45)   | YES  |     | NULL    |                |
| url              | varchar(255)  | YES  |     | NULL    |                |
| solutionId       | varchar(255)  | YES  |     | NULL    |                |
| appKey           | varchar(255)  | YES  |     | NULL    |                |
| userToken        | varchar(255)  | YES  |     | NULL    |                |
| context          | varchar(255)  | YES  |     | NULL    |                |
| instanceId       | varchar(45)   | YES  |     | NULL    |                |
| zone             | varchar(255)  | YES  |     | NULL    |                |
| environmentToken | varchar(255)  | YES  |     | NULL    |                |
| sessionToken     | varchar(255)  | YES  |     | NULL    |                |
| method           | varchar(45)   | YES  |     | NULL    |                |
| queryParameters  | varchar(2000) | YES  |     | NULL    |                |
| requestHeaders   | varchar(2000) | YES  |     | NULL    |                |
| request          | text          | YES  |     | NULL    |                |
| httpStatus       | int(11)       | YES  |     | NULL    |                |
| responseHeaders  | varchar(2000) | YES  |     | NULL    |                |
| response         | text          | YES  |     | NULL    |                |
+------------------+---------------+------+-----+---------+----------------+
20 rows in set (1.72 sec)

Primary protection = appKey (currently only HITS)

	SELECT 
		id,
		requestTime, responseTime,
		clientIp, solutionId, appKey, instanceId, zone,
		method, queryParameters, requestHeaders, request, 
		httpStatus, responseHeaders, response
	FROM
		XMLAudit
	WHERE
		appKey = 'HITS'
	ORDER BY
		id DESC
	LIMIT
		10
		
	SELECT 
		id,
		requestTime, responseTime,
		method, queryParameters, 
		httpStatus
	FROM
		XMLAudit
	WHERE
		appKey = 'HITS'
	ORDER BY
		id DESC
	LIMIT
		10
		

=cut

our $VERSION = '0.1';
prefix '/audit';
set serializer => 'mutable';

get '/' => sub {
	# TODO - API definition
};

get '/:appKey' => sub {
	# TODO - Show list for this ID (most recent 25, add params later)
	my $sth = database->prepare(q{
		SELECT 
			id,
			url,
			requestTime, responseTime,
			method, queryParameters, 
			httpStatus
		FROM
			XMLAudit
		WHERE
			appKey = ?
		ORDER BY
			id DESC
		LIMIT
			25
	});
	$sth->execute(params->{appKey});
	return {
		audit => $sth->fetchall_arrayref({}),
	};
};

get '/:appKey/entry/:auditId' => sub {
	my $sth = database->prepare(q{
		SELECT
			*
		FROM
			XMLAudit
		WHERE
			appKey = ? AND id = ?
	});
	$sth->execute(params->{appKey}, params->{auditId});
	my $data = $sth->fetchrow_hashref // {};

	# XML Analysis
	foreach my $type (qw/response request/) {
		my $xml = $data->{$type} // '';
		if ($xml) {
			eval {
				my $class = $xml;
				$class =~ s/>.*$//s;
				$class =~ s/^<//;
				$class =~ s/ .*$//;
				info("DETECTED $class");
				$class = "SIF::AU::$class";
				info("Converted $class");

				my $obj = $class->from_xml($xml);
				$obj->xml_validate();
			};
			if ($@) {
				info ($@);
				$data->{$type . "Analysis"} = $@ . "";
			}
			else {
				$data->{$type . "Analysis"} = "NO ERRORS / WARNINGS";
			}
		}
		else {
			$data->{$type . "Analysis"} = "NO XML";
		}
	}
		
	return $data;
};

true;
