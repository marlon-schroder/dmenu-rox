#!/bin/sh

app="locate wmctrl xdg-open notify-send lsw dbclient"

for i in $app; do
	[ ! -x "$(type -P $i)" ] && echo "$i not in PATH" && exit 0
done

. $HOME/.config/dmenurc

update_cache() {
	exclude_search=".cache\|sublime_text_3\|sublime-text-3\|chromium\|.icons\|.themes\|.pgadmin\|node_modules\|venv\|busybox\|buildroot\|generated_completions\|scrollback\|.dbus\|.fonts\|.vscode\|Code\|.local"
	locate ~/ | grep -v  $exclude_search > ~/.config/dmenu_search
	#menu=$(mmaker --no-legacy --no-debian -c -t Xterm fluxbox)
	#exclude_menu='exo-open\|xterm\|submenu\|separator\|end\|begin\|exit\|restart\|reconfig\|(Configure)\|(Workspaces)'
	#echo "$menu"|grep -v $exclude_menu|sed 's/.*exec] /drun: /'|sed 's/{//'|sed 's/}//' > ~/.config/dmenu_drun
}

# AWESOME LIST
search=$(cat ~/.config/dmenu_search|sed 's/^./search: \//')
window=$(wmctrl -lx | cut -d '.' -f2-|sed 's/arch//'|nl -w 3 -n rn|sed -r 's/^([ 0-9]+)[ \t]*(.*)$/\1 \2/'|sed 's/  /window: /'|sed 's/ \+/ /g'|sed 's/ /) /3'|sed 's/\s/ (/2;P;D')
#window=$(lsw|cut -d ' ' -f2-|nl -s ' - '|sed 's/^/window: /'|sed -e 's/\s\+/ /g')
ssh=$(echo -e "ssh: marlon@192.168.1.4 -p 2222\nssh: marlon@192.168.1.8")
#drun=$(cat ~/.config/dmenu_drun)
drun=$(echo -e "drun: console.sh\ndrun: chromium-browser\ndrun: terminal\ndrun: jumpapp.sh pcmanfm\ndrun: gcolor2\ndrun: gedit\ndrun: transmission-gtk\ndrun: sublime_text\ndrun: lxappearance\ndrun: hexchat\ndrun: steam\ndrun: skypeforlinux\ndrun: mousepad\ndrun: discord\ndrun: gnome-calculator\ndrun: sqlitebrowser")

# COMMAND
selected=$(echo -e "$window\n>>>; (Text to Search in Google)\n>>>:: (Text to Search in Youtube)\n>>> (Rebuild Cache)\n$ssh\n$drun\n$search"| dmenu $options -p '>>>')

# Verify the selected
w=$(echo $selected|grep 'window:')
r=$(echo $selected|grep 'drun:')
s=$(echo $selected|grep 'search:')
i=$(echo $selected|grep ';')
y=$(echo $selected|grep '::')
c=$(echo $selected|grep 'Rebuild Cache')
h=$(echo $selected|grep 'ssh:')

# Update database files/directories to Search
if [[ ! -z "$c" ]]; then
	update_cache
	notify-send "Rebuild cache done!"
fi

# Youtube Search
if [[ ! -z "$y" ]]; then
	if [[ "$selected" = "$y" ]]; then
		yy=$(echo $y|sed 's/.*:://')
		if [[ $yy != '(Text to Search in Youtube)' && $yy != '' ]]; then
			search=$(echo $yy|cut -d ':' -f3)
			url='https://www.youtube.com/results?search_query='
			#mimeopen "${url}${yy}"
			xdg-open "${url}${yy}"
		fi
	fi
fi

# Google Search
if [[ ! -z "$i" ]]; then
	if [[ "$selected" = "$i" ]]; then
		ii=$(echo $i|sed 's/.*; //')
		if [[ "$ii" != '(Text to Search in Google)' && "$ii" != '' ]]; then
			search=$(echo $ii|cut -d ';' -f2)
			url='https://www.google.com/search?q='
			#mimeopen "${url}${search}"
			xdg-open "${url}${search}"
		fi
	fi
fi

# Window Search
if [[ ! -z "$w" ]]; then
	ww=$(echo $selected | cut -d ' ' -f 2)
	#id_window=$(wmctrl -l | sed -n "$ww p" | cut -c -10)
	wid=$(lsw|sed -n "$ww p")
	[[ ! -z "$wid" ]] && wmctrl -i -a $wid
fi

# Drun Search
if [[ ! -z "$r" ]]; then
	#rr=$(echo $selected | cut -d ')' -f 2)
	rr=$(echo $selected | cut -d ':' -f2-)
	#echo "exec $rr"
	exec $rr
fi

# SSH
if [[ ! -z "$h" ]]; then
	hh=$(echo $selected | cut -d ':' -f2-)
	exec st -c SSH -T SSH -e dbclient $hh
fi

# Files/Directories Search
if [[ ! -z "$s" ]]; then
	ss=$(echo $s|cut -d ' ' -f2)
	#mimeopen -n $ss
	xdg-open $ss
fi
