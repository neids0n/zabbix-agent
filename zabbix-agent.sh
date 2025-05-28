#!/bin/bash

# Função para validar IP do servidor Zabbix
valida_ip(){
    echo "Informe o IP do servidor Zabbix: "
    read ip_servidor

    echo "Tem certeza que o IP $ip_servidor está correto? [s/n]"
    read resposta
    if [[ $resposta == "n" ]]; then
        valida_ip
    elif [[ $resposta != "s" ]]; then
        echo "Resposta incorreta"
        valida_ip
    fi
}

valida_ip

# Detectar a distribuição do sistema operacional
if grep -qi "ubuntu\|debian" /etc/os-release; then
    OS="Debian"
elif grep -qi "rhel\|centos\|fedora\|rocky\|alma" /etc/os-release; then
    OS="RedHat"
else
    echo "Sistema operacional não suportado."
    exit 1
fi

# Instalação do agente Zabbix
if [[ $OS == "Debian" ]]; then
    echo "Baixando e instalando repositório Zabbix para Debian/Ubuntu..."
    UBUNTU_VERSION=$(lsb_release -rs)
    wget -q https://repo.zabbix.com/zabbix/7.2/release/ubuntu/pool/main/z/zabbix-release/zabbix-release_latest_7.2+ubuntu${UBUNTU_VERSION}_all.deb
    dpkg -i zabbix-release_latest_7.2+ubuntu${UBUNTU_VERSION}_all.deb
    apt-get update && apt-get install -y zabbix-agent
elif [[ $OS == "RedHat" ]]; then
    echo "Baixando e instalando repositório Zabbix para RedHat..."
    rpm -Uvh https://repo.zabbix.com/zabbix/7.2/release/rhel/$(rpm -E %rhel)/noarch/zabbix-release-latest-7.2.el$(rpm -E %rhel).noarch.rpm
    
    if command -v dnf &> /dev/null; then
        dnf clean all -q
        dnf install -y zabbix-agent
    elif command -v yum &> /dev/null; then
        yum clean all -q
        yum install -y zabbix-agent
    else
        echo "Nenhum gerenciador de pacotes compatível encontrado."
        exit 1
    fi
fi

# Backup do arquivo de configuração do Zabbix Agent
cp /etc/zabbix/zabbix_agentd.conf /etc/zabbix/zabbix_agentd.conf.old

# Configuração do IP do servidor Zabbix
sed -i "s/Server=127.0.0.1/Server=$ip_servidor/g" /etc/zabbix/zabbix_agentd.conf
sed -i "s/ServerActive=127.0.0.1/ServerActive=$ip_servidor/g" /etc/zabbix/zabbix_agentd.conf

# Reiniciar e habilitar o serviço do Zabbix Agent
systemctl restart zabbix-agent
systemctl enable zabbix-agent

# Configuração do firewall
if command -v firewall-cmd &> /dev/null; then
    firewall-cmd --add-port=10050/tcp --permanent
    firewall-cmd --reload
elif command -v iptables &> /dev/null; then
    iptables -I INPUT -p tcp --dport 10050 -j ACCEPT
    iptables-save > /etc/sysconfig/iptables
    echo -e "#!/bin/bash\niptables-restore < /etc/sysconfig/iptables" > /etc/rc.local
    chmod +x /etc/rc.local
    systemctl enable rc-local
    systemctl start rc-local
else
    echo "Nenhum gerenciador de firewall encontrado. Configure manualmente a porta 10050."
fi

echo "Instalação concluída com sucesso!"
