#!/bin/bash
BASE="$1"
FORCE="$2" # Passa 'force' per rigenerare

log() { echo "[$(date +'%H:%M:%S')] $1"; }

if [ -z "$BASE" ]; then
    log "ERRORE: Specifica una cartella."
    exit 1
fi

find "$BASE" -type d \( -name "@eaDir" -o -name "#recycle" \) -prune -o -type f \( -iname "*.mp4" -o -iname "*.mkv" -o -iname "*.avi" -o -iname "*.mpg" -o -iname "*.mpeg" -o -iname "*.mov" \) -print | while read -r FILE
do
    DIR=$(dirname "$FILE")
    NAME=$(basename "$FILE")
    EADIR="$DIR/@eaDir/$NAME"
    
    # RIGENERAZIONE: Se passi 'force', cancella la vecchia thumb
    if [ "$FORCE" == "force" ]; then rm -f "$EADIR/SYNOPHOTO_THUMB_M.jpg"; fi
    if [ -f "$EADIR/SYNOPHOTO_THUMB_M.jpg" ]; then continue; fi

    mkdir -p "$EADIR"

    # RECUPERO DATI (Documentazione ufficiale ffprobe)
    W=$(ffprobe -v error -select_streams v:0 -show_entries stream=width -of default=noprint_wrappers=1:nokey=1 "$FILE" | head -n 1)
    H=$(ffprobe -v error -select_streams v:0 -show_entries stream=height -of default=noprint_wrappers=1:nokey=1 "$FILE" | head -n 1)
    ROT=$(ffprobe -v error -select_streams v:0 -show_entries stream_side_data=rotation -of default=noprint_wrappers=1:nokey=1 "$FILE" | tr -d '-' | cut -d'.' -f1)
    DUR=$(ffprobe -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 "$FILE" | cut -d'.' -f1)

    # Gestione rotazione reale
    if [[ "$ROT" == "90" || "$ROT" == "270" ]]; then
        REAL_W=$H; REAL_H=$W
    else
        REAL_W=$W; REAL_H=$H
    fi

    # Fallback di sicurezza
    [[ -z "$DUR" || "$DUR" -eq 0 ]] && DUR=10
    T1=$(awk "BEGIN {print int($DUR * 0.2)}"); T2=$(awk "BEGIN {print int($DUR * 0.5)}"); T3=$(awk "BEGIN {print int($DUR * 0.8)}")

    log "Processing $NAME (Orientamento: ${REAL_W}x${REAL_H})"

    if [ "$REAL_W" -ge "$REAL_H" ]; then
        # Video Orizzontale -> 3 frame uno SOPRA l'altro (VSTACK)
        ffmpeg -nostdin -y -v error -ss "$T1" -i "$FILE" -ss "$T2" -i "$FILE" -ss "$T3" -i "$FILE" \
        -filter_complex "[0:v]scale=320:-2[v0];[1:v]scale=320:-2[v1];[2:v]scale=320:-2[v2];[v0][v1][v2]vstack=inputs=3" \
        -frames:v 1 -q:v 2 "$EADIR/SYNOPHOTO_THUMB_M.jpg"
    else
        # Video Verticale -> 3 frame uno AFFIANCO all'altro (HSTACK)
        ffmpeg -nostdin -y -v error -ss "$T1" -i "$FILE" -ss "$T2" -i "$FILE" -ss "$T3" -i "$FILE" \
        -filter_complex "[0:v]scale=-2:320[v0];[1:v]scale=-2:320[v1];[2:v]scale=-2:320[v2];[v0][v1][v2]hstack=inputs=3" \
        -frames:v 1 -q:v 2 "$EADIR/SYNOPHOTO_THUMB_M.jpg"
    fi

    # Genera la Small al 50%
    if [ -f "$EADIR/SYNOPHOTO_THUMB_M.jpg" ]; then
        ffmpeg -nostdin -y -v error -i "$EADIR/SYNOPHOTO_THUMB_M.jpg" -vf "scale=iw*0.5:-2" -q:v 4 "$EADIR/SYNOPHOTO_THUMB_S.jpg"
    fi
    chmod 644 "$EADIR"/*.jpg
done