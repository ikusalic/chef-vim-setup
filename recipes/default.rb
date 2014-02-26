include_recipe 'git'

execute 'custom preinstall bash' do
  command node[:vim_setup][:custom_preinstall_bash]
end

node[:vim_setup][:base_packages].each { |pkg| package pkg }

node[:vim_setup][:additional_packages].each { |pkg| package pkg }

if node[:vim_setup][:dotfiles_repo]
  git 'Checkout dotfiles' do
    repository node[:vim_setup][:dotfiles_repo]
    reference 'master'
    action :checkout
    destination '/tmp/dotfiles'
  end

  ruby_block "copy vimrc" do
    block do
      require 'fileutils'

      src = File.join '/tmp/dotfiles', node[:vim_setup][:dotfiles_rvmrc_path]

      if node[:vim_setup][:global]
        FileUtils.cp src, '/etc/vim/vimrc'
      end

      node[:vim_setup][:users].each do |user|
        dest = (user == 'root') ? '/root/.vimrc' : File.join('/home', user, '.vimrc')
        FileUtils.cp src, dest
        FileUtils.chown user, user, dest
      end
    end
  end

  execute 'custom bash once' do
    command node[:vim_setup][:custom_bash_once]
  end

  node[:vim_setup][:users].each do |user|
    user_dir = (user == 'root') ? '/root' : File.join('/home', user)

    if node[:vim_setup][:use_vundle]
      bundle_dir = File.join(user_dir, '.vim/bundle/')

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

    ruby_block "chown files" do
      block { FileUtils.chown_R user, user, user_dir }
    end

    execute "custom bash user: #{ user }" do
      user user
      group user
      environment 'HOME' => user_dir
      command node[:vim_setup][:custom_bash_user]
    end

    if node[:vim_setup][:use_vundle] and node[:vim_setup][:bundle_install]
      execute 'install plugins via vundle' do
        user user
        group user
        environment 'HOME' => user_dir
        timeout node[:vim_setup][:vundle_timeout]
        command "vim -c 'set shortmess=at' +BundleInstall +qa"
      end
    end
  end

  execute 'custom bash once after vundle' do
    command node[:vim_setup][:custom_bash_once_after_vundle]
  end

  node[:vim_setup][:users].each do |user|
    user_dir = (user == 'root') ? '/root' : File.join('/home', user)
    execute "custom bash user(#{ user }) after vundle" do
      user user
      group user
      environment 'HOME' => user_dir
      command node[:vim_setup][:custom_bash_user_after_vundle]
    end
  end
end
