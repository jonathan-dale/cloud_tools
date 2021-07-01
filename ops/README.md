# build the container
```bash
docker build -t my-container .
```

# run the container
```bash
docker run -it --rm my-container
```
> look for the output of start-container.sh

Its good to use the 'exec form' of the ENTRYPOINT or CMD which formats the instructions as a JSON array.
If you dont, the process in the container will spin up a shell that runs the command as PID 1.
The CMD can be overridden by any commnad line args passed in on 'docker run' command; you can also override the ENTRYPOINT command can with the '--entrypoint' flag
> refernece https://www.ctl.io/developers/blog/post/dockerfile-entrypoint-vs-cmd/

