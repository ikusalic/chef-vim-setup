include_recipe 'git'

def setup()
  custom_preinstall_bash

  install_vim

  use_dotfiles

  custom_bash_once

  handle_vundle
end

def custom_preinstall_bash()
  execute 'custom preinstall bash' do
    command node[:vim_setup][:custom_preinstall_bash]
  end
end

def install_vim()
  if node[:vim_setup][:build_from_source]
    build_from_source
  else
    install_packages
  end
end

def build_from_source()
  package 'mercurial'

  execute 'build from source' do
    command <<-HERE
      set -e
      hg clone https://code.google.com/p/vim/ /tmp/vim
      cd /tmp/vim
      ./configure #{ node[:vim_setup][:build_parameters] }
      make
      make install
    HERE
  end
end

def install_packages()
  node[:vim_setup][:base_packages].each { |pkg| package pkg }
  node[:vim_setup][:additional_packages].each { |pkg| package pkg }
end

def use_dotfiles()
  return unless node[:vim_setup][:dotfiles_repo]

  log_global_vim_dir
  checkout_dotfiles
  copy_vimrc
end

def log_global_vim_dir()
  execute('log global vim dir') do  # HACK
    command "echo | vim -u NONE --cmd '!echo $VIM > /tmp/system_vim_dir' || true"
  end
end

def checkout_dotfiles()
  git 'Checkout dotfiles' do
    repository node[:vim_setup][:dotfiles_repo]
    reference 'master'
    action :checkout
    destination '/tmp/dotfiles'
  end
end

def copy_vimrc()
  that = self

  ruby_block "copy vimrc" do
    block do
      require 'fileutils'

      src = File.join '/tmp/dotfiles', node[:vim_setup][:dotfiles_rvmrc_path]

      FileUtils.cp(src, that.global_vimrc) if node[:vim_setup][:global_vimrc]

      node[:vim_setup][:users].each do |user|
        dest = File.join(that.user_dir(user), '.vimrc')
        FileUtils.cp src, dest
        FileUtils.chown user, user, dest
      end
    end
  end
end

def global_vimrc()
  return File.join global_vim_dir, 'vimrc'
end

def global_vim_dir()
  return ( open(tmp_file).read.strip rescue '/usr/share/vim' )
end

def custom_bash_once()
  execute('custom bash once') { command node[:vim_setup][:custom_bash_once] }
end

def handle_vundle()
  return unless node[:vim_setup][:use_vundle]

  node[:vim_setup][:users].each do |user|
    setup_vundle user
    chown_files user
    custom_bash_user_before_vundle user
    install_plugins_with_vundle user
  end

  custom_bash_once_after_vundle

  node[:vim_setup][:users].each { |user| custom_bash_user_after_vundle user }
end

def custom_bash_once_after_vundle()
  execute 'custom bash once after vundle' do
    command node[:vim_setup][:custom_bash_once_after_vundle]
  end
end

def custom_bash_user_after_vundle(user)
  that = self

  execute "custom bash user(#{ user }) after vundle" do
    user user
    group user
    environment 'HOME' => that.user_dir(user)
    command node[:vim_setup][:custom_bash_user_after_vundle]
  end
end

def setup_vundle(user)
  bundle_dir = File.join(user_dir(user), '.vim/bundle/')

  directory bundle_dir do
    recursive true
    action :create
  end

  git 'Get vundle' do
    repository 'https://github.com/gmarik/vundle.git'
    reference 'master'
    action :checkout
    destination File.join(bundle_dir, 'vundle')
  end
end

def chown_files(user)
  that = self

  ruby_block "chown files" do
    block { FileUtils.chown_R user, user, that.user_dir(user) }
  end
end

def custom_bash_user_before_vundle(user)
  that = self

  execute "custom bash user: #{ user }" do
    user user
    group user
    environment 'HOME' => that.user_dir(user)
    command node[:vim_setup][:custom_bash_user_before_vundle]
  end
end

def install_plugins_with_vundle(user)
  return unless node[:vim_setup][:bundle_install]

  that = self

  execute 'install plugins via vundle' do
    user user
    group user
    environment 'HOME' => that.user_dir(user)
    timeout node[:vim_setup][:vundle_timeout]
    command "vim -c 'set shortmess=at' +BundleInstall +qa"
  end
end

def user_dir(user)
  return (user == 'root') ? '/root' : File.join('/home', user)
end


setup # NOTE
