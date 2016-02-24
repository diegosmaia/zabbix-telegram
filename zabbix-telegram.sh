#!/bin/bash

# Zabbix-Telegram envio de alerta por Telegram com graficos dos eventos
# Filename: zabbix-telegram.sh
# Revision: 1.0
# Date: 23/02/2016
# Author: Diego Maia - diegosmaia@yahoo.com.br Telegram - @diegosmaia
# Aproveitei algumas coisas do script getItemGraph.sh Author: Qicheng



MAIN_DIRECTORY="/usr/lib/zabbix/alertscripts/"

############################################
# GroupId do exemplo, tem que modificar
############################################

USER=-57169325

############################################

USER=$1
SUBJECT=$2
SUBJECT="${SUBJECT//,/ }"
GRAPHID=$3
ZBX_URL="http://192.168.10.24/zabbix"

##############################################
# Conta de usuário para logar no site Zabbix
##############################################

USERNAME="guest"
PASSWORD=""

##############################################
# Graficos
##############################################

WIDTH=800
GRAPH_DIR="/tmp/graph"
COOKIE="/tmp/zabbix_cookie"
CURL="/usr/bin/curl"
PNG_PATH="/tmp/graph.png"

############################################
# Periodo do grafico em minutos Exp: 10800min/3600min=3h 
############################################

PERIOD=10800

############################################
# O Bot-Token do exemplo, tem que modificar
############################################

BOT_TOKEN='161080402:AAGah3HIxM9jUr0NX1WmEKX3cJCv9PyWD58'


############################################
# DEBUG
############################################

#echo "$USER | $SUBJECT | $GRAPHID" >> /tmp/telegram-teste

############################################
# Zabbix logando com o usuário no site
############################################

# Limpando Cookie
rm -f ${COOKIE}

# Zabbix - Ingles - Botao da tela de login e "Sign in"
#${CURL} -c ${COOKIE} -b ${COOKIE} -d "name=${USERNAME}&password=${PASSWORD}&autologin=1&enter=Sign+in" ${ZBX_URL}"/index.php"

# Zabbix - Portugues - Botao da tela de login e "Conectar-se"
${CURL} -c ${COOKIE} -b ${COOKIE} -d "name=${USERNAME}&password=${PASSWORD}&autologin=1&enter=Conectar-se" ${ZBX_URL}"/index.php"

############################################
# Envio Mensagem de Texto do Alerta
############################################

${CURL} -c ${COOKIE} -b ${COOKIE} -s -X GET "https://api.telegram.org/bot${BOT_TOKEN}/sendMessage?chat_id=${USER}&text=${SUBJECT}"


############################################
# Envio dos graficos 
############################################

# Se existir valor no GRAPHID ele envia
[ -n "$GRAPHID" ] && {

	${CURL} -c ${COOKIE}  -b ${COOKIE} -d "itemids=${GRAPHID}&period=${PERIOD}&width=${WIDTH}" ${ZBX_URL}"/chart.php" > $PNG_PATH
	${CURL} -s -X POST "https://api.telegram.org/bot${BOT_TOKEN}/sendPhoto" -F chat_id="${USER}" -F photo="@/tmp/graph.png"
}

exit 0

