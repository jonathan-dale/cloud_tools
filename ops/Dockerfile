FROM ubuntu
# let people know how this container was built:
ADD ./Dockerfile /Dockerfile
ADD start-container.sh /usr/bin/start-container
RUN chmod +x /usr/bin/start-container
ENTRYPOINT ["start-container"]

