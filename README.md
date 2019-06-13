# ruby-wa-discord-bot
WeakAuras discord bot re-written in ruby.

Basic set up:

```bash
git clone https://github.com/rbenv/rbenv.git ~/.rbenv
echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> ~/.bashrc
echo 'eval "$(rbenv init -)"' >> ~/.bashrc
git clone https://github.com/rbenv/ruby-build.git ~/.rbenv/plugins/ruby-build`
source ~/.bashrc
rbenv install 2.6.3
rbenv global 2.6.3
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
