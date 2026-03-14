mkdir framesVideo
fr=$(ffprobe -v error -select_streams v:0 -show_entries stream=r_frame_rate -of default=nokey=1:noprint_wrappers=1 distort.resize.mov)
rand=out_$RANDOM.mp4
ffmpeg -r $fr -i $1 "framesVideo/frame%4d.png"
magick "framesVideo/frame*.png" $2 "framesVideo/processed.png"
ffmpeg -r $fr -i "framesVideo/processed-%d.png" -i $1 -map 0:v -map 1:a -pix_fmt yuv420p -c:v libx264 -c:a aac $rand
rm -rf framesVideo
