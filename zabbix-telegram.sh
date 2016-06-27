#!/bin/bash

##########################################################################
# Zabbix-Telegram envio de alerta por Telegram com graficos dos eventos
# Filename: zabbix-telegram.sh
# Revision: 2.1
# Date: 24/04/2016
# Author: Diego Maia - diegosmaia@yahoo.com.br Telegram - @diegosmaia
# Aproveitei algumas coisas:
# Script getItemGraph.sh Author: Qicheng
# https://github.com/GabrielRF/Zabbix-Telegram-Notification @GabrielRF
# Obs.: Caso esqueci de alguem, por favor, me chame no Telegram que adiciono
##########################################################################

MAIN_DIRECTORY="/usr/lib/zabbix/alertscripts/"

USER=$1
SUBJECT=$2
SUBJECT="${SUBJECT//,/ }"
MESSAGE="chat_id=${USER}&text=$3"
GRAPHID=$3
GRAPHID=$(echo $GRAPHID | grep -o -E "(Item Graphic: \[[0-9]{7}\])|(Item Graphic: \[[0-9]{6}\])|(Item Graphic: \[[0-9]{5}\])|(Item Graphic: \[[0-9]{4}\])|(Item Graphic: \[[0-9]{3}\])")
GRAPHID=$(echo $GRAPHID | grep -o -E "([0-9]{7})|([0-9]{6})|([0-9]{5})|([0-9]{4})|([0-9]{3})")

ZABBIXMSG="/tmp/zabbix-message-$(date "+%Y.%m.%d-%H.%M.%S").tmp"

#############################################
# Endereço do Zabbix
#############################################
ZBX_URL="http://192.168.0.102/zabbix"

##############################################
# Conta de usuário para logar no site Zabbix
##############################################

USERNAME="admin"
PASSWORD="zabbix"

############################################
# O Bot-Token do exemplo, tem que modificar
############################################

BOT_TOKEN='161080402:AAGah3HIxM9jUr0NX1WmEKX3cJCv9PyWD58'

#############################################
# Se nao desejar enviar GRAFICO / ENVIA_GRAFICO = 0
# Se nao desejar enviar MESSAGE / ENVIA_MESSAGE = 0
#############################################

ENVIA_GRAFICO=1
ENVIA_MESSAGE=1

# Se não receber o valor de GRAPHID ele seta o valor de ENVIA_GRAFICO para 0

case $GRAPHID in
    ''|*[!0-9]*) ENVIA_GRAFICO=0 ;;
    *) ENVIA_GRAFICO=1 ;;
esac


##############################################
# Graficos
##############################################

WIDTH=800
CURL="/usr/bin/curl"
COOKIE="/tmp/telegram_cookie-$(date "+%Y.%m.%d-%H.%M.%S")"
PNG_PATH="/tmp/telegram_graph-$(date "+%Y.%m.%d-%H.%M.%S").png"

############################################
# Periodo do grafico em minutos Exp: 10800min/3600min=3h 
############################################

PERIOD=10800


###########################################
# Verifica se foi passado os 3 parametros
# para o script
###########################################

if [ "$#" -lt 3 ]
then
	exit 1
fi

############################################
# Envio Mensagem de Texto do Alerta
############################################

echo "$MESSAGE" > $ZABBIXMSG
${CURL} -k -s -c ${COOKIE} -b ${COOKIE} -s -X GET "https://api.telegram.org/bot${BOT_TOKEN}/sendMessage?chat_id=${USER}&text=\"${SUBJECT}\""  > /dev/null

if [ "$ENVIA_MESSAGE" -eq 1 ]
then
	${CURL} -k -s -c ${COOKIE} -b ${COOKIE} --data-binary @${ZABBIXMSG} -X GET "https://api.telegram.org/bot${BOT_TOKEN}/sendMessage"  > /dev/null
fi
############################################
# Envio dos graficos
############################################

# Se ENVIA_GRAFICO=1 ele envia o gráfico.
if [ $(($ENVIA_GRAFICO)) -eq '1' ]; then
	############################################
	# Zabbix logando com o usuário no site
	############################################

   	# Zabbix - Ingles - Verifique no seu Zabbix se na tela de login se o botao de login é "Sign in".
	# Obs.: Caso queira mudar, abra a configuração do usuário Guest e mude a linguagem para Portugues, se fizer isso comente (#) a linha abaixo e descomente a linha Zabbix-Portugues.

    	${CURL} -k -s -c ${COOKIE} -b ${COOKIE} -d "name=${USERNAME}&password=${PASSWORD}&autologin=1&enter=Sign%20in" ${ZBX_URL}"/index.php" > /dev/null

    	# Zabbix - Portugues - Verifique no seu Zabbix se na tela de login se o botao de login é  "Conectar-se".
    	# ${CURL} -k -s -c ${COOKIE} -b ${COOKIE} -d "name=${USERNAME}&password=${PASSWORD}&autologin=1&enter=Conectar-se" ${ZBX_URL}"/index.php" > /dev/null

	# Download do gráfico e envio
	${CURL} -k -s -c ${COOKIE}  -b ${COOKIE} -d "itemids=${GRAPHID}&period=${PERIOD}&width=${WIDTH}" ${ZBX_URL}"/chart.php" -o "${PNG_PATH}"

	${CURL} -k -s -X POST "https://api.telegram.org/bot${BOT_TOKEN}/sendPhoto" -F chat_id="${USER}" -F photo="@${PNG_PATH}" > /dev/null

fi

############################################
# DEBUG
############################################

# Verificar valores recebidos do Zabbix ou do prompt
# cat /tmp/telegram-debug.txt
# echo "User-Telegram=$USER | Subject=$SUBJECT | Menssage=$MESSAGE | GraphID=${GRAPHID} | Period=${PERIOD} | Width=${WIDTH}" >/tmp/telegram-debug.txt

# Teste com curl tentando baixar o gráfico
# Verifique o arquivo /tmp/telegram-graph.png no seu computador para ver se o grafico esta sendo gerado corretamente
# ${CURL} -k -c ${COOKIE}  -b ${COOKIE} -d "graphid=1459&itemids=1459&period=10800&width=800" 192.168.10.24/zabbix/chart.php > /tmp/telegram-graph.png

#Verificando o envio da msg

# Envio da msg de texto
# Gera uma saída no script com algo parecido com isso  {"ok":true,"result":{"message_id":xxx,"from":{"id":xxxx,"first_name":"xxx","username":"xxxx"},"chat":{"id":xxxxx,"first_name":"xxx","last_name":"xxx","username":"xxxxx","type":"private"},"date":xxxx,"text":"teste"}}
# Se gerar uma saida diferente verifique o seu BOT_TOKEN ou então o UserID ou Group-ID para qual a msg esta sendo enviada
# ${CURL} -k -c ${COOKIE} -b ${COOKIE} -X GET "https://api.telegram.org/bot${BOT_TOKEN}/sendMessage?chat_id=${USER}&text=${SUBJECT}"

# Envio do Grafico
# ${CURL} -k -X POST "https://api.telegram.org/bot${BOT_TOKEN}/sendPhoto" -F chat_id="${USER}" -F photo="@${PNG_PATH}"


############################################
# Apagando os arquivos utilizados no script
############################################

rm -f ${COOKIE}
rm -f ${PNG_PATH}
rm -f ${ZABBIXMSG}
exit 0
