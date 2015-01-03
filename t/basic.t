use strict;
use Test::Most;

my $datastore = {};

{
    package MyDoc;
    use Moose;
    use MooseX::Storage;

    with Storage(io => [ 'CHI' => {
        key_attr => 'doc_id',
        cache_args => {
            driver    => 'Memory',
            datastore => $datastore,
        },
    }]);

    has 'doc_id'  => (is => 'ro', isa => 'Str', required => 1);
    has 'title'   => (is => 'rw', isa => 'Str');
    has 'body'    => (is => 'rw', isa => 'Str');
    has 'tags'    => (is => 'rw', isa => 'ArrayRef');
    has 'authors' => (is => 'rw', isa => 'HashRef');
}

my $doc = MyDoc->new(
    doc_id   => 'foo12',
    title    => 'Foo',
    body     => 'blah blah',
    tags     => [qw(horse yellow angry)],
    authors  => {
        jdoe => {
            name  => 'John Doe',
            email => 'jdoe@gmail.com',
            roles => [qw(author reader)],
        },
        bsmith => {
            name  => 'Bob Smith',
            email => 'bsmith@yahoo.com',
            roles => [qw(editor reader)],
        },
    },
);

$doc->store();

my $doc2 = MyDoc->load('foo12');

cmp_deeply(
    $doc2,
    all(
        isa('MyDoc'),
        methods(
            doc_id   => 'foo12',
            title    => 'Foo',
            body     => 'blah blah',
            tags     => [qw(horse yellow angry)],
            authors  => {
                jdoe => {
                    name  => 'John Doe',
                    email => 'jdoe@gmail.com',
                    roles => [qw(author reader)],
                },
                bsmith => {
                    name  => 'Bob Smith',
                    email => 'bsmith@yahoo.com',
                    roles => [qw(editor reader)],
                },
            },
        ),
    ),
    'retrieved document looks good',
);

done_testing;
