class Eggdrop < ActiveRecord::Base
  belongs_to :user
  has_many :logs

  def stdout_file
    log_file('stdout')
  end

  def stderr_file
    log_file('stderr')
  end

  def stdout_log
    read_log log_file('stdout')
  end

  def stderr_log
    read_log log_file('stderr')
  end

  def log_file(log)
    return nil if self.path.nil?
    File.join(self.path, "/eggdrop/logs/#{log}.log")
  end

  def read_log(file)
    return '' unless FileTest.exists?(file)
    File.read(file)
  end

  module Status
    DOWN = 0
    UP = 1
  end
end
