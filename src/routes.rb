require 'json'
require 'sinatra/activerecord'
require 'sinatra/base'
require_relative './brand'
require_relative './paint'
require_relative './paint_range'
require_relative './user'
require_relative './status_key'
require_relative './paint_status'

# Entry point of the application.
class Routes < Sinatra::Base
  after do
    ActiveRecord::Base.connection.close
  end

  # @method /brands
  # Returns all Brands.
  get '/brands' do
    return Brand.all.to_json
  end

  # @method /brands/id
  # @param id [Integer] The Brand's id.
  # Returns Brand that matches the given id.
  get '/brands/:id' do |id|
    return Brand.where(id: id).to_json
  end

  # @method /brands
  # @param name [String] The name of the Brand to create.
  # Returns the created Brand.
  post '/brands' do
    brand = Brand.create(name: params[:name])
    return brand.to_json
  end

  # @method /ranges
  # Returns all PaintRanges.
  get '/ranges' do
    return PaintRange.all.to_json
  end

  # @method /ranges/id
  # @param id [Integer] The PaintRange's id.
  # Returns the PaintRange with the given id.
  get '/ranges/:id' do |id|
    return PaintRange.where(id: id).to_json
  end

  # @method /ranges
  # @param name [String] The name of the PaintRange to create.
  # @param brand_id [Integer] The id of the brand the new PaintRange belongs to
  # Returns the created PaintRange.
  post '/ranges' do
    range = PaintRange.create(name: params[:name],
                              brand_id: params[:brand_id])
    return range.to_json
  end

  # @method /paints
  # Returns all Paints.
  get '/paints' do
    return Paint.all.to_json
  end

  # @method /paints/id
  # @param id [Integer] The Paint to fetch with given id.
  # Returns Paint with given id.
  get '/paints/:id' do |id|
    return Paint.where(id: id).to_json
  end

  # @method /paints
  # @param name [String] The name of the Paint to create.
  # @param color [String] The color of the paint in #XXXXXX format.
  # @param range_id [Integer] The id of the PaintRange the Paint belongs to.
  # Returns the new Paint.
  post '/paints' do
    paint = Paint.create(name: params[:name],
                         color: params[:color],
                         range_id: params[:range_id])
    return paint.to_json
  end

  # @method /status_key
  # Returns all StatusKeys
  get '/status_keys' do
    return StatusKey.all.to_json
  end

  # @method /status_keys/id
  # @param id [Integer] The id of the StatusKey to fetch.
  # Returns StatusKey with given id.
  get '/status_keys/:id' do |id|
    return StatusKey.where(id: id).to_json
  end

  # @method /status_key
  # @param name [String] The name of the StatusKey to create.
  # @param color [String] The color of the StatusKey to create.
  # Returns the newly created StatusKey.
  post '/status_keys' do
    status_key = StatusKey.create(name: params[:name], color: params[:color])
    return status_key.to_json
  end

  # @method /user
  # @param email [String] The email of the new user.
  # @param password [String] The password of the new user.
  # Returns the new User.
  post '/user' do
    user = User.create(email: params[:email], password: params[:password])
    return user.to_json
  end

  # @method /paint_statuses
  # Returns all the PaintStatuses
  get '/paint_statuses' do
    return PaintStatus.all.to_json
  end

  # @method /paint_statuses
  # @param paint_id [Integer] The id of the Paint.
  # @param user_id [Integer] The id of the User.
  # Returns the PaintStatus for the given Paint and User.
  post '/paint_statuses' do
    status = PaintStatus.where(paint_id: params['paint_id'], user_id: 1)
      .first_or_create
    status.status = params['status']
    status.save
    return status.to_json
  end

  # @method /sync
  # Returns all Brands, PaintRanges, Paints and StatusKeys.
  get '/sync' do
    brands = Brand.all
    ranges = PaintRange.all
    paints = Paint.select('paints.*,
                           COALESCE(paint_statuses.status, 1) AS status')
      .joins('LEFT OUTER JOIN paint_statuses
              ON paints.id = paint_statuses.paint_id')
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
  else
    db_config = YAML.load(File.open('db/config.yml'))
    ActiveRecord::Base.establish_connection(db_config['test'])
  end
end
