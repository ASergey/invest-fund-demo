class RoleName
  NO_ROLE           = :no_role
  ADMIN             = :admin
  ADMIN_READ_ONLY   = :admin_read_only
  MANAGER           = :manager
  FINANCIAL_MANAGER = :fin_manager
  INVESTOR          = :investor

  DEVELOPER         = :developer

  def self.all
    {
      NO_ROLE           => 'None',
      ADMIN             => 'Admin',
      ADMIN_READ_ONLY   => 'Admin Read Only',
      MANAGER           => 'Manager',
      FINANCIAL_MANAGER => 'Financial manager',
      INVESTOR          => 'Investor'
    }
  end

  def self.description(name)
    all[name]
  end
end
