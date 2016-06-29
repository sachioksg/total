FROM ubuntu
MAINTAINER sachioksg <s-kono@nri.co.jp>

RUN apt-get update && \
    echo "mysql-server mysql-server/root_password password root" | debconf-set-selections && \
    echo "mysql-server mysql-server/root_password_again password root" | debconf-set-selections && \
    apt-get install -y mysql-server build-essential zlib1g-dev libssl-dev libreadline-dev libyaml-dev libcurl4-openssl-dev \
                       apache2 libapache2-mod-passenger imagemagick libmagick++-dev fonts-takao-pgothic \
                       subversion git bundler libmysqlclient-dev

RUN gem install mysql2
RUN mkdir -m 755 /opt/redmine-3.3 && svn co http://svn.redmine.org/redmine/branches/3.3-stable /opt/redmine-3.3

RUN mkdir -m 755 /tmp/mysql
COPY setmysql.sh /tmp/mysql/
RUN chmod 755 /tmp/mysql/setmysql.sh && /tmp/mysql/setmysql.sh

COPY database.yml /opt/redmine-3.3/config/

RUN cd /opt/redmine-3.3 && \
    bundle update && \
    bundle install --without development test postgresql sqlite && \
    bundle exec rake generate_secret_token && \
    /etc/init.d/mysql start && \
    RAILS_ENV=production rake db:migrate && \
    RAILS_ENV=production REDMINE_LANG=ja rake redmine:load_default_data

CMD /etc/init.d/mysql start && cd /opt/redmine-3.3 && ruby bin/rails server webrick --bind=0.0.0.0 -p 80 -e production

