FROM blacklabelops/volumerize

# disable host key checking and set identity file to /keys/id_rsa
ADD ssh_config /etc/ssh/ssh_config 

# install the pexpect python package, which is needed for the pexpect 
# backend of dublicity. This is the only backend for ssh or scp that respect
# ssh_config settings
RUN pip install pexpect