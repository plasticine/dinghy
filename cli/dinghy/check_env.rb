require 'dinghy/constants'

class CheckEnv
  attr_reader :machine

  def initialize(machine)
    @machine = machine
  end

  def run
    if set?
      puts "\e[32mYour environment variables are already set correctly.\e[0m"
    else
      puts "\e[33mTo connect the Docker client to the Docker daemon, please set:\e[0m"
      print
    end
  end

  def expected
    {
      "DOCKER_HOST" => "tcp://#{machine.vm_ip}:2376",
      "DOCKER_CERT_PATH" => machine.store_path,
      "DOCKER_TLS_VERIFY" => "1",
      "DOCKER_MACHINE_NAME" => machine.name,
    }
  end

  def print
    expected.each { |name,value| puts "    export #{name}=#{value}" }
  end

  def set?
    expected.all? { |name,value| ENV[name] == value }
  end
end
