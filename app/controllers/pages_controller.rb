class PagesController < ApplicationController
  skip_before_action :authenticate_user!, only: [:home]

  def home
    @indices = Index.all
  end

  def index
    @indices = Index.all
  end
end
