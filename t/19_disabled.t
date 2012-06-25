use strict;
use warnings;
use Test::More;

# Tests which expect a STOMP server like ActiveMQ to exist on
# localhost:61613, which is what you get if you just get the ActiveMQ
# distro and changes its config.

use Net::Stomp;
use YAML::XS qw/ Dump Load /;
use Data::Dumper;

use FindBin;
use lib "$FindBin::Bin/lib";
use TestServer;

my $stomp = start_server();

my $frame = $stomp->connect();
ok($frame, 'connect to MQ server ok');

my $reply_to = sprintf '%s:1', $frame->headers->{session};
ok($frame->headers->{session}, 'got a session');
ok(length $reply_to > 2, 'valid-looking reply_to queue');

ok($stomp->subscribe( {
    destination => '/temp-queue/reply',
    selector => "JMSType = 'disabled_response' OR JMSType = 'enabled_response'",
} ),
   'subscribe to temp queue');

my $message = {
    reply_to => $reply_to,
    type => 'testaction',
};
my $text = Dump($message);
ok($text, 'compose message');

$stomp->send( {
    destination => '/queue/test_disabled',
    JMSType => 'testaction',
    body => $text,
} );

my $reply_frame = $stomp->receive_frame();
ok($reply_frame, 'got a reply');
is($reply_frame->headers->{destination},
   "/remote-temp-queue/$reply_to",
   'came to correct temp queue');
is($reply_frame->headers->{type},
   "enabled_response",
   'correct reply type (in headers)');
ok($reply_frame->body, 'has a body');

note Dumper($reply_frame);

$stomp->disconnect;
ok(!$stomp->socket->connected, 'disconnected');

done_testing();
