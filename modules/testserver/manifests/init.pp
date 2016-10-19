class testserver {

  class { 'apache':
    default_vhost => false,
    user => 'www-data',
    group => 'www-data',
  }

  apache::vhost { 'testsite':
    port => '80',
    docroot => '/var/www/cintest',
  }

  class { 'apache::mod::php': }

  file { '/var/www/testsite':
    ensure => directory,
    owner  => apache,
    group  => apache,
    mode   => 0750,
  }

  $str = "<?php

\$dsn = \'mysql:dbname=testdb;host=127.0.0.1\';
\$user = \'testuser\';
\$password = \'testpassword\';

try {
    \$dbh = new PDO(\$dsn, \$user, \$password);
    echo \'Sucess, Connected to Database\';
} catch (PDOException \$e) {
    echo \'Connection failed: \' . \$e->getMessage();
}
?>"

  file { '/var/www/testsite/index.php':
    ensure => present,
    #content => "<html>\n  <body>\n    HELLO WORLD! IT WORKS!!\n  </body>\n</html>",
    content => $str,
    owner  => apache,
    group  => apache,
    mode   => 0750,
  }

  class { 'mysql::server':
    root_password => 'testservers', 
    remove_default_accounts => true,
    override_options => {
      mysqld => {
        'port' => '3390',
      }
    }
  }

  mysql::db { 'testdb':
    user => 'testuser',
    password => 'testpassword',
    dbname => 'testdb',
    host => 'localhost',
    grant => ['ALL'],
  }

}
