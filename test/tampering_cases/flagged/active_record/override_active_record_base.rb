class ActiveRecord::Base
  def save!(*args)
    puts "ActiveRecord::Base#save! overridden!"
  end
end
