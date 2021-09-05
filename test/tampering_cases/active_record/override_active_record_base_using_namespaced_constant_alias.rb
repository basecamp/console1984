MyAlias = ActiveRecord::Base

class MyAlias
  def save!(*args)
    puts "ActiveRecord::Base#save! overridden!"
  end
end
