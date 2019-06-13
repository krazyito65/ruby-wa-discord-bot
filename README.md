# ruby-wa-discord-bot
weak auras discord bot re-written in ruby.

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
bundle install```
