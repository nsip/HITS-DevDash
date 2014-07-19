package HITS::Identity;
use perl5i::2;
use Dancer ':syntax';
use Dancer::Plugin::REST;
use Dancer::Plugin::Database;
use MIME::Base64;

our $VERSION = '0.1';
prefix undef;
set serializer => 'mutable';

get '/' => sub {
    template 
		'index', 
		{
			objects => [],
			version => 1,
		},
		{
			layout => undef
		}
	;
};

get '/id' => sub {
	return {
		'todo' => 'HELP',
	};
};

get '/id/:id' => sub {
	return {
		'implement' => 'TODO',
	};
};

post '/id' => sub {
	return {
		'implement' => 'TODO',
	};
};

put '/id:id' => sub {
	return {
		'implement' => 'TODO',
	};
};

del '/id:id' => sub {
	return {
		'implement' => 'TODO',
	};
};

true;
