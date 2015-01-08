# NAME

MooseX::Storage::IO::CHI - Store and retrieve Moose objects to a cache, via [CHI](https://metacpan.org/pod/CHI).

# SYNOPSIS

First, configure your Moose class via a call to Storage:

    package MyDoc;
    use Moose;
    use MooseX::Storage;

    with Storage(io => [ 'CHI' => {
        key_attr   => 'doc_id',
        key_prefix => 'mydoc-',
        cache_args => {
            driver  => 'Memcached::libmemcached',
            servers => [ "10.0.0.15:11211", "10.0.0.15:11212" ],
        },
    }]);

    has 'doc_id'  => (is => 'ro', isa => 'Str', required => 1);
    has 'title'   => (is => 'rw', isa => 'Str');
    has 'body'    => (is => 'rw', isa => 'Str');
    has 'tags'    => (is => 'rw', isa => 'ArrayRef');
    has 'authors' => (is => 'rw', isa => 'HashRef');

    1;

Now you can store/load your class to the cache you defined in cache\_args:

    use MyDoc;

    # Create a new instance of MyDoc
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

    # Save it to cache (will be stored using key "mydoc-foo12")
    $doc->store();

    # Load the saved data into a new instance
    my $doc2 = MyDoc->load('foo12');

    # This should say 'Bob Smith'
    print $doc2->authors->{bsmith}{name};

# DESCRIPTION

MooseX::Storage::IO::CHI is a Moose role that provides an io layer for [MooseX::Storage](https://metacpan.org/pod/MooseX::Storage) to store/load your Moose objects to a cache, using [CHI](https://metacpan.org/pod/CHI).

You should understand the basics of [Moose](https://metacpan.org/pod/Moose), [MooseX::Storage](https://metacpan.org/pod/MooseX::Storage), and [CHI](https://metacpan.org/pod/CHI) before using this module.

At a bare minimum the consuming class needs to give this role a [CHI](https://metacpan.org/pod/CHI) configuration, and a field to use as a cachekey - see [cache\_args](#cache_args) and [key\_attr](#key_attr).

# PARAMETERS

Following are the parameters you can set when consuming this role that configure it in different ways.

## key\_attr

"key\_attr" is a required parameter when consuming this role.  It specifies an attribute in your class that will provide the value to use as a cachekey when storing your object via [CHI](https://metacpan.org/pod/CHI)'s set method.

## key\_prefix

A string that will be used to prefix the key\_attr value when building the cachekey.

## expires\_in

Expiration duration to use when saving items to cache.

## cache\_args

A hashref of args that will be passed to [CHI](https://metacpan.org/pod/CHI)'s constructor when building cache objects.

## cache\_attr

## cache\_args\_method

## cache\_builder\_method

Parameters you can use if you want to rename the various attributes and methods that are added to your class by this role.

# ATTRIBUTES

Following are attributes that will be added to your consuming class.

## cache

A [CHI](https://metacpan.org/pod/CHI) object that will be used to communicate to your cache.  See [CACHE CONFIGURATION](#cache-configuration) for how to configure.

You can change this attribute's name via the cache\_attr parameter.

# METHODS

Following are methods that will be added to your consuming class.

## $obj->store(\[ cache => $cache \])

Object method.  Stores the packed Moose object to your cache, via [CHI](https://metacpan.org/pod/CHI)'s set method.  You can optionally pass in a cache object directly instead of using the object's cache attribute.

We will look at the <"expires\_in"|expires\_in> parameter when calling set().

## $obj = $class->load($key\_value, \[, cache => $cache, inject => { key => val, ... } \])

Class method.  Queries your cache using [CHI](https://metacpan.org/pod/CHI)'s get method, and returns a new Moose object built from the resulting data.  Returns undefined if there was a cache miss.

The first argument is the key value (the value for key\_attr) to use, and is required.  It will be prefixed with key\_prefix when querying the cache.

You can optionally pass in a cache object directly instead of having the class build one for you.

You can also pass in an inject hashref to supply additional arguments to the class' new function, or override ones from the cached data.

## $cache = $class->build\_cache()

See [CACHE CONFIGURATION](#cache-configuration).

You can change this method's name via the cache\_builder\_method parameter.

## $args = $class->cache\_args()

See [CACHE CONFIGURATION](#cache-configuration)

You can change this method's name via the cache\_args\_method parameter.

# CACHE CONFIGURATION

There are a handful ways to configure how this module sets up a [CHI](https://metacpan.org/pod/CHI) object to talk to your cache:

A) Setup contructor args via the cache\_args parameter.  See the [SYNOPSIS](#synopsis) for an example of how to do this.

B) Pass your own cache object at every call, e.g.

    my $cache = CHI->new(...);
    my $obj   = MyDoc->new(...);
    $obj->store(cache => $cache);
    my $obj2 = MyDoc->load(cache => $cache);

C) Override the cache\_args method in your class to provide constructor args for CHI, e.g.

    package MyDoc;
    use Moose;
    use MooseX::Storage;

    with Storage(io => [ 'CHI' => {
        key_attr => 'doc_id',
    }]);

    sub cache_args {
        my $class = shift;
        my $servers = My::Config->memcached_servers;
        return {
            driver  => 'Memcached::libmemcached',
            servers => $servers,
        };
    }

D) Override the build\_cache method in your class to directly build a CHI object, e.g.

    package MyDoc;
    ...
    sub build_cache {
        my $class = shift;
        my $cache = My::Config->get_cache_obj;
        return $cache;
    }

# NOTES

## Serialization

If your class provides a format serialization level - i.e. freeze and thaw methods - it will be called around calling CHI's get/set methods.  Otherwise, we will rely on CHI's serialization.

# SEE ALSO

- [Moose](https://metacpan.org/pod/Moose)
- [MooseX::Storage](https://metacpan.org/pod/MooseX::Storage)
- [CHI](https://metacpan.org/pod/CHI)

# AUTHOR

Steve Caldwell <scaldwell@gmail.com>

# COPYRIGHT

Copyright 2015- Steve Caldwell <scaldwell@gmail.com>

# LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

# ACKNOWLEDGEMENTS

Thanks to [Campus Explorer](http://www.campusexplorer.com), who allowed me to release this code as open source.
