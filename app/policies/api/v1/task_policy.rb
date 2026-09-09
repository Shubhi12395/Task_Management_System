class Api::V1::TaskPolicy < ApplicationPolicy
  # NOTE: Up to Pundit v2.3.1, the inheritance was declared as
  # `Scope < Scope` rather than `Scope < ApplicationPolicy::Scope`.
  # In most cases the behavior will be identical, but if updating existing
  # code, beware of possible changes to the ancestors:
  # https://gist.github.com/Burgestrand/4b4bc22f31c8a95c425fc0e30d7ef1f5
  def create?
    true
  end
  def index?
    user.present?
  end
  def show?
    true
  end
  def sort?
    true
  end
  def search?
    true
  end
  def update_all?
    true
  end
  def duetoday?
    true
  end
  def destroy_all?
    true
  end
  def overdue?
    true
  end
  def pending?
    true
  end
  def by_priority?
    true
  end
  def destory?
    true
  end
  
  class Scope < ApplicationPolicy::Scope
    # NOTE: Be explicit about which records you allow access to!
    # def resolve
    #   scope.all
    # end
  end
end
