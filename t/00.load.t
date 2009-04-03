use Test::More tests => 2;

BEGIN {
    use_ok('Adam');
    use_ok('Moses');
}

diag("Testing Adam $Adam::VERSION");
diag("Testing Moses $Moses::VERSION");
