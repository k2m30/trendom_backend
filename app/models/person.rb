require_relative 'full_contact_db'
require_relative 'pipl_db'

class Person < ActiveRecord::Base
  has_and_belongs_to_many :users

  def self.get(params)
    person = Person.find_by(linkedin_id: params[:linkedin_id])
    if person.present?
      return person.to_json
    else
      person = PiplDb.find(params) #|| FullContactDb.find(params)
      if person.present?
        return Person.create(params.merge!(person)).to_json
      else
        return {}
      end
    end
  end
end

# a = '{
#     "name": "Nikolay Lagutko",
#     "linkedin": "123456",
#     "company": "InDataLabs",
#     "position": "Senior engineer",
#     "location": "London, UK"
# }'
#
# URI.encode_www_form(JSON.parse(a))
# http://localhost:3000/persons/find?name=Nikolay+Lagutko&linkedin=123456&company=InDataLabs&position=Senior+engineer&location=London%2C+UK

# http://localhost:3000/persons/find.json?name=Leigh+Bromby&linkedin_id=178274623&company=InDataLabs&position=Senior+engineer&location=London%2C+UK