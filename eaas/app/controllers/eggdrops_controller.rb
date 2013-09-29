class EggdropsController < ApplicationController

  before_filter :authenticate_user!
  before_filter :check_available, only: [ :new, :create ]
  before_filter :check_property, only: [ :show, :delete, :order ]

  def index
    @eggdrop = Eggdrop.where(user_id: current_user.id).first
  end

  def new
    @eggdrop = Eggdrop.new
    flash[:error] = nil
  end

  def create
    pool = Pool.where(used: false).first
    @eggdrop = Eggdrop.new
    if params[:eggdrop][:password].empty? or
       params[:eggdrop][:password] != params[:eggdrop][:password_confirmation]
       flash[:error] = "Passwords doesn't match"
       render :new
       return 
    end
    if pool.nil?
      flash[:error] = "No more eggdrop available"
      render :new
    else
      pool.used = true
      pool.save
      @eggdrop.user_id = current_user.id
      @eggdrop.port_users = pool.port_users
      @eggdrop.port_bots = pool.port_bots
      @eggdrop.port_ftp = pool.port_ftp
      @eggdrop.password = params[:eggdrop][:password].crypt("$1$c4k4IdGe9$")
      @eggdrop.status = Eggdrop::Status::DOWN
      if @eggdrop.save
        DockerWorker.perform_async(@eggdrop.id, 'init')
        render :show
      else
        flash[:error] = @eggdrop.errors
        render :new
      end
    end
  end

  def delete
    @eggdrop.delete
    redirect_to eggdrops_path
  end

  def show
    if @eggdrop.path
      @stdout = @eggdrop.stdout_log
      @stderr = @eggdrop.stderr_log
    end
  end

  def order
    if %w(start stop restart).include? params[:order]
      DockerWorker.perform_async(@eggdrop.id, params[:order])
      redirect_to eggdrop_path(@eggdrop), flash: { message: "Order #{params[:order]} executed" }
    else
      redirect_to eggdrop_path(@eggdrop), flash: { error: "Unknow order" }
    end
  end

  def check_available
    if not Eggdrop.where(user_id: current_user.id).first.nil?
      redirect_to eggdrops_path
    end
  end

  def check_property
    if params[:eggdrop_id]
      @eggdrop = Eggdrop.find(params[:eggdrop_id])
    else
      @eggdrop = Eggdrop.find(params[:id])
    end
    if @eggdrop.user_id != current_user.id
      redirect_to eggdrops_path
    end
  end

end
