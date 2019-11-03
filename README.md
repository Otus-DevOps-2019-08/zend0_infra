# zend0_infra
zend0 Infra repository

# Подключение к GCP
## Подключение ко внутреннему серверу по SSH через bastion-сервер
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

## Подключение ко внутреннему серверу по VPN через bastion-сервер
Для подключения к VPN необходимо на клиенте поставить следующие пакеты:
```shell script
sudo apt install network-manager-openvpn
sudo apt install network-manager-openvpn-gnome
```
импортировать `cloud-bastion.ovpn`, после подключения к VPN-серверу можно подключаться ко внутренним серверам.

_Данные для проверки задания_
```
bastion_IP = 35.206.160.227
someinternalhost_IP = 10.156.0.5
```

# Работа с gcloud

Пример создания ВМ, с использованием локального стартап-скрипта:
```shell script
gcloud compute instances create reddit-app\
  --boot-disk-size=10GB \
  --image-family ubuntu-1604-lts \
  --image-project=ubuntu-os-cloud \
  --machine-type=g1-small \
  --tags puma-server \
  --metadata-from-file startup-script=startup_script.sh \
  --restart-on-failure
```
Пример создания ВМ, с использованием стартап-скрипта расположенного в Google Storage (S3):
```shell script
gcloud compute instances create reddit-app \
  --boot-disk-size=10GB \
  --image-family ubuntu-1604-lts \
  --image-project=ubuntu-os-cloud \
  --machine-type=g1-small \
  --tags puma-server \
  --metadata startup-script-url=gs://zend0_infra_startup_script/startup_script.sh \
  --restart-on-failure
```
Пример создания правила на firewall:
```shell script
gcloud compute firewall-rules create default-puma-server \
    --direction ingress \
    --action allow \
    --target-tags puma-server \
    --source-ranges 0.0.0.0/0 \
    --rules tcp:9292
```
_Данные для проверки задания_
```shell script
testapp_IP = 23.251.131.126
testapp_port = 9292
```