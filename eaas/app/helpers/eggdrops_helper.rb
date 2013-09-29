module EggdropsHelper
  def eggdrop_status(status)
    case status
      when Eggdrop::Status::DOWN
        "DOWN"
      when Eggdrop::Status::UP
        "UP"
      else
        "UNKNOWN"
    end
  end
end
