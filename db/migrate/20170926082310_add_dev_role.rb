class AddDevRole < ActiveRecord::Migration[5.1]
  def change
    Role.find_or_create_by(name: RoleName::DEVELOPER)
    developer = User.find_by(email: 'saleynikov@3atdev.com')
    developer.add_role(RoleName::DEVELOPER) if developer.present?
  end
end
