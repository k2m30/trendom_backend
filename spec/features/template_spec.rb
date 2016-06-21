require 'rails_helper'

require 'capybara/rspec'
require 'capybara/rails'

require_relative 'features_common'

RSpec.feature EmailTemplate, type: :feature do
  before :each do
    login
    seed
    visit email_templates_path
  end

  let(:user) { User.first }

  it 'has initial templates' do
    expect(user.email_templates.size).to be 2
    expect(all('.template').size).to be 2
  end

  it 'can delete template' do
    templates_before = user.email_templates.size
    find('#delete-template').click
    templates_after = user.email_templates.size
    expect(templates_before - templates_after).to be 1
  end

  it 'can delete all templates' do
    while all('.template').size > 0 do
      find('#delete-template').click
    end
    expect(user.email_templates.size).to be 0
  end

  it 'can clone templates' do
    templates_before = user.email_templates.size
    find('#clone-template').click
    templates_after = user.email_templates.size
    expect(templates_after - templates_before).to be 1
  end

  it 'can create new templates when user has no templates' do
    user.email_templates.destroy_all
    visit email_templates_path
    expect(page).to have_content 'create one'
    find('#create-one').click
    expect(user.email_templates.ids.size).to be 1
  end

  it 'can create new templates' do
    templates_before = user.email_templates.size
    find('#new-template').click
    templates_after = user.email_templates.size
    expect(templates_after - templates_before).to be 1
  end

end