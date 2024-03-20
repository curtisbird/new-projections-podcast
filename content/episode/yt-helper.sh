#!/bin/bash

# Remove playlist from URL
if [[ $1 == *"list"* ]]; then
    echo "This is a playlist. Please provide a link to a single video."
    exit 1
fi

# Get JSON format of the video
JSON=$(yt-dlp --skip-download --dump-single-json "$1" | jq . )

FILE=$(echo $JSON | jq -r .upload_date).md

TITLE=$(echo $JSON | jq -r .fulltitle | sed -e 's/^New Projections - //' -e 's/^New Projections Podcast - //')

EPISODE=$(tr -d '\n' < ep.txt)

# Begin markdown file
echo "+++" > "$FILE"
echo 'Description = "'$(echo $JSON | jq -r .description)'"' >> "$FILE"
echo "aliases = [\"/$EPISODE\"]" >> "$FILE"
echo 'author = "Curtis Bird"' >> "$FILE"
echo 'date = "'$(echo $JSON | jq -r .upload_date | sed 's/\(....\)\(..\)\(..\)/\1-\2-\3T04:09:45-05:00/')'"' >> "$FILE"
echo 'episode = "'$EPISODE'"' >> "$FILE"

# Download the thumbnail to the img/episode folder
yt-dlp --skip-download --write-thumbnail "$1" -o "../../static/img/episode/$(echo $JSON | jq -r .upload_date)-$(echo $JSON | jq -r .fulltitle)"

echo "episode_image = \"img/episode/$(echo $JSON | jq -r .upload_date)-$(echo $JSON | jq -r .fulltitle).webp\"" >> "$FILE"
echo 'explicit = "false"' >> "$FILE"
#echo 'images = ["img/episode/$(echo $JSON | jq -r .upload_date)-$(echo $JSON | jq -r .fulltitle).jpg"]' >> "$FILE"
echo 'news_keywords = []' >> "$FILE"
echo 'podcast_duration = "'$(echo $JSON | jq -r .duration_string)'"' >> "$FILE"

# Download the audio file to the static/audio folder
FILE_TITLE=$(echo $TITLE | tr '[:upper:]' '[:lower:]' | tr ' ' '-')
yt-dlp -ciwx --embed-thumbnail --add-metadata --audio-format best --audio-format mp3 -o "../../static/audio/$FILE_TITLE.%(ext)s" "$1"

echo "podcast_file = \"audio/$FILE_TITLE.mp3\"" >> "$FILE"
echo 'podcast_bytes = ""' >> "$FILE"
echo "title = \"$TITLE\"" >> "$FILE"
echo 'youtube = "'$(echo $JSON | jq -r .id)'"' >> "$FILE"
echo "+++" >> "$FILE"

# Move file
mv "$FILE" "$TITLE".md

# Increment episode number
echo $((EPISODE+1)) > ep.txt