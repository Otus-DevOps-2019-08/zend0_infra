#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import json
import argparse

parser = argparse.ArgumentParser(description='Генератор динамического Inventory для Ansible')
parser.add_argument('--list', help='JSON с данными о хостах и группах', action="store_true")
parser.add_argument('--host', help='JSON с переменными для конкретного хоста')
args = parser.parse_args()

with open("inventory.json", "r") as json_file:
    data = json.load(json_file)

if args.list:
    inventory = dict()
    hostvars = dict()
    for group, group_value in data.items():
        hosts = list()

        for host in group_value['hosts']:
            hosts.append(host)
            hostvar = dict()
            for host_var, host_var_value in group_value['hosts'][host].items():
                hostvar.update({host_var: host_var_value})
            hostvars.update({host: hostvar})

        inventory.update({group: {"hosts": hosts}})
    inventory.update({"_meta": {"hostvars": hostvars}})
    print(json.dumps(inventory, sort_keys=True, indent=2))

if not args.list and args.host:
    hostvars = dict()
    for group, group_value in data.items():
        if args.host in group_value['hosts']:
            for host_var, host_var_value in group_value['hosts'][args.host].items():
                hostvars.update({host_var: host_var_value})
    print(json.dumps(hostvars, sort_keys=True, indent=2))
