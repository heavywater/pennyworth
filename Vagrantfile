Vagrant::Config.run do |config|
  config.vm.define :pennyworth do |pennyworth|
    pennyworth.vm.customize do |vm|
      vm.memory_size = ENV["PENNYWORTH_RAM"] || 4096
      vm.cpus = ENV["PENNYWORTH_CPUS"] || 2
    end
    pennyworth.vm.box = "oneiric64"
    pennyworth.vm.box_url = "https://s3.amazonaws.com/hw-vagrant/oneiric64.box"
    pennyworth.vm.forward_port 80, 8000
    pennyworth.vm.forward_port 8080, 8080
    pennyworth.vm.provision :chef_solo do |chef|
      chef.data_bags_path = "data_bags"
      chef.cookbooks_path = "cookbooks"
      chef.roles_path = "roles"
      chef.add_role "pennyworth"
    end
  end
end
