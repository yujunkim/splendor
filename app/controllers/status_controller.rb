class StatusController < ApplicationController
  layout 'cdn_only'

  def messages
    @messages = Kaminari.paginate_array(Splendor::Application::Messages).page(params[:page]).per(200)
  end

  def games
    @games = Kaminari.paginate_array(Splendor::Application::Record[:game].values).page(params[:page]).per(30)
  end

  def users
    @users = Kaminari.paginate_array(Splendor::Application::Record[:user].values).page(params[:page]).per(30)
  end
end
