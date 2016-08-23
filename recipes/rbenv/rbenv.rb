package "epel-release"
package "gcc"
package "openssl-devel"
package "libyaml-devel"
package "readline-devel"
package "zlib-devel"
package "git"

RBENV_DIR = "/usr/local/rbenv"
RBENV_SCRIPT = "/etc/profile.d/rbenv.sh"

git RBENV_DIR do
  repository "git://github.com/sstephenson/rbenv.git"
  not_if "test -d #{RBENV_DIR}"
end

remote_file RBENV_SCRIPT do
  source "templates/rbenv.sh"
  mode "644"
  owner "root"
  group "root"
end

execute "make plugins directory" do
  command "mkdir #{RBENV_DIR}/plugins"
  not_if "test -d #{RBENV_DIR}/plugins"
end

execute "make shims directory" do
  command "mkdir #{RBENV_DIR}/shims"
  not_if "test -d #{RBENV_DIR}/shims"
end

execute "make versions directory" do
  command "mkdir #{RBENV_DIR}/versions"
  not_if "test -d #{RBENV_DIR}/versions"
end

git "#{RBENV_DIR}/plugins/ruby-build" do
  repository "git://github.com/sstephenson/ruby-build.git"
end

node[:rbenv][:versions].each do |version|
  execute "install ruby #{version}" do
    command "source #{RBENV_SCRIPT}; rbenv install #{version}"
    not_if "source #{RBENV_SCRIPT}; rbenv versions | grep #{version}"
  end
end

execute "set global ruby #{node[:rbenv][:global]}" do
  command "source #{RBENV_SCRIPT}; rbenv global #{node[:rbenv][:global]}; rbenv rehash"
  not_if "source #{RBENV_SCRIPT}; rbenv global | grep #{node[:rbenv][:global]}"
end

node[:rbenv][:gems].each do |gem|
  execute "gem install #{gem}" do
    command "source #{RBENV_SCRIPT}; gem install #{gem}; rbenv rehash"
    not_if "source #{RBENV_SCRIPT}; gem list | grep #{gem}"
  end
end
