package "git"

PYENV_DIR = "/usr/local/pyenv"
PYENV_SCRIPT = "/etc/profile.d/pyenv.sh"

git PYENV_DIR do
  repository "git://github.com/yyuu/pyenv.git"
  not_if "test -d #{PYENV_DIR}"
end

remote_file PYENV_SCRIPT do
  source "templates/pyenv.sh"
  mode "644"
  owner "root"
  group "root"
end

node[:pyenv][:versions].each do |version|
  execute "pyenv install #{version}" do
    command "source #{PYENV_SCRIPT}; pyenv install #{version}"
    not_if  "source #{PYENV_SCRIPT}; pyenv versions | grep #{version}"
  end
end

node[:pyenv][:global].tap do |version|
  execute "pyenv global #{version}" do
    command "source #{PYENV_SCRIPT}; pyenv global #{version}"
    not_if  "source #{PYENV_SCRIPT}; pyenv version | grep #{version}"
  end
end
