# holland

Puppet module to manage [Holland Backup Manager](http://hollandbackup.org/)

#### Table of Contents

1. [Description](#description)
2. [Setup - The basics of getting started with holland](#setup)
    * [What holland affects](#what-holland-affects)
    * [Setup requirements](#setup-requirements)
    * [Beginning with holland](#beginning-with-holland)
3. [Usage - Configuration options and additional functionality](#usage)
4. [Limitations - OS compatibility, etc.](#limitations)
5. [Development - Guide for contributing to the module](#development)

## Description

This module will setup the [Holland Backup Manager](http://hollandbackup.org/)
and manage its [providers](http://docs.hollandbackup.org/docs/overview.html#providers)
and [backup sets](http://docs.hollandbackup.org/docs/overview.html#backup-sets).
Currently only the mongodump and mysqldump providers are supported by this module.

## Setup

### Setup Requirements

This module requires [puppetlabs/stdlib](https://forge.puppet.com/puppetlabs/stdlib)
and if you are using Puppet 6 or above it also requires [puppetlabs/augeas_core](https://forge.puppet.com/puppetlabs/augeas_core)

#### mongodump Requirements

If you are going to use the `holland-mongodump` provider you will need to make
sure the `mongodump` command is installed and in the path outside of the module
as the package does not pull it in as a dependency. I'm not working around this
in the module because of the many different ways to install the utility. It will need to match the version and deployment method of your MongoDB deployment.

### Beginning with holland

At a minimum you will need to simply include the main `holland` class and one
of the providers.

```puppet
include ::holland
include ::holland::mysqldump
```

## Usage

Please see the REFFERENCE.md for the reference documentation and examples of usage.

## Limitations

The version of `holland-mongodump` that is included in the EPEL pulls in the
`python-pymongo` package from EPEL as a dependency. This package matches with
the version of MongoDB also included in EPEL but will have authentication errors
if you're trying to backup more recent versions of MongoDB.  To work around
this issue I've used the following hack to upgrade `pymongo` via `pip` as a
workaround.

```puppet
package { 'pymongo':
  ensure          => '3.7.2',
  install_options => '--upgrade',
  provider        => 'pip',
  require         => Package['holland-mongodump', 'python2-pip'],
}
```

## Development

Pull requests are welcome especially for unit tests, and additional providers.

### TODO
* Support more backup providers
* Add logging format config to main Holland configuration
* Support historic backup set size calculation for MySQL providers
* Support "hook" commands to be run before, after, or on failure of a backup.
* Better unit tests
