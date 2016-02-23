#!/bin/bash
# Telegram com graficos
# Diego Maia - diegosmaia@yahoo.com.br Telegram - @diegosmaia
MAIN_DIRECTORY="/usr/lib/zabbix/alertscripts/"

############################################
# GroupId do exemplo, tem que modificar
############################################
USER=-57169325
############################################

USER=$1
SUBJECT=$2
TEXT=$3
TEXT = TEXT.replace('/n','\n')

############################################
# IP do seu zabbix server
############################################
ZABBIX_SERVER_IP=192.168.10.24

############################################
# O Bot-Token do exemplo, tem que modificar
############################################
BOT_TOKEN='161080402:AAGah3HIxM9jUr0NX1WmEKX3cJCv9PyWD58'

############ Debug ##################
#echo "$USER $SUBJECT $TEXT" >> /tmp/telegram-teste
######## Envio Mensagem ############
curl -s -X GET "https://api.telegram.org/bot$BOT_TOKEN/sendMessage?chat_id=$USER&text=$SUBJECT"

##### Envio dos graficos ###########
GRAPHID=$TEXT
#echo $GRAPHID >> /tmp/telegram-teste

############################################
# Caso queriam o gráfico diferentes de 3h e 1d modifiquem baixo o period=10800 que é 3600 * 3h
############################################
wget --load-cookies=/tmp/cookies.txt -O /tmp/graph3h.png -q "http://$ZABBIX_SERVER_IP/zabbix/chart.php?&itemids[0]=$GRAPHID&type=0&updateProfile=1&profileIdx=web.item.graph&period=10800&width=800"

wget --load-cookies=/tmp/cookies.txt -O /tmp/graph1d.png -q "http://$ZABBIX_SERVER_IP/zabbix/chart.php?&itemids[0]=$GRAPHID&type=0&updateProfile=1&profileIdx=web.item.graph&period=86400&width=800"

curl -s -X POST "https://api.telegram.org/bot$BOT_TOKEN/sendPhoto" -F chat_id="$USER" -F photo="@/tmp/graph3h.png"
curl -s -X POST "https://api.telegram.org/bot$BOT_TOKEN/sendPhoto" -F chat_id="$USER" -F photo="@/tmp/graph1d.png"
####################################
exit 0

