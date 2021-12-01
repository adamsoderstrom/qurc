init () {
	fswatch -0 -n -e ".*" --include "\.mov$" "/Users/$(id -un)/Desktop" | while read -d "" event
	do
		event_file_path="${event%.mov*}.mov"
		event_numerical_value=${event##*.mov}

		if [[ $event_numerical_value -eq "576" ]]
		then
			ffprobe -v error -hide_banner -select_streams v:0 -show_entries format_tags=major_brand -of default=noprint_wrappers=1 "${event_file_path}" | grep "qt" &> /dev/null
			is_quicktime_file="$?"

			echo "is quicktime file:"
			echo $is_quicktime_file

			if [ $is_quicktime_file == "0" ]
			then
				echo "Converting..."
				ffmpeg -i "${event_file_path}" -vcodec libx264 -crf 24 "${event_file_path%.mov}.mp4" 2>&1 | sed -n 's/Duration: \(.*\), start/\1/gp'

				# Conversion completed
				if [ $? ]
				then
					echo "Removing '${event_file_path}'..."
					rm "${event_file_path}"
					echo "Done"
				fi
			fi
		fi
	done
}

init