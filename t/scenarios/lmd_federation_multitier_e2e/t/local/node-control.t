use warnings;
use strict;
use Test::More;

BEGIN {
    plan tests => 36;

    use lib('t');
    require TestUtils;
    import TestUtils;

    use IO::Socket::SSL;
    IO::Socket::SSL::set_ctx_defaults( SSL_verify_mode => 0 );
    $ENV{PERL_LWP_SSL_VERIFY_HOSTNAME} = "0";
}

$ENV{'THRUK_TEST_AUTH_KEY'}  = "key_tier1a";
$ENV{'THRUK_TEST_AUTH_USER'} = "omdadmin";

###########################################################
# test thruks script path
TestUtils::test_command({
    cmd  => '/bin/bash -c "type thruk"',
    like => ['/\/thruk\/script\/thruk/'],
}) or BAIL_OUT("wrong thruk path");

TestUtils::test_command({
    cmd    => '/usr/bin/env thruk nc facts tier1a',
    errlike   => ['/tier1a updated facts sucessfully: OK/'],
});

TestUtils::test_command({
    cmd    => '/usr/bin/env thruk nc facts tier2c',
    errlike   => ['/tier2c updated facts sucessfully: OK/'],
});

TestUtils::test_page(
    url      => 'https://localhost/demo/thruk/cgi-bin/node_control.cgi',
    like     => ['6.66-test'],
);

TestUtils::test_page(
    url      => 'https://localhost/demo/thruk/cgi-bin/node_control.cgi',
    post     => { "action" => "save_options", "omd_default_version" => "6.66-test" },
    redirect => 1,
);

TestUtils::test_page(
    url      => 'https://localhost/demo/thruk/cgi-bin/node_control.cgi',
    post     => { "action" => "omd_restart", "peer" => "tier2c", "service" => "crontab" },
    like     => ['"success" : 1'],
);
