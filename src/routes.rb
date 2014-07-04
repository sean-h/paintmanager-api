require 'json'
require 'sinatra/activerecord'
require 'sinatra/base'
require_relative './brand'
require_relative './paint'
require_relative './paint_range'
require_relative './user'

class Routes < Sinatra::Base

  get '/' do

  end

  get '/paints' do
    return Paint.all.to_json
  end

  get '/paints/:id' do |id|
    return Paint.where(:id => id).to_json
  end

  post '/paints' do
    paint = Paint.create(name: params[:name], color: params[:color])
    return paint.to_json
  end

  if app_file == $0
    db_config = YAML::load(File.open('db/config.yml'))
    ActiveRecord::Base.establish_connection(db_config["development"])
    run!
  end
end
