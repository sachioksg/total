#!/bin/bash

/etc/init.d/mysql start

mysql -uroot -proot -e'create database redmine character set utf8;'
mysql -uroot -proot -e"create user redmine_user@localhost identified by 'redmine';"
mysql -uroot -proot -e"grant all privileges on redmine.* to 'redmine_user'@'localhost';"
