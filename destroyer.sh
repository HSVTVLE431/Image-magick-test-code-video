#!/bin/bash

# 1. Check if input file exists
read -p "Select any file: " file1
if [[ ! -f "$file1" ]]; then
    echo "❌ Error: File '$file1' not found."
    exit 1
fi

read -p "Select effects of ImageMagick (e.g., -negate -modulate 120): " file2

mkdir -p framesVideo

# 2. Get frame rate using bc to handle fractions (like 30000/1001)
fr=$(ffprobe -v error -select_streams v:0 -show_entries stream=r_frame_rate -of default=nokey=1:noprint_wrappers=1 "$file1")

out="imtcv.$(openssl rand -hex 4).mp4"

echo "⚙️ Extracting frames..."
ffmpeg -hide_banner -loglevel error -y -i "$file1" "framesVideo/pro%04d.png"

echo "⚙️ Applying ImageMagick effects..."
# We use -set filename:f to maintain a clean sequence and handle the effects properly
magick "framesVideo/pro*.png" $file2 "framesVideo/pro-%d.png"

# Check if magick actually produced files
if [ -z "$(ls -A framesVideo/pro-*.png 2>/dev/null)" ]; then
    echo "❌ An unknown error has occurred during ImageMagick processing!"
    rm -rf framesVideo
    exit 1
fi

echo "⚙️ Rebuilding video... Please wait..."
# Using -start_number 0 because Magick starts its index at 0 by default
ffmpeg -hide_banner -loglevel error -y -r "$fr" -i "framesVideo/pro-%d.png" -i "$file1" \
    -map 0:v:0 -map 1:a? -pix_fmt yuv420p -c:v libx264 -crf 18 -c:a aac -shortest -movflags +faststart "$out"

rm -rf framesVideo
echo "✅ Your video is now finished: $out"
