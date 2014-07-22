#!/bin/bash

drucker[1]="Kyocera-Mita-KM-4035-StuRa"
drucker[2]="Kyocera-Mita-KM-4035-StuRa-A3-Duplex"
drucker[3]="Kyocera-Mita-KM-4035-StuRa-A3-NoDuplex"
drucker[4]="Kyocera-Mita-KM-4035-StuRa-A4-Duplex-Kassette-1"
drucker[5]="Kyocera-Mita-KM-4035-StuRa-A4-Duplex-Kassette-3"
drucker[6]="Kyocera-Mita-KM-4035-StuRa-A4-NoDuplex-Kassette-1"
drucker[7]="Kyocera-Mita-KM-4035-StuRa-A4-NoDuplex-Kassette-3"

for d in "${drucker[@]}"
  do
    p=$(lpstat -p $d 2>/dev/null)
    if [[ $p == *deaktiviert* || $p == *Paused* || $p == *disabled* ]]
    then
      sudo cupsenable $d
    fi
done
