requires 'perl', '5.008005';

requires 'Moose';
requires 'MooseX::Role::Parameterized';
requires 'MooseX::Storage';
requires 'CHI';

on test => sub {
    requires 'Test::Most';
};
