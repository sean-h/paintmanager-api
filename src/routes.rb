require 'bcrypt'
require 'date'
require 'json'
require 'securerandom'
require 'sinatra/activerecord'
require 'sinatra/base'
require_relative './brand'
require_relative './compatibility_group'
require_relative './compatibility_paint'
require_relative './paint'
require_relative './paint_range'
require_relative './user'
require_relative './status_key'
require_relative './paint_status'

# Entry point of the application.
class Routes < Sinatra::Base
  auth_tokens = {}

  configure do
    p 'Config'
    db_config = YAML.load(File.open('db/config.yml'))
    environment = ENV['ENV'] || 'development'
    ActiveRecord::Base.establish_connection(db_config[environment])
    set :public_folder, 'public'
  end

  before do
    @user = User.where(id: auth_tokens[request.env['HTTP_AUTHORIZATION']]).first
  end

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
    return { auth_error: 'You must be logged in to access this page' }.to_json if @user.nil?
    brand = Brand.create(name: params[:name])
    return brand.to_json
  end

  # @method /brands.json
  post '/brands.json' do
    return { auth_error: 'You must be logged in to access this page' }.to_json if @user.nil?
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
    return { auth_error: 'You must be logged in to access this page' }.to_json if @user.nil?
    range = PaintRange.create(name: params[:name],
                              brand_id: params[:brand_id])
    return range.to_json
  end

  # @method /ranges.json
  post '/ranges.json' do
    return { auth_error: 'You must be logged in to access this page' }.to_json if @user.nil?
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
    return { auth_error: 'You must be logged in to access this page' }.to_json if @user.nil?
    paint = Paint.create(name: params[:name],
                         color: params[:color],
                         range_id: params[:range_id])
    return paint.to_json
  end

  # @method /paints.json
  post '/paints.json' do
    return { auth_error: 'You must be logged in to access this page' }.to_json if @user.nil?
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

  # @method /paint_groups.json
  get '/paint_groups.json' do
    #return { auth_error: 'You must be logged in to access this page' }.to_json if @user.nil?
    results = CompatibilityGroup
             .select("compatibility_groups.id, #{group_concat('compatibility_paints.paint_id')} as paint_id")
             .joins('LEFT OUTER JOIN compatibility_paints ON compatibility_groups.id = compatibility_groups_id')
             .group('compatibility_groups.id')
             .as_json
    results.each do |result|
      result['paint_id'] = result['paint_id'].split(',').map(&:to_i)
    end

    results.to_json
  end

  # @method /paint_groups
  post '/paint_groups.json' do
    json_params = JSON params[:json]

    if json_params['id'] == 0
      group = CompatibilityGroup.create
    else
      group = CompatibilityGroup.find(json_params['id'])
    end
    
    json_params['paint_id'].each do |paint_id|
      CompatibilityPaint.create(paint_id: paint_id,
                                compatibility_groups_id: group.id) 
    end

    group.to_json
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
    return { auth_error: 'You must be logged in to access this page' }.to_json if @user.nil?
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
    return { auth_error: 'You must be logged in to access this page' }.to_json if @user.nil?
    status = PaintStatus.where(paint_id: params['paint_id'], user_id: @user.id)
             .first_or_create
    status.status = params['status']
    status.save
    return status.to_json
  end

  # @method /sync.json
  # Returns all Brands, PaintRanges, Paints and StatusKeys.
  get '/sync.json' do
    #return { auth_error: 'You must be logged in to access this page' }.to_json if @user.nil?
    brands = Brand.all
    ranges = PaintRange.all
    paints = Paint.select('paints.*,
                           COALESCE(paint_statuses.status, 1) AS status')
             .joins('LEFT OUTER JOIN paint_statuses
                     ON paints.id = paint_statuses.paint_id')
    status_keys = StatusKey.all
    groups = CompatibilityGroup
             .select("compatibility_groups.id, #{group_concat('compatibility_paints.paint_id')} as paint_id")
             .joins('LEFT OUTER JOIN compatibility_paints ON compatibility_groups.id = compatibility_groups_id')
             .group('compatibility_groups.id')
             .as_json
    p groups
    groups.each do |result|
      result['paint_id'] = result['paint_id'].split(',').map(&:to_i) unless result['paint_id'].nil?
    end
    data = { brand: brands, paint_range: ranges,
             paint: paints, status_key: status_keys,
             compatibility_groups: groups }
    return data.to_json
  end

  # @method /sync.json
  post '/sync.json' do
    return { auth_error: 'You must be logged in to access this page' }.to_json if @user.nil?
    json = JSON params['JSON']
    unless json['paints'].nil?
      json['paints'].each do |paint|
        status = PaintStatus.where(paint_id: paint['id'], user_id: @user.id)
                 .first_or_create
        status.status = paint['status']
        status.save
        p paint
        p status
      end
    end
    last_sync = DateTime.strptime(json['last_sync'].to_s, '%Q')
    last_sync_formatted = last_sync.strftime('%Y-%m-%d %H:%M:%S.%L')

    brands = Brand.where('updated_at > ?', last_sync_formatted)
    ranges = PaintRange.where('updated_at > ?', last_sync_formatted)
    paints = Paint.select('paints.id, paints.name, paints.color, paints.range_id,
                           COALESCE(paint_statuses.status, 1) AS status')
             .joins('LEFT OUTER JOIN paint_statuses
                     ON paints.id = paint_statuses.paint_id')
             .where('paint_statuses.updated_at > ? AND user_id = ?', last_sync_formatted, @user.id)
    data = { brand: brands, paint_range: ranges, paint: paints }
    return data.to_json
  end

  post '/login' do
    begin
      user = User.find_by(email: params[:email]).try(:authenticate, params[:password])
      auth = SecureRandom.base64
      auth_tokens[auth] = user.id
      return { auth_token: auth }.to_json unless user.nil?
    rescue
      return { error: 'Failed to login' }.to_json
    end
    { error: 'Failed to login' }.to_json
  end

  def group_concat(column)
    return "array_to_string(array_agg(#{column}), ',')" if ENV['ENV'] == 'production'
    "group_concat(#{column})"
  end

end
