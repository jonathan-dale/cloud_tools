FROM ubuntu
# let people know how this container was built:
ADD ./Dockerfile /Dockerfile
ADD start-container.sh /usr/bin/start-container
RUN chmod +x /usr/bin/start-container
ENTRYPOINT ["start-container"]

## Its good to use the 'exec form' of the ENTRYPOINT or CMD which formats the instructions as a JSON array.
## If you dont, the process in the container will spin up a shell that runs the command as PID 1.
## Using CMD can be overridden by any commnad line args passed in on 'docker run....' command
## The ENTRYPOINT command can also be overridden but needs the '--entrypoint' flag

# modify start-container.sh to start daemons or run command passed in as args to 'docker run ...'
# To build container: 'docker build -t my-container .'
# To run container:   'docker run -it --rm my-container' and look for the output of start-container.sh
