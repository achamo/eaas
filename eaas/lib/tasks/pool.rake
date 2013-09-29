namespace :pool do
  desc "Create pools"
  task :create => :environment do
    if ENV['START'].nil? or ENV['COUNT'].nil?
      warn "pool:create START=port COUNT=pools"
      exit
    end
    count = ENV['COUNT'].to_i
    start = ENV['START'].to_i
    count.times do
      ports = start.upto(start+2).collect{|p| p}
      Pool.create(port_users: ports[0], port_bots: ports[1],
                  port_ftp: ports[2], used: false)
      start += 3
    end
  end
end
