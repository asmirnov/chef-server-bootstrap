name             'chef-server-bootstrap'
maintainer       'Alexander Smirnov'
maintainer_email 'devops@asmirnov.info'
license          'Apache 2.0'
description      'Installs/Configures chef-server-bootstrap'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          '0.1.0'
depends          'hostsfile'
depends          'chef-server-populator'
depends          'chef-server'