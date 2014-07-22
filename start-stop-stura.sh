#! /bin/sh -e

if [ $USER = "root" ]; then
  profile=$1
  rootmode=$2
  UID=$SUDO_UID
  GID=$SUDO_GID
  HOME=$(getent passwd $SUDO_USER | awk -F ':' '{print $6}')
  if [ $rootmode = "mount" ]; then
    read USR
    read password
  fi
else
  HOME=~
  profile=$(zenity  --list  --title "Profilauswahl" --text "" --radiolist --height 350 --width 200 \
	--column "" --column "Nr." --column "Profil" \
	TRUE "1" "Stura" \
	FALSE "2" "Ref. Soziales" \
	FALSE "3" "Ref. Finanzen" \
	FALSE "4" "Konsul" \
	FALSE "5" "OwnCloud" \
	FALSE "6" "Ref IT" \
	FALSE "7" "Schließsystem" );

  DIR=""
  SRC="@141.24.44.131:/raid/"
  SRCDIR=""
  USR=""
  password=""
  UID=$(id -u)
  GID=$(id -g)
  rootmode=""
fi

INFO=""
INFOU=""
INFOP=""
case ${profile} in
	1)
		DIR=$HOME/StuRa
		#USR="stura"
		#MODE="ssh"
		MODE="smb"
                SRC="//127.0.0.1/stura"
		INFO="Zugangsdaten können auf https://auth.stura.tu-ilmenau.de eingerichtet werden.\nBitte verwende den SGIS-Nutzernamen und das WLAN-Passwort.\n"
		INFOU="SGIS-"
		INFOP="WLAN-"
	;;
	2)
		DIR=$HOME/Soziales
		#SRCDIR="Soziales"
		#USR="soziales"
		#MODE="ssh"
		MODE="smb"
                SRC="//127.0.0.1/soziales"
		INFO="Zugangsdaten können auf https://auth.stura.tu-ilmenau.de eingerichtet werden.\nBitte verwende den SGIS-Nutzernamen und das WLAN-Passwort.\n"
		INFOU="SGIS-"
		INFOP="WLAN-"
	;;
	3)
		DIR=$HOME/Finanzen
		#USR="finanzen"
		#MODE="ssh"
		MODE="smb"
                SRC="//127.0.0.1/finanzen"
		INFO="Zugangsdaten können auf https://auth.stura.tu-ilmenau.de eingerichtet werden.\nBitte verwende den SGIS-Nutzernamen und das WLAN-Passwort.\n"
		INFOU="SGIS-"
		INFOP="WLAN-"
	;;
	4)
		DIR=$HOME/Konsul
		#USR="konsul"
		#MODE="ssh"
		MODE="smb"
                SRC="//127.0.0.1/konsul"
		INFO="Zugangsdaten können auf https://auth.stura.tu-ilmenau.de eingerichtet werden.\nBitte verwende den SGIS-Nutzernamen und das WLAN-Passwort.\n"
		INFOU="SGIS-"
		INFOP="WLAN-"
	;;
	5)
		MODE="davfs"
		DIR=$HOME/owncloud
		INFO="Zugangsdaten können auf https://helfer.stura.tu-ilmenau.de/sgis eingerichtet werden.\nBitte verwende den SGIS-Nutzernamen und das SGIS-Passwort.\n"
		INFOU="SGIS-"
		INFOP="SGIS-"
	;;
	6)
		DIR=$HOME/Admin
		MODE="smb"
                SRC="//127.0.0.1/admin"
		INFO="Zugangsdaten können auf https://auth.stura.tu-ilmenau.de eingerichtet werden.\nBitte verwende den SGIS-Nutzernamen und das WLAN-Passwort.\n"
		INFOU="SGIS-"
		INFOP="WLAN-"
	;;
	7)
		DIR=$HOME/Schliesser
		MODE="smb"
                SRC="//127.0.0.1/schliesser"
		INFO="Zugangsdaten können auf https://auth.stura.tu-ilmenau.de eingerichtet werden.\nBitte verwende den SGIS-Nutzernamen und das WLAN-Passwort.\n"
		INFOU="SGIS-"
		INFOP="WLAN-"
	;;
	*)
		exit
esac

if [ "$DIR" = "" ]; then
 zenity --warning --timeout 3 --title "Unzulässige Eingabe" --text "Versuche erneute Verbindung" || true
 exec $0 $1 $2
 exit
fi

if [ "$SRCDIR" = "" ]; then 
 SRCDIR="$USR"
fi

if [ $USER != "root" -a -e "$DIR" ]; then
 zenity --warning --timeout 3 --title "Beende Verbindung" --text "Beende Verbindung zum Server..." || true
 case ${MODE} in
  "davfs" | "sshfs")
   fusermount -u "$DIR" || true
  ;;
  "smb")
   sudo -H $0 $profile umount
 esac;

 rmdir "$DIR" || true
 if [ -e "$DIR" ]; then
  mv "$DIR" "$DIR"$(date +%s)
 fi
 exit
fi
if [ $USER = "root" -a $rootmode = "umount" -a -e "$DIR" ]; then
  fusermount -u "$DIR" || true
  exit
fi
if [ $USER = "root" -a $rootmode != "mount" ]; then
  exit
fi

if [ $USER != "root" -a -z "$USR" ]; then
 USR=$(zenity --entry --text "${INFO}${INFOU}Nutzername eingeben:" --title "${INFOU}Nutzername")
fi
if [ -z "$USR" ]; then
 exit;
fi

if [ $USER != "root" -a -z "$password" ]; then
 password=$(zenity --entry --hide-text --text "${INFO}${INFOP}Passwort für $USR eingeben:" --title "${INFOP}Passwort")
fi
if [ -z "$password" ]; then
 exit;
fi

if [ $USER != "root" ]; then
 mkdir "$DIR"
fi

case ${MODE} in
	"davfs")
		( echo "$USR\n$password\nj\n" | wdfs https://box.stura.tu-ilmenau.de/owncloud/files/webdav.php "$DIR"  && nautilus "$DIR") || (rmdir "$DIR" && zenity --warning --timeout 3 --title "Verbindung fehlgeschlagen" --text "Versuche erneute Verbindung"; $0 $1 $2; exit 1) || exit
	;;
	"ssh")
		# Der Host muss in /etc/ssh/ssh_known_hosts oder ~/.ssh/known_hosts eingetragen sein
		(echo $password | sshfs $USR$SRC$SRCDIR $DIR -o idmap=user -o password_stdin -o uid=$UID -o gid=$GID && nautilus "$DIR") || (rmdir "$DIR" && zenity --warning --timeout 3 --title "Verbindung fehlgeschlagen" --text "Versuche erneute Verbindung"; $0 $1 $2; exit 1) || exit
	;;
	"smb")
          if [ $USER = "root" ]; then
           PASSWD="$password" smbmount "$SRC" "$DIR" -o "username=$USR,uid=$UID,gid=$GID" || exit $?
          else
           ((echo "$USR"; echo "$password") | sudo -H $0 $profile mount && nautilus "$DIR") || (rmdir "$DIR" && zenity --warning --timeout 3 --title "Verbindung fehlgeschlagen" --text "Versuche erneute Verbindung"; $0 $1 $2; exit 1) || exit
         fi
	;;
esac

exit

