# Chef cookbook vim-setup

Chef cookbook to install and set up Vim.

- [Description](#description)
- [Dependencies](#dependencies)
- [Attributes](#attributes)
- [Usage](#usage)
- [TODOs](#todos)
- [Comments, issues, ideas or if you feel likechatting](
    #comments-issues-ideas-or-if-you-feel-like-chatting)


## Description

The cookbook installs Vim and additionally supports:

* copying vimrc from git repository (typically from the user's dotfiles, here's
  mine: [dotfiles])
* setting up system-wide or user specific Vim
* installation of plugins managed by [Vundle]
* post-install customisation via bash scripts


## Dependencies

This cookbook depends only on the [git cookbook][git-cookbook].


## Attributes

The following attributes are available (default values are also show):

default[:vim_setup][:build_from_source] = false
default[:vim_setup][:build_parameters]  = <<-HERE
--prefix=/usr --with-features=huge --enable-rubyinterp --enable-pythoninterp \
--enable-python3interp --enable-luainterp --enable-perlinterp --enable-cscope
HERE

The `:build_from_source` attribute specifies if Vim should be build from
source or installed as package. It defaults to `false`. If
`:build_from_source` is set to `true`, attribute `:build_parameters` specifies
what parameters to use to build Vim. This influences the features that are
enabled in Vim.
* * *

~~~ruby
- default[:vim_setup][:base_packages]       = ['vim-gtk']
- default[:vim_setup][:additional_packages] = []
~~~

The `:base_packages` attribute defines which packages to install for Vim, the
default is `vim-gtk` which includes GUI support, but more importantly also has
the support for Ruby and Python amongst other things.

With the `:additional_packages` attribute additional packages to be installed
can be specified.
* * *

~~~ruby
- default[:vim_setup][:dotfiles_repo]       = nil
- default[:vim_setup][:dotfiles_rvmrc_path] = '.vimrc'
- default[:vim_setup][:global]              = true
- default[:vim_setup][:users]               = []
~~~

The `:dotfiles_repo` attribute can specify the git repository that contains
`.vimrc`, and the `:dotfiles_rvmrc_path` specifies the path to vimrc inside the
repository.

If the `:global` attribute is set to `true`, shared Vim will be set up. The
`:users` attribute can specify a list of users for whom to set up vimrc in
their home directory.

Note: both `:global` and `:users` attributes can be used at the same time.
* * *

~~~ruby
- default[:vim_setup][:custom_preinstall_bash] = 'true'
- default[:vim_setup][:custom_bash_user]       = 'true'
- default[:vim_setup][:custom_bash_once]       = 'true'
~~~

The attributes `:custom_bash_user` and `:custom_bash_once` can specify custom
scripts to execute for all individual users (executed as the user) and script
to be executed once for the root.

The attribute `:custom_preinstall_bash` can specify custom shell script to be
executed before any other action. It can be used to install dependencies
needed to build Vim from source.
* * *

~~~ruby
- default[:vim_setup][:use_vundle]                    = false
- default[:vim_setup][:bundle_install]                = true
- default[:vim_setup][:vundle_timeout]                = 500
- default[:vim_setup][:custom_bash_user_after_vundle] = 'true'
- default[:vim_setup][:custom_bash_once_after_vundle] = 'true'
~~~

All of attributes in this section can be used to manage the plugins with
Vundle.

The `:use_vundle` enables the usage of Vundle to install plugins. The bundle
directory will be created and Vundle will be cloned to that directory.

After both `:custom_bash_user` and `:custom_bash_once` scripts had run, the
~~~bash
vim -c 'set shortmess=at' +BundleInstall +qa
~~~
command will be executed to install all the plugins if the `:bundle_install`
attribute is set to true. With the `:vundle_timeout` attribute the timeout for
this operation can be adjusted to enable easier debugging. This particular
command can fail if plugins have external dependencies or e.g. if the color
scheme is managed via Vundle.)

Finally, the attributes `:custom_bash_user_after_vundle` and
`:custom_bash_once_after_vundle` can be used to run custom scripts after the
Vundle's `:BundleInstall` command. This can be used to finalize plugin set up,
e.g. to install external plugin dependencies.


## Usage

To enable easy testing and attribute selection, with the cookbook the [Vagrant]
testing environment is provided. The Vagrant setup will install Vim the way I
like it. [Take a look at it][Vagrantfile] to get the feel for the cookbook and
to see somewhat advanced application.
Modify it as desired.


## TODOs

Currently tested and developed for use on Ubuntu and CentOS, but can be easily
expanded to support other *nix systems. If you want to use it with some other
OS, send me an email or even better submit a pull request.

The Vundle is my favorite pluing manager, and so some of features are
Vundle-centric. If you'd like to use something else, you can do it via
customisation attributes (running custom bash scripts) or just send a pull
request.


## Comments, issues, ideas or if you feel like chatting

ivan@<< username >>.com

I'd be happy to hear from you.

Also, visit my [homepage].


[dotfiles]: https://github.com/ikusalic/dotfiles
[git-cookbook]: https://github.com/fnichol/chef-git
[homepage]: http://www.ikusalic.com/
[Vagrant]: http://www.vagrantup.com/about.html
[Vagrantfile]: /test/Vagrantfile
[Vundle]: https://github.com/gmarik/vundle
