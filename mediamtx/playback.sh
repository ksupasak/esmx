#!/bin/sh
# Called by MediaMTX runOnDemand for paths like:
#   playback/cusys/test/20260408_181112.mp4
# MTX_PATH is set by MediaMTX

RECORDING_KEY=$(echo "$MTX_PATH" | sed 's|^playback/||')
RAILS_URL="http://web:3000/media/recordings/stream_url?key=${RECORDING_KEY}"

# Fetch presigned MinIO URL from Rails (use wget — curl not available)
MINIO_URL=$(wget -q -O - --header="Host: localhost" "$RAILS_URL" 2>/dev/null)

if [ -z "$MINIO_URL" ]; then
  echo "ERROR: could not get stream URL for $RECORDING_KEY" >&2
  exit 1
fi

echo "Streaming $RECORDING_KEY via ffmpeg → $MTX_PATH" >&2

exec ffmpeg -re -i "$MINIO_URL" -c copy -f rtsp -rtsp_transport tcp "rtsp://localhost:8554/$MTX_PATH"
