class Role < ApplicationRecord
  has_and_belongs_to_many :users, join_table: :users_roles

  belongs_to :resource,
             polymorphic: true,
             optional: true

  validates :resource_type,
            inclusion: { in: Rolify.resource_types },
            allow_nil: true

  scopify

  scope :by_names, ->(names) { where(name: names) }

  def self.select_collection
    collection = by_names(RoleName.all.keys).select(:name, :id)
    result = {}
    collection.each do |row|
      result[RoleName.description(row.name.to_sym)] = row.id
    end
    result
  end
end
