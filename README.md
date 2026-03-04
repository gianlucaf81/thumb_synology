# thumb_synology
Script for generating thumbnails icons for video files viewable in File Station on Synology NAS.

The thumbnail triptych adapts according to the video orientation.

The thumbnail are also visible in DS File on smartphones.

![](https://github.com/gianlucaf81/thumb_synology/blob/main/media/small.png)
![](https://github.com/gianlucaf81/thumb_synology/blob/main/media/medium.png)


1 - The script requires ffmpeg to be installed (docker)

/docker/docker-compose.yaml
```bash
services:
  ffmpeg:
    image: jrottenberg/ffmpeg:latest
    container_name: ffmpeg
    entrypoint: ["tail", "-f", "/dev/null"]
    volumes:
      - /volume1:/volume1
      - /volume1/docker/script:/scripts
    restart: always
```

2 - Add a task to the Task Scheduler with the folder containing your media. I recommend scheduling it to run every 6-12 hours.
    Files already processed will not be reprocessed.
    In General tab set **root** on User:

```bash
docker exec ffmpeg bash /scripts/thumb_synology.sh "/volume1/YOUR_MEDIA_FOLDER"
```
2.b - If necessary it is possible to force the regeneration of all thumbnails (even those already created) add the ```force``` parameter
```bash
docker exec ffmpeg bash /scripts/thumb_synology.sh "/volume1/YOUR_MEDIA_FOLDER" force
```
