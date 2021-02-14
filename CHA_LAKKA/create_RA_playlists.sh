#!/bin/bash

# Path to get thumbnails. Leave empty to skip.
BOXARTS="/mnt/e/MAMEUI64/flyers"
SNAPS="/mnt/e/MAMEUI64/snap"
TITLES="/mnt/e/MAMEUI64/titles"

# Path to set base for roms in playlists
BASEPATH="/storage/roms"
#DEFAULTCOREPATH="/tmp/cores/fbneo_libretro.so"
#DEFAULTCORENAME="Arcade (FinalBurn Neo)"
DEFAULTCOREPATH="/tmp/cores/mame2003_plus_libretro.so"
#DEFAULTCORENAME="Arcade (MAME 2003-Plus)"
DEFAULTCORENAME="DETECT"

RUNNINGFROM="$(dirname "$(readlink -f "$0")")"
mkdir -p "$RUNNINGFROM/playlists"

PREVIOUSPLAYLISTNAME=""
while read -r ZIPFILE; do
  ROMNAME=${ZIPFILE##*/}; ROMNAME=${ROMNAME%.zip}
  GAMENAME="$(grep -m 1 "$ROMNAME " "$RUNNINGFROM/games_names.txt")"
  if [ -n "$GAMENAME" ]
  then
    # Game name found
    GAMENAME=${GAMENAME#*\"}; GAMENAME=${GAMENAME%\"*}; GAMENAME=${GAMENAME%% /*}; GAMENAME=${GAMENAME%%/*}; GAMENAME=${GAMENAME%% \(*}; GAMENAME=${GAMENAME%% \[*}
    THUMBNAME=${GAMENAME//\&/_}; THUMBNAME=${THUMBNAME//\*/_}; THUMBNAME=${THUMBNAME//\//_}; THUMBNAME=${THUMBNAME//\:/_}; THUMBNAME=${THUMBNAME//\`/_}; THUMBNAME=${THUMBNAME//\</_}; THUMBNAME=${THUMBNAME//\>/_}; THUMBNAME=${THUMBNAME//\?/_}; THUMBNAME=${THUMBNAME//\\/_}; THUMBNAME=${THUMBNAME//\|/_}
    PLAYLISTNAME=${ZIPFILE%/*}; PLAYLISTNAME=${PLAYLISTNAME#"$RUNNINGFROM/roms/"}; PLAYLISTNAME=${PLAYLISTNAME//\//" - "}
    if [ "$PLAYLISTNAME" = "$PREVIOUSPLAYLISTNAME" ]
    then
      # Echo one dot for each ROM added to the playlist
      echo -n "."
      echo "," >> "$RUNNINGFROM/playlists/$PLAYLISTNAME.lpl"
    else
      if [ -n "$PREVIOUSPLAYLISTNAME" ]
      then
        # Close previous playlist if we are not in the first playlist of all
        echo -e "\n]\n}" >> "$RUNNINGFROM/playlists/$PREVIOUSPLAYLISTNAME.lpl"
      fi
      # Start a new playlist
      echo -en "\nCreating \"$PLAYLISTNAME\"."
      echo -e "{\n\"version\": \"1.4\",\n\"default_core_path\": \"$DEFAULTCOREPATH\",\n\"default_core_name\": \"$DEFAULTCORENAME\",\n\"base_content_directory\": \"$BASEPATH\",\n\"label_display_mode\": 0,\n\"right_thumbnail_mode\": 0,\n\"left_thumbnail_mode\": 0,\n\"sort_mode\": 0,\n\"items\": [\n" >> "$RUNNINGFROM/playlists/$PLAYLISTNAME.lpl"
    fi
    # Write game to playlist
    echo -ne "{\n\"path\": \"${ZIPFILE/$RUNNINGFROM\/roms/$BASEPATH}\",\n\"label\": \"$GAMENAME\",\n\"core_path\": \"DETECT\",\n\"core_name\": \"DETECT\",\n\"crc32\": \"DETECT\",\n\"db_name\": \"$PLAYLISTNAME.lpl\"\n}" >> "$RUNNINGFROM/playlists/$PLAYLISTNAME.lpl"
    PREVIOUSPLAYLISTNAME="$PLAYLISTNAME"
    if [ -n "$BOXARTS" ]
    then
      mkdir -p "$RUNNINGFROM/thumbnails/$PLAYLISTNAME/Named_Boxarts"
      if [ -f "$BOXARTS/$ROMNAME.png" ]
      then
        cp "$BOXARTS/$ROMNAME.png" "$RUNNINGFROM/thumbnails/$PLAYLISTNAME/Named_Boxarts/$THUMBNAME.png"
      else
        # If no thumbnail image found, create empty file so we can look for it
        touch "$RUNNINGFROM/thumbnails/$PLAYLISTNAME/Named_Boxarts/$THUMBNAME.png"
      fi
    fi
    if [ -n "$SNAPS" ]
    then
      mkdir -p "$RUNNINGFROM/thumbnails/$PLAYLISTNAME/Named_Snaps"
      if [ -f "$SNAPS/$ROMNAME.png" ]
      then
        cp "$SNAPS/$ROMNAME.png" "$RUNNINGFROM/thumbnails/$PLAYLISTNAME/Named_Snaps/$THUMBNAME.png"
      else
        # If no thumbnail image found, create empty file so we can look for it
        touch "$RUNNINGFROM/thumbnails/$PLAYLISTNAME/Named_Snaps/$THUMBNAME.png"
      fi
    fi
    if [ -n "$TITLES" ]
    then
      mkdir -p "$RUNNINGFROM/thumbnails/$PLAYLISTNAME/Named_Titles"
      if [ -f "$TITLES/$ROMNAME.png" ]
      then
        cp "$TITLES/$ROMNAME.png" "$RUNNINGFROM/thumbnails/$PLAYLISTNAME/Named_Titles/$THUMBNAME.png"
      else
        # If no thumbnail image found, create empty file so we can look for it
        touch "$RUNNINGFROM/thumbnails/$PLAYLISTNAME/Named_Titles/$THUMBNAME.png"
      fi
    fi
  else
    # Game name not found
    echo -n "(Game \"$ROMNAME\" not found)"
  fi
done <<EOF1
$(find "$RUNNINGFROM/roms" -name '*.zip' -mindepth 2 -type f -print 2> /dev/null | sort -f)
EOF1

echo -e "\nDone."

