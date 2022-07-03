MyAlias = ApplicationRecord

class MyAlias
  def save!(*args)
    puts "ApplicationRecord#save! overridden!"
  end
end
