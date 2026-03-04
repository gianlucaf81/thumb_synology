# thumb_synology
Script for generating thumbnails for video files viewable in File Station on Synology NAS

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

2 - Add a task to the Task Scheduler with the folder containing your media

```bash
docker exec ffmpeg bash /scripts/thumb_synology.sh "/volume1/YOUR_MEDIA_FOLDER"
```
