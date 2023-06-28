# telegraf_os_updates
Simple bash script for Telegraf [[inputs.exec]] to grab pending updates

## Telegraf config

```
# Pending updates
[[inputs.exec]]
  commands = ["/usr/local/bin/get_updates.sh"]
  timeout = "10s"
  data_format = "influx"
  interval = "1h"
```
