# ruby-wa-discord-bot
WeakAuras discord bot re-written in ruby.

Basic set up:

```bash
git clone https://github.com/rbenv/rbenv.git ~/.rbenv
echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> ~/.bashrc
echo 'eval "$(rbenv init -)"' >> ~/.bashrc
git clone https://github.com/rbenv/ruby-build.git ~/.rbenv/plugins/ruby-build`
source ~/.bashrc
rbenv install 3.0.1
rbenv local 3.0.1
echo "gem: --no-document" > ~/.gemrc
gem install bundler
bundle install
```

Once you have all that installed, you need to create a file called `token.yml`. This file will contain your development and/or live tokens for use with the bot. Simply format it as such:

```yml
dev_token: your_testing_token
live_loken: your_main_token
```
While obvioulsy replacing the data with your actual tokens.

to run the bot you can do:
```
ruby wa_discord_bot.rb # dev token
ruby wa_discord_bot.rb -p # live/prod token
```

Currently using `supervisor` to keep the program running.

add this to the bottom of your `/etc/supervisord.conf`

You should update the username/paths in this config to your specific machine.
```ini
[program:ruby_weak_auras]
command=/home/wabot/.rbenv/shims/bundle exec ruby /home/wabot/ruby-wa-discord-bot/wa_discord_bot.rb -p
stdout_logfile=/home/wabot/ruby-wa-discord-bot/logs/out.log
autorestart=true
directory=/home/wabot/ruby-wa-discord-bot
stdout_logfile_maxbytes=100MB
stdout_logfile_backups=20
stdout_capture_maxbytes=0
stdout_events_enabled=false
stderr_logfile=/home/wabot/ruby-wa-discord-bot/logs/err.log
stderr_logfile_maxbytes=100MB
stderr_logfile_backups=20
stderr_capture_maxbytes=0
buffer_size=0 ; event buffer queue size (default 10)
; run this to update:
; supervisorctl
; reread
```

you should then run `supervisorctl` then in the prompt, `reread`
```
supervisord
supervisorctl restart ruby_weak_auras
```


Old depreacted bot: https://github.com/krazyito65/wa-discord-bot
