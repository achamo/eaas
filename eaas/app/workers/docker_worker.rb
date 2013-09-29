class DockerWorker
  include Sidekiq::Worker
  sidekiq_options queue: :docker
 
  DOCKER_PATH = '/home/eaas/project/volumes'

  def create_volumes
    @volume_sftp = File.join(DOCKER_PATH, @eggdrop.id.to_s, 'sftp')
    @volume_eggdrop = File.join(DOCKER_PATH, @eggdrop.id.to_s, 'eggdrop')
    @eggdrop.path = File.join(DOCKER_PATH, @eggdrop.id.to_s)
    FileUtils.mkpath(@volume_sftp) unless FileTest.directory?(@volume_sftp)
    FileUtils.mkpath(@volume_eggdrop) unless FileTest.directory?(@volume_eggdrop)
    %w(conf db scripts logs).each do |path|
      dest = File.join(@volume_eggdrop, path)
      FileUtils.mkdir(dest) unless FileTest.directory?(dest)
    end
  end

  def create_user
    File.open(File.join(@volume_sftp, 'sftp.passwd'), 'w') do |f|
      f.puts "eggdrop:#{@eggdrop.password}:1000:1000::/home/eggdrop:/bin/false"
    end
  end

  def create_config
    File.open(File.join(@volume_eggdrop, 'conf', 'eggdrop.conf'), 'w') do |f|
      filename = Rails.root.join('lib/templates/erb/eggdrop/eggdrop.conf.erb')
      f.puts ERB.new(File.read(filename)).result(binding)
    end
  end

  def init_docker
    res = `sudo /usr/bin/docker run -i \
           -m 209715200 \
           -p #{@eggdrop.port_users}:#{@eggdrop.port_users} \
           -p #{@eggdrop.port_bots}:#{@eggdrop.port_bots} \
           -p #{@eggdrop.port_ftp}:22 \
           -w /home/eggdrop \
           -v #{@volume_sftp}:/mnt/sftp:ro \
           -v #{@volume_eggdrop}:/home/eggdrop:rw \
           -d \
           shine/eggdrop \
           /usr/bin/supervisord`
  end

  def start_docker(id)
    `sudo /usr/bin/docker start #{id}`
    @eggdrop.status = Eggdrop::Status::UP
  end

  def stop_docker(id)
    `sudo /usr/bin/docker stop #{id}`
    @eggdrop.status = Eggdrop::Status::DOWN
  end

  def perform(id, status)
    @eggdrop = Eggdrop.find(id)
    return if @eggdrop.nil?
    case status
      when 'init'
        create_volumes
        create_user
        create_config
        res = init_docker
        @eggdrop.docker_id = res.chomp
        @eggdrop.status = Eggdrop::Status::UP
      when 'stop'
        stop_docker(@eggdrop.docker_id)
      when 'start'
        start_docker(@eggdrop.docker_id)
      when 'restart'
        stop_docker(@eggdrop.docker_id)
        start_docker(@eggdrop.docker_id)
    end
    @eggdrop.save
  end
end
