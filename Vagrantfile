Vagrant::Config.run do |config|
  config.vm.define :pennyworth do |pennyworth|
    pennyworth.vm.customize do |vm|
      vm.memory_size = 4096
      # vm.cpus = 8
    end
    pennyworth.vm.box = "natty64"
    pennyworth.vm.box_url = "https://s3.amazonaws.com/hw-vagrant/natty64.box"
    pennyworth.vm.forward_port "web", 80, 8000, :auto => true
    pennyworth.vm.forward_port "jenkins", 8080, 8080, :auto => true
    pennyworth.vm.provision :chef_solo do |chef|
      chef.data_bags_path = "data_bags"
      chef.cookbooks_path = "cookbooks"
      chef.roles_path = "roles"
      chef.add_role "pennyworth"
    end
  end
end
