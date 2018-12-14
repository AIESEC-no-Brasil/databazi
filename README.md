# Databazi

To restart the webserver, from within your local application directory run:
$ cap production puma:restart

# Periodic tasks

> Whenever --update-crontab

Run scheduler manually
>  bin/rails runner -e development 'ExpaApplicationSyncScheduler.call'

Run Shoryuken
> shoryuken -R -C config/shoryuken.yml -v
