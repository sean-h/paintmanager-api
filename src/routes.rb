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
  enable :sessions

  "before do
    @user = User.get(session[:user_id])
  end"

  after do
    ActiveRecord::Base.connection.close
  end

  get '/' do
    send_file File.join(settings.public_folder, 'index.html')
  end

  # @method /brands
  # Returns all Brands.
  get '/brands.json' do
    return Brand.all.to_json
  end

  # @method /brands/id
  # @param id [Integer] The Brand's id.
  # Returns Brand that matches the given id.
  get '/brands/:id.json' do |id|
    return Brand.where(id: id).to_json
  end

  # @method /brands
  # @param name [String] The name of the Brand to create.
  # Returns the created Brand.
  post '/brands' do
    brand = Brand.create(name: params[:name])
    return brand.to_json
  end

  # @method /brands.json
  post '/brands.json' do
    return 'Missing json data' if params[:json].nil?

    json = JSON.parse(params[:json])
    if json['kind'] == 'Brand'
      json['data'].each do |brand|
        Brand.create(name: brand['name'])
      end
    end
  end

  # @method /ranges
  # Returns all PaintRanges.
  get '/ranges.json' do
    return PaintRange.all.to_json
  end

  # @method /ranges/id
  # @param id [Integer] The PaintRange's id.
  # Returns the PaintRange with the given id.
  get '/ranges/:id.json' do |id|
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

  # @method /ranges.json
  post '/ranges.json' do
    return 'Missing json data' if params[:json].nil?

    json = JSON.parse(params[:json])
    if json['kind'] == 'Range'
      json['data'].each do |range|
        Range.create(name: range['name'],
                     brand_id: range['brand_id'])
      end
    end
  end

  # @method /paints
  # Returns all Paints.
  get '/paints.json' do
    return Paint.all.to_json
  end

  # @method /paints/id
  # @param id [Integer] The Paint to fetch with given id.
  # Returns Paint with given id.
  get '/paints/:id.json' do |id|
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

  # @method /paints.json
  post '/paints.json' do
    return 'Missing json data' if params[:json].nil?

    json = JSON.parse(params[:json])
    if json['kind'] == 'Paint'
      json['data'].each do |paint|
        Paint.create(name: paint['name'],
                     color: paint['color'],
                     range_id: paint['range_id'])
      end
    end
  end

  # @method /status_key
  # Returns all StatusKeys
  get '/status_keys.json' do
    return StatusKey.all.to_json
  end

  # @method /status_keys/id
  # @param id [Integer] The id of the StatusKey to fetch.
  # Returns StatusKey with given id.
  get '/status_keys/:id.json' do |id|
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

  # @method /user.json
  # @param email [String] The email of the new user.
  # @param password [String] The password of the new user.
  # Returns the new User.
  post '/user.json' do
    user = User.create(email: params[:email], password: params[:password])
    return user.to_json if user.valid?
    return JSON(errors: user.errors.to_a)
  end

  # @method /paint_statuses
  # Returns all the PaintStatuses
  get '/paint_statuses.json' do
    return PaintStatus.all.to_json
  end

  get '/paint_statuses/:id.json' do |id|
    return PaintStatus.where(paint_id: id).to_json
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

  # @method /sync.json
  # Returns all Brands, PaintRanges, Paints and StatusKeys.
  get '/sync.json' do
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

  # @method /sync.json
  post '/sync.json' do
    params['paint'].each do |paint|
      status = PaintStatus.where(paint_id: paint['id'], user_id: 1)
               .first_or_create
      status.status = paint['status']
      status.save
    end
  end

  post '/login' do
    user = User.find_by(email: params[:email]).try(:authenticate, params[:password])
    session[:user_id] = user.id unless user.nil?
  end

  if app_file == $PROGRAM_NAME
    db_config = YAML.load(File.open('db/config.yml'))
    environment = ENV['ENV']
    ActiveRecord::Base.establish_connection(db_config[environment])
    set :bind, '0.0.0.0'
    set :public_folder, 'public'
    set :raise_errors, true
    set :dump_errors, false
    set :show_exceptions, false
    run!
  else
    db_config = YAML.load(File.open('db/config.yml'))
    environment = ENV['ENV']
    ActiveRecord::Base.establish_connection(db_config[environment])
  end
end
