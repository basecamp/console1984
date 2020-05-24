Rails.application.routes.draw do
  mount OrwellConsole::Engine => "/orwell_console"
end
