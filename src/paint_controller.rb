class PaintController
  def get_all_paints
    Paint.all.to_json
  end

  def get_paint(id)
    Paint.where(id: id).to_json
  end

  def add_paint(name, color, range_id)
    paint = Paint.new(name: name, color: color, range_id: range_id)
    return { error: paint.errors.messages } unless paint.valid?
    paint.save
    paint
  end
end
