begin
  RemotePerson.find("922004269") # 922004269 is people(:jorge).id
rescue Errno::ECONNREFUSED, ActiveResource::ServerError
  # This is fine, we want to discard the command tries to execute without being prevented.
end
