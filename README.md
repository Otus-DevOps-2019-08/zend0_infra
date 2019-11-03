# zend0_infra
zend0 Infra repository

# Подключение ко внутреннему серверу по SSH через bastion-сервер
Для подключения одной строкой
```shell script
ssh -o ProxyCommand='ssh -l appuser <bastion_ip> nc <vm_ip>>' -l appuser <vm_ip>
```
если по проще и по имени то, необходимо в `~/.ssh/config` добавить следующее:

```shell script
Host someinternalhost
  Hostname     <vm_ip>
  Port         22
  User         appuser
  IdentityFile ~/.ssh/id_ed25519
  ProxyCommand ssh <bastion_ip> nc %h %p
```

и подключиться к внутреннему серверу:
```shell script
ssh someinternalhost
```

# Подключение ко внутреннему серверу по VPN через bastion-сервер
Для подключения к VPN необходимо на клиенте поставить следующие пакеты:
```shell script
sudo apt install network-manager-openvpn
sudo apt install network-manager-openvpn-gnome
```
импортировать `cloud-bastion.ovpn`, после подключения к VPN-серверу можно подключаться ко внутренним серверам.

Пример адресации для задания
```
bastion_IP = 35.206.160.227
someinternalhost_IP = 10.156.0.5
```
