ApplicationRecord.class_eval do
  def save!(*args)
    puts "ApplicationRecord#save! overridden!"
  end
end
