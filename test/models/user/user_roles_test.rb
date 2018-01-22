require 'test_helper'

class RolesTest < ActiveSupport::TestCase
  test 'admin role' do
    user = create(:user)

    assert_not user.has_role?(RoleName::ADMIN)
    user.add_role(RoleName::ADMIN)

    assert user.has_role?(RoleName::ADMIN)
  end

  test 'investor' do
    user = create(:user_investor)
    assert user.has_role?(RoleName::INVESTOR)
    assert_not user.has_any_role?(RoleName.all.delete(RoleName::INVESTOR))
  end
end
