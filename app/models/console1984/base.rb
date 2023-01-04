module Console1984
  class Base < ActiveRecord::Base
    self.abstract_class = true
  end
end

ActiveSupport.run_load_hooks(:console_1984_base, Console1984::Base)
