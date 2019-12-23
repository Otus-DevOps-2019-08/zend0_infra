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

# Ansible
Проверка доступности хоста
```bash
ansible all -i inventory.yml -m ping
```
Получение статуса сервиса используя модули
```bash
ansible all -i inventory.yml -m systemd -a name=mongod
```
### Динамическое инвентори в Ansible
[Ссылка на описание что же это такое](https://medium.com/@Nklya/%D0%B4%D0%B8%D0%BD%D0%B0%D0%BC%D0%B8%D1%87%D0%B5%D1%81%D0%BA%D0%BE%D0%B5-%D0%B8%D0%BD%D0%B2%D0%B5%D0%BD%D1%82%D0%BE%D1%80%D0%B8-%D0%B2-ansible-9ee880d540d6).  
Для того что бы Ansible начал работать с динамическим инвентори, надо указать ему "инвентори" скрипт, который поддерживает ключи `--list` и `--host` и возвращает корректный формат ответа в JSON.  
Необходимо обратить внимание, что формат ответа сконвертированного YAML->JSON от `inventory.py --list` отличается.

### Деплой и управление конфигурацией с Ansible
Разбиваем плейбук на несколько плеев (play).  
Так же сделал интеграцию Packer с Ansible.

### Ansible, роли и окружения
Ansible Galaxy - централизованное хранилище плейбуков.  

Справка по команде:
```bash
ansible-galaxy -h
```
Создание "заготовки" для своей роли
```bash
ansible-galaxy init <role_name>
```
Хорошей практикой при использовании ролей с `galaxy` считается их описывание в `requirements.yml`
```yaml
- src: jdauphant.nginx
  version: v2.21.1
```
и устанавливаем роль:
```bash
ansible-galaxy install -r environments/stage/requirements.yml
```
коммитить в свой репозиторий такие роли не стоит, лучше их хранить отдельно, для простоты в конфиге стоит указать путь для таких ролей в `ansible.cfg`
```ini
[defaults]
...
roles_path = ./.imported_roles:./roles
```

Для работы с Ansible Vault необходимо создать файл с секретом, как вариант в  
`~/.ansible/otus_vault.key`
Для того что бы Ansible его сам подключал укажем путь к файлу в ancible.cfg
```ini
[defaults]
...
vault_password_file = ~/.ansible/otus_vault.key
```

Шифруем файл
```bash
ansible-vault encrypt environments/prod/credentials.yml
```
Правим файл
```bash
ansible-vault edit <file>
```
Расшифровываем файл
```bash
ansible-vault decrypt <file>
```
