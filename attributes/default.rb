default[:vim_setup][:build_from_source] = false
default[:vim_setup][:build_parameters]  = <<-HERE
--prefix=/usr --with-features=huge --enable-rubyinterp --enable-pythoninterp \
--enable-python3interp --enable-luainterp --enable-perlinterp --enable-cscope
HERE

default[:vim_setup][:base_packages]       = ['vim-gtk']
default[:vim_setup][:additional_packages] = []

default[:vim_setup][:dotfiles_repo]       = nil
default[:vim_setup][:dotfiles_rvmrc_path] = '.vimrc'
default[:vim_setup][:global_vimrc]        = true
default[:vim_setup][:users]               = []

default[:vim_setup][:custom_preinstall_bash] = 'true'
default[:vim_setup][:custom_bash_once]       = 'true'

default[:vim_setup][:use_vundle]                     = false
default[:vim_setup][:bundle_install]                 = true
default[:vim_setup][:vundle_timeout]                 = 500
default[:vim_setup][:custom_bash_user_before_vundle] = 'true'
default[:vim_setup][:custom_bash_user_after_vundle]  = 'true'
default[:vim_setup][:custom_bash_once_after_vundle]  = 'true'
