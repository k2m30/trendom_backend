class PeopleController < ApplicationController
  skip_before_filter :verify_authenticity_token, only: [:find, :download]

  def find
    logger.warn params
    respond_to do |format|
      format.json { render json: Person.get_emails(person_params) }
    end
  end

  def download

  end

  def count
    render text: 'Total: ' << Person.count.to_s <<
        ', Emails: ' << Person.where.not(email: nil).count.to_s <<
        ', Linkedin IDs: ' << Person.where.not(linkedin_id: nil).count.to_s <<
        ', Notes: ' << Person.where.not(notes: nil).count.to_s
  end

  def search
    @people = Person.limit(100)
  end

  private
  def person_params
    params.permit!#(:name, :linkedin_id, :position, :location, :industry, :email)
  end
end
