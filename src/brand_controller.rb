class BrandController
  def get_all_brands
    Brand.all.to_json
  end

  def get_brand(id)
    Brand.where(id: id).to_json
  end

  def add_brand(name)
    brand = Brand.new(name: name)    
    return { error: brand.errors.messages } unless brand.valid?
    brand.save
    brand
  end
end
