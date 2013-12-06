require 'spec_helper'

describe OrganisationsController do
  describe '#index' do

    let!(:organisation_z) { create :organisation, :with_site, title: 'Zzzzzz' }
    let!(:organisation_a) { create :organisation, :with_site, title: 'Aaaaaa' }

    before do
      login_as_stub_user
      get :index
    end

    it 'orders organisations alphabetically' do
      assigns(:organisations).should == [organisation_a, organisation_z]
    end
  end
end
