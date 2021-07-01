#!/usr/bin/env bash
# this is used as ENTRYPOINT in Dockerfile
# that means this is what runs when docker starts the container.
# We will run any commands passed in or start some daemon proces.
# Add it to the end of a Dockerfile:
## ADD start-container.sh /usr/bin/start-container
## RUN chmod +x /usr/bin/start-container
## ENTRYPOINT ["start-container"]


#########################
# ADD CONFIGURATION HERE  
# this could be for nginx or 
# other configurable daemon
######################### 

if [ ! -d /.composer ] ; then
    mkdir /.composer
fi

chmod -R ugo+rw /.composer

# if commands sent in run them...
# otherwise start some process
if [ $# -gt 0 ] ; then 
   exec "$@"
else
echo "no daemons started"
fi
