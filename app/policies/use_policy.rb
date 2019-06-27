class UsePolicy < ApplicationPolicy

  def create?
    true
  end

  def update?
    true
  end

  def destroy?
    record.appliances.blank?
  end

  def refresh_load?
    true
  end

end
