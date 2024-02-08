#!/bin/bash

# Funzione per generare un file di configurazione con valori casuali
generate_conf_file() {
  cat > "$1" <<EOL
nick $(tr -dc 'a-zA-Z' < /dev/urandom | head -c 8)
ident $(tr -dc 'a-zA-Z' < /dev/urandom | head -c 8)
realname $(tr -dc 'a-zA-Z0-9' < /dev/urandom | head -c 8)
logfile Knb$1.log
nicks $2
channel #channels password
vhost 0.0.0.0
server $3 6667
ctcptype 2
ctcpreply xchat
reason xchat_part
EOL
}

# Funzione per ottenere un nuovo nome per il file di configurazione
get_new_conf_name() {
  local i=1
  local new_name="conf$i"
  
  while [ -e "$new_name" ]; do
    ((i++))
    new_name="conf$i"
  done

  echo "$new_name"
}

# Funzione per avviare il programma con i file di configurazione
start_program() {
  for file in "$@"; do
    proxychains ./knb "$file" &
  done
  wait
}

# Menu interattivo
echo "Menu:"
echo "1 - Specificare il numero di knb"
echo "2 - Pulisci la cartella"
read -p "Scegli un'opzione (1 o 2): " choice

# Opzione 1: Generare i file di configurazione e avviare il programma
if [ "$choice" == "1" ]; then
  read -p "Specificare il numero di knb: " num_files
  read -p "Inserisci i nomi dei 'nicks' separati da spazio: " nicks_list
  read -p "Quale 'server' vuoi utilizzare?: " server_address

  for ((i=1; i<=$num_files; i++)); do
    new_conf_name=$(get_new_conf_name)
    generate_conf_file "$new_conf_name" "$nicks_list" "$server_address"
  done

  start_program $(ls -v conf*)

  echo "File di configurazione generati e programma avviato con successo."

# Opzione 2: Pulisci la cartella
elif [ "$choice" == "2" ]; then
  rm -f conf*
  rm -rf pid.*
  rm -rf *.log
  rm -rf log.*
  pkill -9 knb
  rm -rf *.uf
  echo "Cartella pulita."

# Opzione sconosciuta
else
  echo "Scelta non valida."
  exit 1
fi
