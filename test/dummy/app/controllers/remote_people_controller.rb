class RemotePeopleController < ApplicationController
  def show
    render json: Person.find(params[id])
  end
end
