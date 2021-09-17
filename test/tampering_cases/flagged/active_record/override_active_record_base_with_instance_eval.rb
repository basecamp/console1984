person = Person.first
person.instance_eval do
  def save!(*args)
    puts "ActiveRecord::Base#save! overridden!"
  end
end
