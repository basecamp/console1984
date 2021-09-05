class Console1984::ProtectionsConfig
  include Console1984::Freezeable

  delegate :static_validations, to: :instance

  attr_reader :config

  def initialize(config)
    @config = config
  end

  def static_validations
    config[:static_validations]
  end
end
