require 'json'
require 'sinatra/activerecord'
require 'sinatra/base'
require_relative './brand'
require_relative './paint'
require_relative './paint_range'
require_relative './user'

class Routes < Sinatra::Base

  after do
    ActiveRecord::Base.connection.close
  end

  get '/' do

  end

  get '/brands' do
    return Brand.all.to_json
  end

  get '/brands/:id' do |id|
    return Brand.where(:id => id).to_json
  end

  post '/brands' do
    brand = Brand.create(name: params[:name])
    return brand.to_json
  end

  get '/ranges' do
    return PaintRange.all.to_json
  end

  get '/ranges/:id' do |id|
    return PaintRange.where(:id => id).to_json
  end

  post '/ranges' do
    range = PaintRange.create(name: params[:name], brand_id: params[:brand_id])
    return range.to_json
  end

  get '/paints' do
    return Paint.all.to_json
  end

  get '/paints/:id' do |id|
    return Paint.where(:id => id).to_json
  end

  post '/paints' do
    paint = Paint.create(name: params[:name], color: params[:color], range_id: params[:range_id])
    return paint.to_json
  end

  get '/sync' do
    brands = Brand.all
    ranges = PaintRange.all
    paints = Paint.all
    data = {brand: brands, paint_range: ranges, paint: paints}
    return data.to_json
  end

  if app_file == $0
    db_config = YAML::load(File.open('db/config.yml'))
    ActiveRecord::Base.establish_connection(db_config["development"])
    run!
  end
end
