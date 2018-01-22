class Ability
  include CanCan::Ability

  def initialize(user, _options = {})
    @user = user || User.new
    alias_action :create, :read, :update, :destroy, to: :crud
    @user.roles.each do |role|
      exec_role_rules(role.name) if @user.roles.include? role
    end
    default_rules
  end

  def exec_role_rules(role_name)
    meth = :"#{role_name}_rules"
    send(meth) if respond_to? meth
  end

  def developer_rules
    can :read, ActiveAdmin::Page, name: 'Jobs List'
  end

  # various rules methods for each role
  def admin_rules
    can :manage, :all
    can :edit_roles, User do
      @user.has_role?(RoleName::ADMIN)
    end
  end

  def admin_read_only_rules
    can :read, :all
  end

  def manager_rules
    can :read, :all
    can %i[create read update], FundOperation
    can :manage_investor, User do |user|
      user.investor? || user.id == @user.id
    end
    can %i[create update], User
    cannot :read, ApiClient
  end

  def fin_manager_rules
    manager_rules
    can :manage, FundOperation
    can :approve_operation, FundOperation
    can :manage, Instrument
    can :manage, InstrumentBalance
    can :manage, InstrumentGroup
    can :manage, Currency
    can :manage, Wallet
    can :manage, FundBalance
    can :manage, ExchangeOperation
  end

  def investor_rules; end

  def default_rules
    can :read, ActiveAdmin::Page, name: 'Dashboard'
    cannot :read, ActiveAdmin::Page, name: 'Jobs List' unless @user.has_role? RoleName::DEVELOPER
    can :read_fund_stats, User do |user|
      user.has_any_role?(
        RoleName::ADMIN,
        RoleName::ADMIN_READ_ONLY,
        RoleName::FINANCIAL_MANAGER,
        RoleName::MANAGER
      )
    end
  end
end
