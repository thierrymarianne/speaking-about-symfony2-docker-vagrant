
# as inspired by https://github.com/Cethy/vagrant-gaudi
class { 'docker':
  manage_kernel => false,
  socket_bind => 'unix:///var/run/docker.sock',
}
