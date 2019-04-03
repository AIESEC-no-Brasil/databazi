cd /home/ubuntu/apps/databazi/current
kill $(ps aux | awk '/bin\/shoryuken/ { print $2}'); RAILS_ENV=production bundle exec shoryuken -R -C config/shoryuken.yml -d -L ~/debug_shoryuken.log
