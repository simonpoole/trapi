#!/usr/bin/perl

use HTTP::Daemon;
use HTTP::Status;
use IPC::System::Simple qw(system capture);

my $port = 2999;
if (scalar(@ARGV) > 0) {
  $port = $ARGV[0];
}

my $d = HTTP::Daemon->new(LocalPort => $port, ReuseAddr => 1) || die;

print "Please contact me at: <URL:", $d->url, ">\n";
while (my $c = $d->accept) {
  if (my $r = $c->get_request) {
    $c->force_last_request;
    print "Incoming request ".$r->uri."\n";
    if ($r->method eq 'GET' and $r->uri->path eq "/api/0.6/map") {
      # remember, this is *not* recommended practice :-)
      my $results = capture($^X, "map", $r->uri->query);
      $c->send_status_line;
      print $c $results;
    }
    else {
      $c->send_error(RC_FORBIDDEN)
    }
  }
  $c->close;
  undef($c);
}
