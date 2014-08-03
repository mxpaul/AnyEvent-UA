#/usr/bin/env perl

use lib qw(../lib ./lib);
use Test::More;
use AnyEvent::HTTPD;
use AnyEvent::UA;
use AnyEvent::HTTP;

my $host            = '127.0.0.1';
my $hostname        = 'localhost';
my $port            = 9090;
my $sslport         = 9091;
my $url             = "http://$hostname:$port/";
my $httpsurl        = "https://$hostname:$port/";
my $request_headers = { Host=> $hostname};

my $httpd = AnyEvent::HTTPD->new (host=>$host,port => $port);
$httpd->reg_cb (
	'/' => sub {
		my ($httpd, $req) = @_;
		$req->respond ({ content => ['text/plain', "HI" ]});
	},
);

{
	my $ua = AnyEvent::UA->new();
	for my $method ( qw(GET POST) ) {
		my $cv = AE::cv;
		$ua->req($method=> $url, cb => $cv);
		my ($body, $headers) = $cv->recv();
		is($headers->{Status},200, "UA $method: Test server returned 200") or diag $headers->{Reason};
		is($body, 'HI', "UA $method: Got predefined response from test http server");
	}
}

#my $httpsd = AnyEvent::HTTPD->new (host=>$host,port => $sslport, ssl=> {verify=>0});
#$httpsd->reg_cb (
#	'/' => sub {
#		my ($httpd, $req) = @_;
#		$req->respond ({ content => ['text/plain', "HI" ]});
#	},
#);

#{
#	my $ua = AnyEvent::UA->new();
#	for my $method ( qw(GET POST) ) {
#		my $cv = AE::cv;
#		$ua->req($method=> $httpsurl, cb => $cv);
#		my ($body, $headers) = $cv->recv();
#		is($headers->{Status},200, "UA $method: Test server returned 200") or diag $headers->{Reason};
#		is($body, 'HI', "UA $method: Got predefined response from test http server");
#	}
#}

# {
# 	my $cv = AE::cv;
# 	http_request( GET=> $httpsurl,
# 		headers=> $request_headers,
# 		$cv
# 	);
# 
# 	my ($body, $headers) = $cv->recv();
# 
# 	is($headers->{Status},200, 'Test server returned 200') or diag $headers->{Reason};
# 	is($body, 'HI', 'Got predefined response from test http server');
# }


done_testing;
