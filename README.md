# 🔨 zabbix-agent
<img alt="GitHub last commit" src="https://img.shields.io/github/last-commit/neids0n/zabbix-agent">
Instalação e configuração do agent Zabbix no linux

## ✔️  O script executa as seguintes ações:

- Instalação do agent zabbix
- Backup do arquivo zabbix_agentd.conf original
- Alteração do IP do servidor no arquivo zabbix_agentd.conf
- Reiniciar e habilitar o serviço do zabbix na inicialização do servidor
- Criação de regra do Iptables para habilitar porta 10050
- Habilitar regra do Iptables para carregar na inicialização do servidor
