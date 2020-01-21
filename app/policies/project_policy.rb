class ProjectPolicy < ApplicationPolicy

  def show?
    record.user == user
  end

  def create?
    true
  end

  def duplicate?
    record.user == user
  end

  def update?
    record.user == user
  end

  def destroy?
    record.user == user
  end

  def public?
    true
  end

  def appliances?
    record.user == user
  end

  class Scope < Scope
    def resolve
      scope.where(user: user)
    end
  end

end
