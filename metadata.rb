name             'vim-setup'
maintainer       'Ivan Kusalic'
maintainer_email 'ivan@ikusalic.com'
description      'Installs and configures Vim including plugins'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          '1.2.9'

depends          'git'

%w[ ubuntu centos ].each do |os|
  supports os
end
