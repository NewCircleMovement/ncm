module SharedMethods
  extend ActiveSupport::Concern

  def generate_slug(model, field)
    if model.new_record?
      model.slug = model[field].parameterize
    else
      unless model.slug_changed?
        if model.changed.include?(field)
          model.slug = model[field].parameterize
        end
      end
    end

  end
end