#!/bin/bash

# Solicita e valida IP do servidor zabbix
valida_ip(){
    echo "Informe o IP do servidor zabbix: "
    read ip_servidor

    echo "Tem certeza que o IP $ip_servidor está correto [s/n]?"
    read resposta
    if [ $resposta = n ]
    then
        valida_ip
    else
        if [ $resposta != s ]
        then
            echo "Resposta incorreta"
            valida_ip
        fi
    fi
}
valida_ip
# Instalação do agent zabbix
apt-get update && apt-get install zabbix-agent -y && \
# Backup do arquivo zabbix_agentd.conf original
cp /etc/zabbix/zabbix_agentd.conf /etc/zabbix/zabbix_agentd.conf.old && \
# Alteração do IP do servidor
sed -i 's/Server=127.0.0.1/Server='$ip_servidor'/g' /etc/zabbix/zabbix_agentd.conf && \
sed -i 's/ServerActive=127.0.0.1/ServerActive='$ip_servidor'/g' /etc/zabbix/zabbix_agentd.conf && \
# Reiniciar e habilitar o serviço do zabbix na inicialização do servidor
/etc/init.d/zabbix-agent restart && systemctl enable zabbix-agent.service && \
# Criação de regra do Iptables para habilitar porta 10050
echo '#!/bin/bash' > iptables.sh && \
echo -e "iptables -I INPUT -p tcp --dport 10050 -j ACCEPT\niptables-save" >> iptables.sh && \
# Habilitar regra do Iptables para carregar na inicialização do servidor
chmod +x iptables.sh && cp iptables.sh /etc/rc.local && chmod +x /etc/rc.local && \
systemctl enable rc-local && systemctl start rc-local