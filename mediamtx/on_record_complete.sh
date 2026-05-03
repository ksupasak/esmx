#!/bin/sh
RAILS_URL="http://web:3000/media/recording_complete"
SECRET="${MEDIAMTX_WEBHOOK_SECRET:-esmx-mediamtx-secret}"
BODY="{\"path\":\"${MTX_PATH}\",\"segment\":\"${MTX_RECORD_SEGMENT_PATH}\"}"

# Retry up to 5 times (Rails may be booting)
ATTEMPTS=0
while [ $ATTEMPTS -lt 5 ]; do
  RESULT=$(wget -q -O - --post-data="$BODY" --header="Content-Type: application/json" --header="Host: localhost" --header="X-Mediamtx-Secret: ${SECRET}" "$RAILS_URL" 2>&1)
  if echo "$RESULT" | grep -q '"status":"queued"'; then
    echo "[on_record_complete] Queued: ${MTX_PATH}" >&2
    exit 0
  fi
  ATTEMPTS=$((ATTEMPTS + 1))
  echo "[on_record_complete] Attempt $ATTEMPTS failed, retrying in 5s..." >&2
  sleep 5
done

echo "[on_record_complete] ERROR: gave up after 5 attempts for ${MTX_PATH}" >&2
exit 1
