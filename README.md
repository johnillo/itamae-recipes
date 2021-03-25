# Itamae Recipes

Collection of Itamae scripts for provisioning.


## Setup

### Install Bundler and rbenv

Itamae requires at least Ruby 2.3.0.

1. Install `rbenv` and `ruby-build` via Homebrew (macOS):
    - For Linux distros, use your system's package manager.
    ```
    brew update
    brew install rbenv ruby-build
    ```
2. Setup `rbenv` in your shell by following the printed instructions of the command:
    ```
    rbenv init
    ```
3. Reload your terminal session for the changes to take effect.
4. Install Ruby 2.3.0 and rehash:
    ```
    rbenv install 2.3.0
    rbenv rehash
    ```
5. To use Ruby 2.3.0 as the default on new terminal session, run:
    ```
    rbenv global 2.3.0
    ```
6. Install `bundler`:
    ```
    rbenv exec gem install bundler
    rbenv rehash
    ```
7. Install Itamae and plugins:
    ```
    bundle config set --local path 'vendor/bundle'
    bundle install
    ```

    
## Specify Nodes and Roles

Create separate _nodes_ for each environment. For example:

- `myapp.local`
- `staging.myapp.com`
- `myapp.com`

Use these node names to organize roles, files, templates, and other configuration files.

### Node Configuration

The variables for each nodes are saved in `nodes/<nodename>.yml` files. Cookbooks will use these variables for the appropriate operation.

### Role Configuration

Specify what recipes to execute in `roles/<nodename>.rb` files. For example:

```ruby
# roles/develop.myapp.local.rb
include_recipe '../cookbooks/system'
include_recipe '../cookbooks/docker'
include_recipe '../cookbooks/nginx'
include_recipe '../cookbooks/postgres'
```


## Testing with Serverspec

Specify the test cases in `spec/hostname/all_spec.rb` file. Use to test if target machine meets the required setup.

```
bundle exec rake spec:hostname
```

Register the host name in the `Rakefile` `hosts` variable.


## Available Cookbooks

Cookbooks are tested to run on Ubuntu/Debian based systems. Support for other OSes (e.g. RHEL/CentOS) may be added in some other time.

- Package Update
    - apt update (Debian)
    - apt full-upgrade (Debian)
    - yum update (RHEL)
- System
    - Timezone
    - Locale
- Docker
- MySQL
- Apache


## Creating recipes

Please refer to the Itamae wiki [here](https://github.com/itamae-kitchen/itamae/wiki/Getting-Started).


## Test with Vagrant

### Vagrant Example Configuration

- Apache Reverse Proxy
- MySQL DBMS
- Docker Engine
- Ubuntu 18.04
- ja_JP locale
- UTC Timezone

### Setup

Create a test VM with the help of Vagrant. The included Vagrantfile creates Ubuntu 18.04.

1. Install VirtualBox and Vagrant.
2. Have the following Vagrant plugins installed using `vagrant plugin install <name>`:
    - vagrant-vbguest
    - vagrant-hostsupdater
3. Run the VM using `vagrant up`.
4. Provision the VM:
    `bundle exec itamae ssh --vagrant -h myapp-local roles/myapp.local.rb --node-yaml nodes/myapp.local.yml`
5. Wait until the process is done. It may take some time depending on your system's power and network connection.
6. Go inside the VM using `vagrant ssh` to confirm the changes.


## Disclaimer

Some recipes here may not follow the best or secure practices, so please adjust it accordingly.


## Contributing

I made this for my work and personal use, but feel free to fork and use for your own. If you want to add or update something, submit a PR.
