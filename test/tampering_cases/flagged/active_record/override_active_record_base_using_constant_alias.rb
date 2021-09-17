MyAlias = ActiveRecord

class MyAlias::Base
  def save!(*args)
    puts "ActiveRecord::Base#save! overridden!"
  end
end
