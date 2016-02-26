Role tests
==========

Bootstrap a Debian 8 (Jessie) installation as follows:

    sudo apt-get install -y curl git python-pip python-dev
    sudo pip install ansible==2.0.1 markupsafe
    git clone https://github.com/varda/ansible-role-varda.git
    cd ansible-role-varda/
    git submodule init
    git submodule update

Then run the tests:

    cd tests/
    ./run.sh
