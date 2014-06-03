class User < ActiveRecord::Base
  include GDS::SSO::User

  has_many :mappings_batches

  serialize :permissions, Array

  attr_accessible :uid, :email, :name, :permissions, :organisation_slug, as: :oauth

  def admin?
    permissions.include?('admin')
  end

  def gds_editor?
    permissions.include?('GDS Editor')
  end

  def can_edit_sites
    @can_edit_sites ||= {}
  end

  def can_edit_site?(site_to_edit)
    can_edit_sites[site_to_edit.abbr] ||= begin
      gds_editor? ||
        own_organisation == site_to_edit.organisation ||
        site_to_edit.organisation.parent_organisations.include?(own_organisation) ||
        site_to_edit.extra_organisations.include?(own_organisation) &&
        site_to_edit.global_http_status.blank?
    end
  end

  def own_organisation
    @_own_organisation ||=
      Organisation.find_by_whitehall_slug(organisation_slug) if organisation_slug
  end

  def is_human?
    ! is_robot?
  end
end
