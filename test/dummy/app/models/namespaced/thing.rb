# frozen_string_literal: true

class Namespaced::Thing < ApplicationRecord
  self.table_name = "people"
  encrypts :name
end
