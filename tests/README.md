Role tests
==========

Bootstrap a Debian 8 (Jessie) installation as follows:

    sudo apt-get install curl git python-pip python-dev
    sudo pip install ansible markupsafe
    git clone https://github.com/varda/ansible-role-varda.git
    cd ansible-role-varda/
    git submodule init
    git submodule update

Then run the tests:

    cd tests/
    ./run.sh


Travis CI
---------

Travis CI runs builds in a Ubuntu 12.04 environment. Because this role
requires systemd, which is not available for Ubuntu 12.04, we cannot currently
run these tests on Travis CI.
