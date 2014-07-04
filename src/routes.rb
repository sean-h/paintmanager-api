require 'json'
require 'sinatra/activerecord'
require 'sinatra/base'
require_relative './brand'
require_relative './paint'
require_relative './paint_range'
require_relative './user'
require_relative './status_key'
require_relative './paint_status'

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
    return Brand.where(id: id).to_json
  end

  post '/brands' do
    brand = Brand.create(name: params[:name])
    return brand.to_json
  end

  get '/ranges' do
    return PaintRange.all.to_json
  end

  get '/ranges/:id' do |id|
    return PaintRange.where(id: id).to_json
  end

  post '/ranges' do
    range = PaintRange.create(name: params[:name],
                              brand_id: params[:brand_id])
    return range.to_json
  end

  get '/paints' do
    return Paint.all.to_json
  end

  get '/paints/:id' do |id|
    return Paint.where(id: id).to_json
  end

  post '/paints' do
    paint = Paint.create(name: params[:name],
                         color: params[:color],
                         range_id: params[:range_id])
    return paint.to_json
  end

  get '/status_keys' do
    return StatusKey.all.to_json
  end

  get '/status_keys/:id' do |id|
    return StatusKey.where(id: id).to_json
  end

  post '/status_keys' do
    status_key = StatusKey.create(name: params[:name], color: params[:color])
    return status_key.to_json
  end

  post '/user' do
    user = User.create(email: params[:email], password: params[:password])
    return user.to_json
  end

  get '/paint_statuses' do
    return PaintStatus.all.to_json
  end

  post '/paint_statuses' do
    #status = PaintStatus.where(id: params['paint_id'])
    status = PaintStatus.where(paint_id: params['paint_id'], user_id: 1).first_or_create
    status.status = params['status']
    status.save
    return status.to_json
  end

  get '/sync' do
    brands = Brand.all
    ranges = PaintRange.all
    paints = Paint.select('paints.*, COALESCE(paint_statuses.status, 1) AS status')
      .joins('LEFT OUTER JOIN paint_statuses ON paints.id = paint_statuses.paint_id')
    status_keys = StatusKey.all
    data = { brand: brands, paint_range: ranges,
             paint: paints, status_key: status_keys }
    return data.to_json
  end

  if app_file == $PROGRAM_NAME
    db_config = YAML.load(File.open('db/config.yml'))
    ActiveRecord::Base.establish_connection(db_config['development'])
    set :bind, '0.0.0.0'
    run!
  end
end
