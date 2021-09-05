ActiveRecord::Base.class_eval do
  def save!(*args)
    puts "ActiveRecord::Base#save! overridden!"
  end
end
