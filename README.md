# audio-representation-docker

Audio representations (Wavenet, OpenL3, Coala), dockerized

Docker based upon deepo:

python generate.py Dockerfile pytorch tensorflow==1.13.1 python==3.7 --cuda-ver 11

and then adapted. Dockerfile is based upon:
```
cat Dockerfile.deepo Dockerfile.more >> Dockerfile
```

```
docker pull turian/audio-representations
# Or, build the docker yourself
#docker build -t turian/audio-representations .
docker run --rm --mount source=`pwd`/output,target=/home/dx7/output,type=bind -it turian/audio-representations bash
```
