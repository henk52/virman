# virman
Virtual machine manager, a virsh wrapper in PERL.

TODO Read the install wrapper, if the app references one.
  - GetVNics
  - GetFileProvided
  - GetPreAppRunCommand
  - GeTPostAppRunCommand
TODO Merge the data from the install wrapper with the Instance data
  - e.g. the run commands, file commands and network.
  - index of -1, -2 etc indicates the order they are appended to the network list.
    -1: becomes the first vnic after the app instance vnics. etc.
TODO get the 'configuration' network to work.
TODO get the app files added.
TODO install the app (files)

TODO make virman-clone.pl support multiple roles
  verify that the role exists

