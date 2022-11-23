class ApplicationRecord
  def save!(*args)
    puts "ApplicationRecord#save! overridden!"
  end
end
