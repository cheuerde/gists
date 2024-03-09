# Befehl 'sed'

sed 's/AA/0/g' phen_gen.txt >phen_gen_neu.txt



# ein programm lokal ausführen:

./


# Inhalt eines Verzeichnis anzeigen  mit farbiger darstellung

ls -al

# erste zeile einer datei löschen

perl -pi -e '$_ = "" if ($. == 1);' filename 


# head mit pipe für seitenweise darstellung


head plink.ped | more


# Mit sed 'NA' s in 'N' s umwandeln, x20 steht für ein leerzeichen


sed -e's/\x20NA/\x20N/g' plink.ped > plink2.ped




# eine nicht ausführbare datei ausführbar machen, und: befehle, die man z.B. in eine Textdatei reinschreibt und abspeichert, ausführbar machen!
# so eine Befehlsdatei muss als erste Zeile folgendes aufweisen (mit Raute):


#!/bin/bash  
Behle ....

# Ausführbar machen
chmod +x 'dateiname'


# aktuell laufende Prozesse anzeigen


 ps -aux


# einen prozess beenden


kill -9 'prozessnummer'  (zweite spalte bei der 'ps -aux' ausgabe)


# Taskmanager / AUslastung

top

xosview &


# Programmausführung vom Terminal trennen (Programm läuft auf Server weiter auch wenn Verbindung zum User beendet wird)


nohup 'Befehle' &


# Programm nach Ausführung in 'nohup' bringen

[crtl]+z
bg

disown -h


# Dateien von einem Rechner zum nächsten (über SCP):



rsync -av /home/claas/Alphadrop/SimulatedData cheuer@ant160:'Zielverzeichis' (z.B.: ~)



oder mit(für eine Datei): scp ...

# R pakete unter Unix installieren

R CMD INSTALL ggplot2_0.9.0.tar.gz



# Dateien (tar.gz) entpacken

tar xvfz filename.tar.gz

# Spalte herausschneiden

cat somefile | awk '{$1=""; print $0}' #$1 meint erste spalte, geht mit jeder



# Spalten und Zeilen zählen

awk -F'\x09' '{print NF; exit}' 'dateiname'
awk 'END{print NR}' 



# PDF Mergen

gs -dNOPAUSE -sDEVICE=pdfwrite -sOUTPUTFILE=merged.pdf -dBATCH KAKI_yddmg.pdf KAKI_ydekg.pdf KAKI_ydepr.pdf KAKI_ydfkg.pdf KAKI_ydfpr.pdf KAKI_ydmkg.pdf KAKI_ydscs.pdf


# .pdf Datei zu .jpg konvertieren

convert -density 600 KAKI_yddmg.pdf KAKI_yddmg.jpg


# Spaltenwerte verändern (Spalte drei wird mit 0 gefüllt)

awk '{$3 =0;print}' Dateiname 

# tar.gz eines ordners erstellen

tar -zcvf fleckvieh_phenos.tar.gz /work5/suatt361/fleckvieh_impute/All/fleckvieh_phenos


# diese wieder entpacken:

tar -zxvf fleckvieh_phenos.tar.gz.tar.gz

# .pdf zu .eps konvertieren

pdftops -eps teide.pdf test.eps

# Ersten 4 elmente einer zeile entfernen:

sed 's/^.\{4\}//'  tiere

# system summary

sudo lshw -html > system.html && xdg-open ./system.html

####  Laptop

# install intel drivers and recognize Intel HD

sudo apt-add-repository ppa:glasen/intel-driver
sudo apt-get update
sudo apt-get install xserver-xorg-video-intel

sudo apt-get install mesa-utils

# right mouse botton touch pad

sudo su
echo options psmouse proto=exps > /etc/modprobe.d/psmouse.modprobe
reboot

# turn off ati

# add the following lines into /etc/rc.local right before 'exit 0'


modprobe radeon
echo OFF > /sys/kernel/debug/vgaswitcheroo/switch

