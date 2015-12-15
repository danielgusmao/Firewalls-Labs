#!/bin/bash

#FIREWALL PARA WEBSERVERS - Matheus Fidelis
#

iptables -F

# PERMITINDO SERVIÇOS JÁ INICIADOS:
iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT

#bloqueio de ataques syn
echo 1 > /proc/sys/net/ipv4/tcp_syncookies

#forca resposta na interface de origem
echo 1 > /proc/sys/net/ipv4/conf/default/rp_filter

#bloqueio de ping broadcast
echo 1 > /proc/sys/net/ipv4/icmp_echo_ignore_broadcasts


#Anulando as respostas a ICMP 8 (echo reply)
echo 1 > /proc/sys/net/ipv4/icmp_echo_ignore_all

#Desativar ip_forward
echo 0 > /proc/sys/net/ipv4/ip_forward


#Camadas de proteção contra Scanners de Porta
iptables -A INPUT -p tcp --tcp-flags SYN,ACK,FIN,RST RST -m limit --limit 1/s -j ACCEPT
iptables -A INPUT -p tcp --tcp-flags ALL SYN,ACK -j DROP
iptables -A INPUT -p tcp --tcp-flags ALL FIN,URG,PSH -j DROP


#Bloqueio de ping - Descomente para bloquear o Ping do servidor
#iptables -A INPUT -p icmp --icmp-type echo-request -m limit --limit 1/s -j  DROP

# Abre para a interface de loopback:
iptables -A INPUT -p tcp -i lo -j ACCEPT

# Bloqueia um determinado IP. Use para bloquear hosts específicos:
#iptables -A INPUT -p ALL -s 88.191.79.206 -j DROP

# Abre as portas referentes aos serviços usados:

# SSH:
iptables -A INPUT -p tcp --dport 22 -j ACCEPT

# DNS:
#iptables -A INPUT -p tcp --dport 53 -j ACCEPT
#iptables -A INPUT -p udp --dport 53 -j ACCEPT

# HTTP e HTTPS:
iptables -A INPUT -p tcp --dport 80 -j ACCEPT
iptables -A INPUT -p tcp --dport 443 -j ACCEPT

# FTP
#iptables -A INPUT -p tcp --dport 21 -j ACCEPT

# Bloqueia conexões nas demais portas:
iptables -A INPUT -p tcp --syn -j DROP

# Bloqueia as portas UDP de 0 a 1023 (com exceção das abertas acima):
iptables -A INPUT -p udp --dport 0:1023 -j DROP

# bloqueio de pacotes mal formatados
iptables -A INPUT -m state --state INVALID -j DROP
