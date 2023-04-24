#!/bin/bash

# Instalação do agent zabbix
apt-get update && apt-get install zabbix-agent -y && \
# Backup do arquivo zabbix_agentd.conf original
cp /etc/zabbix/zabbix_agentd.conf /etc/zabbix/zabbix_agentd.conf.old && \
# Alteração do IP do servidor
sed -i 's/Server=127.0.0.1/Server=IP_DO_SERVIDOR/g' /etc/zabbix/zabbix_agentd.conf && \
sed -i 's/ServerActive=127.0.0.1/ServerActive=IP_DO_SERVIDOR/g' /etc/zabbix/zabbix_agentd.conf && \
# Reiniciar e habilitar o serviço do zabbix na inicialização do servidor
/etc/init.d/zabbix-agent restart && systemctl enable zabbix-agent.service && \
# Criação de regra do Iptables para habilitar porta 10050
echo '#!/bin/bash' > iptables.sh && \
echo -e "iptables -I INPUT -p tcp --dport 10050 -j ACCEPT\niptables-save" >> iptables.sh && \
# Habilitar regra do Iptables para carregar na inicialização do servidor
chmod +x iptables.sh && cp iptables.sh /etc/rc.local && chmod +x /etc/rc.local && \
systemctl enable rc-local && systemctl start rc-local