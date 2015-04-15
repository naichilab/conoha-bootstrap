# git用パッケージインストール
%w{ wget curl-devel expat-devel gettext-devel openssl-devel zlib-devel perl-ExtUtils-MakeMaker }.each do |pkg|
  package pkg do
    action :install
  end
end

# 古いバージョンを削除
yum_package 'git' do
  action :remove
end

remote_file "/usr/local/src/git-#{node['git']['version']}.tar.gz" do
  not_if 'which git'
  source node['git']['source_url']
  mode '0644'
end

bash 'install_git' do
  not_if 'which git'
  cwd '/usr/local/src'

  code <<-EOL
    tar zxvf git-#{node['git']['version']}.tar.gz
    rm git-#{node['git']['version']}.tar.gz
    cd git-#{node['git']['version']}
    ./configure --prefix=/usr/local/
    make prefix=/usr/local/ all
    make prefix=/usr/local/ install
    rm /usr/bin/git
    ln -s /usr/local/bin/git /usr/bin/git
  EOL
end
