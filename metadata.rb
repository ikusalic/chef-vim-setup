name             'vim-setup'
maintainer       'Ivan Kusalic'
maintainer_email 'ivan@ikusalic.com'
description      'Installs and configures Vim'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          '0.1.4'

depends          'git'

%w[ ubuntu centos ].each do |os|
  supports os
end
