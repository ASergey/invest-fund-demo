FactoryGirl.define do
  factory :user do
    sequence(:name)     { |n| "My name" }
    sequence(:email)    { |n| "#{name.parameterize}-#{n}@email.com".downcase }
    sequence(:password) { |n| "password-#{n}" }
  end

  factory :user_admin, parent: :user do
    name           'Admin'
    after(:create) { |user| user.add_role(RoleName::ADMIN) }

    trait :developer do
      after(:create) { |user| user.add_role(RoleName::DEVELOPER) }
    end
  end

  factory :user_manager, parent: :user do
    name           'Manager'
    after(:create) { |user| user.add_role(RoleName::MANAGER) }
  end

  factory :user_fin_manager, parent: :user do
    name           'Financial Manager'
    after(:create) { |user| user.add_role(RoleName::FINANCIAL_MANAGER) }
  end

  factory :user_investor, parent: :user do
    name             'Investor'
    sequence(:phone) { |n| "+123456789#{n}" }
    is_gp            true
    is_lp            false
    reinvest         true
    after(:create) { |user| user.add_role(RoleName::INVESTOR) }
  end
end
