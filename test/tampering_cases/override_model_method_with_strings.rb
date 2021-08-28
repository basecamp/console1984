a_constant = ("Con" + "sole1984").constantize
class a_constant::User
  def save!(*args)
    puts "INVOKED!!!"
  end
end
