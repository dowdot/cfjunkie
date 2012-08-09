# CFJunkie

Retrieve and store Cisco switch configurations in git.  Thats is all.

## Background

I was tasked with getting our switch configurations into git.  I was told to look at rancid since it was well suited for this sort of thing.  What did not appeal to me was the lack of git support, and that it emailed diffs of the configuration around.  In my opinion, if you are using eamil as a notification framework of any kind, you are doing something wrong.  So since I just needed git, and I didn't care about email, that was 90% of rancid that I didn't need.

Once I had worked out creating a RO user on the switches, and I could dump the config remotely, I was convinved.  Net/ssh was able to handle all the password issues that I had seen others using expect to solve without any special tweaking.  Kinda cool.

## Basic Usage

You simply execute the script with the following command:

    ./bin/cfjunkie -c etc/cfjunkie.yaml

Sample configuration:

    ---
    :username: 'monitor'
    :password: 'secret'
    :storage: '/opt/admin/netconfigs'
    :path: '/configs'
    :gitrepo: 'git@git.example.net:admin/switches.git'
    :switchlist: - switch1.example.net
                 - switch2.example.net
                 - switch3.example.net

* :storage: is the location on disk where the :gitrepo: will be cloned.
* :path: is the location under the :storage: directory where the files will actually be placed.

## A word on password storage

Since on our switches we are using secret, the configs contain the hashed password for the users.  I didn't want to commit this to git, so I did some quick substitution to replace the password with the word 'sneakybeast'.  This seems sane enough for our use case, but I only tested using a couple switches of the same IOS version, and only a single method of password storage.

Its possible that in your environment, password obfuscation may be different, and it may be worth double checking before you commit your md5 to the git repo.  Just a thought.

## Authors

Zach Leslie <xaque208@gmail.com>
