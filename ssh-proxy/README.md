SSH Proxy
=====================

This is a tool for establishing a routed SSH tunnel into a remote network, for the purpose of performing remote deployments under an additional layer of SSH authentication.


### How it works

This orb is a wrapper around a [`sshuttle`](https://github.com/sshuttle/sshuttle) **client**, which does the following:

* Establishes an SSH tunnel session to the **proxy server** from the **client**;

* Sets up a TCP proxy host locally on the **client**, which receives proxied traffic, disassembles any TCP flows, tunnels them through SSH to a remote Python 3 script on the **proxy server**, and finally re-assembles the flows and send them towards the orginal destination (**remote network servers**);

* For CIDR blocks of the **remote network servers** to be proxied, set up local routes through the proxy host;

* For all DNS requests, tunnel and resolve them through the **proxy server** in order to resolve private DNS hostnames.


### Parameters

* `hostname` (string): the hostname or IP of the SSH **proxy server**;

* `port` (integer): the port of the **proxy server**;

* `username` (string): the UNIX username on the **proxy server**;

* `private_key_fingerprint` (string): the key fingerprint identifying the SSH private key used for the connection, which will be imported from CircleCI settings, where the key must have already been [set up](https://circleci.com/docs/2.0/add-ssh-key/#circleci-cloud);

* `routed_network_cidrs` (string): a space-separated list, such as "10.20.30.0/24 10.20.31.2/32", including all CIDRs in the **remote network** to be routed through the proxy;

* `connection_test_host` (string): the hostname or IP of any single **remote network server**, with which we can check that the SSH tunnel has been established, this server should be a member of `routed_network_cidrs`;

* `connection_test_port` (integer): the port of the **remote network server** for testing the SSH tunnel.
