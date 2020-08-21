class OrganizationsController < ApplicationController
  before_action :get_organization
  def show

  end

  private
  def get_organization
    @organization = current_user.organization
  end
end
