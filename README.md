# telegraf_os_updates
Simple bash script for Telegraf [[inputs.exec]] to grab pending updates

## script config

Set variable `loc_domain` to the domain of a local repository.

## Telegraf config

```
# Pending updates
[[inputs.exec]]
  commands = ["sudo /usr/local/bin/get_updates.sh"]
  timeout = "20s"
  data_format = "influx"
  interval = "30m"
```

## sudoers

`sudo visudo /etc/sudoers.d/telegraf`

```
telegraf ALL = NOPASSWD: /usr/local/bin/get_updates.sh
```
