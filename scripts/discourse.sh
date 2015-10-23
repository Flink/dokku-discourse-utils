#!/bin/bash
echo "=====> Injecting tools needed for Discourse"
echo "-----> Installing PostgreSQL tools"
wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add - > /dev/null
echo "deb http://apt.postgresql.org/pub/repos/apt/ trusty-pgdg main" > /etc/apt/sources.list.d/pgdg.list
apt-get update -qq
apt-get install -qq -y postgresql-client-9.4 &> /dev/null

echo "-----> Installing image optimization tools"
apt-get install -qq -y gifsicle ImageMagick pngquant jhead jpegoptim libjpeg-turbo-progs libjpeg-progs &> /dev/null

echo "-----> Installing npm & svgo"
curl -sL https://deb.nodesource.com/setup_0.12 | bash - > /dev/null
apt-get install -qq -y nodejs &> /dev/null
npm install -g svgo > /dev/null

echo "-----> Setting .git to report correct version"
cd /git
COMMIT=$(git log --grep 'version.*v([0-9]\.)+' -i -E -1 --format=format:%H)
git clone -q https://github.com/discourse/discourse /discourse > /dev/null
cd /discourse
git checkout "$COMMIT" &> /dev/null
cp -a /discourse/.git /app
cd /app
rm -rf /discourse

echo "-----> Generating proper Procfile"
sed -i 's,^web.*$,web: bundle exec unicorn -c config/unicorn.conf.rb -p \$PORT,' /app/Procfile

echo "-----> Modifying Unicorn configuration"
sed -i 's/^stderr_path.*$//' /app/config/unicorn.conf.rb
sed -i 's/^stdout_path.*$//' /app/config/unicorn.conf.rb

echo "-----> Creating /app/tmp/pids directory"
mkdir -p /app/tmp/pids

echo "-----> Cleaning"
apt-get clean -qq
echo "=====> Done"
