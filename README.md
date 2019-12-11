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
# Работа с Packer
Создание Application Default Credentials (АDC):
```shell script
gcloud auth application-default login
```
Валидация конфига для Packer (с внешними переменными)
```shell script
packer validate -var-file=variables.json ubuntu16.json
```
Запуск сборки образа
```shell script
packer build -var-file=variables.json ubuntu16.json
```
# Работа с Terraform
Для Terraform имя файла не имеет значения, он загружает все файлы в текущей директории с расширением `*.tf`  

Все файлы, которые соответствуют `terraform.tfvars` или `*.auto.tfvars` в текущем директории, 
автоматически загружаются для подстановки переменных.  
Как вариант, переменные можно передавать в командной строке:
```shell script
terraform apply \
  -var 'region=us-east-2'
```
Инициализация терраформа, скачивание необходимых провайдеров и т.п.
```shell script
terraform init
```
Вывод планируемых изменений
```shell script
terraform plan
```
Применение изменений
```shell script
terraform apply
```
вывод текущего состояния инфраструктуры (читает `*.tfstate`)
```shell script
terraform show
```
Вывод всех output(ов)
```shell script
terraform output
```
Если внесли изменения в output(ы) то изменения применяем "на лету"
```shell script
terraform refresh
```
Для проверки синтаксиса и корректного форматирования всех файлов, можно воспользоваться
```shell script
terraform fmt
```

При работе с Terraform надо учитывать что если какой то элемент инфраструктуры не описан в Terraform, то при `apply`, 
`destroy` его можно потерять.

# Работа с Terraform (продолжение)
### Импортируем существующую инфраструктуру в Terraform
Указываем terraform(у) импортировать в state-файл описанный элемент инфраструктуры, который был создал вне terraform
```bash
terraform import google_compute_firewall.firewall_ssh default-allow-ssh
```
Для загрузки моулей, необходимо выполнить в дирректории terraform выполнить
```bash
terraform get
```
В ходе выполнения дополнительного задания (хранение state в S3 GCP) подтвердилось что его может использовать только один процесс terraform