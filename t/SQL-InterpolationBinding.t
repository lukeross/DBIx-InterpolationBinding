# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl SQL-InterpolationBinding.t'

#########################

# change 'tests => 1' to 'tests => last_test_to_print';

use Test;
BEGIN { plan tests => 5 };
use SQL::InterpolationBinding;
ok(1); # If we made it this far, we're ok.

#########################

# Insert your test code below, the Test::More module is use()ed here so read
# its man page ( perldoc Test::More ) for help writing this test script.

sub array_eq {
	my $list1 = shift;
	my $list2 = shift;

	return 0 unless @$list1 == @$list2; # Same length?
	my $i;
	for($i = 0; $i < @$list1; ++$i) {
		if ($list1->[$i] ne $list2->[$i]) { return 0; }
	}
	return 1;
}

my $a = 1;
my $b = 'hello';

ok(array_eq(
	[ 'SELECT * FROM table WHERE a=? AND b=?', $a, $b ],
	[ SQL::InterpolationBinding::_create_sql_and_params(
		"SELECT * FROM table WHERE a=$a AND b=$b"
	) ]
), 1, "2: Sanity check");

ok(array_eq(
	[ 'SELECT * FROM table WHERE a=$a AND b=$b' ],
	[ SQL::InterpolationBinding::_create_sql_and_params(
		'SELECT * FROM table WHERE a=$a AND b=$b'
	) ]
), 1, "3: Double quotes only");

{

no SQL::InterpolationBinding;

ok(array_eq(
	[ 'SELECT * FROM table WHERE a=1 AND b=hello' ],
	[ SQL::InterpolationBinding::_create_sql_and_params(
		"SELECT * FROM table WHERE a=$a AND b=$b"
	) ]
), 1, "4: Lexical scope only");

}

ok('hello 1', "hello $a", "5: Can stringify");
