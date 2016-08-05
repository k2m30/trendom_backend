require 'rails_helper'

RSpec.describe 'User' do
  include ActiveJob::TestHelper

  after do
    clear_enqueued_jobs
  end

  it 'adds profiles' do

    expect(User.count).to eq(0)
    hash = {"source"=>"linkedin", "uid"=>"102594557413371756317", "email"=>"mikhail.chuprynski@gmail.com", "version"=>1, "data"=>[{"name"=>"Brendan Walsh", "id"=>"36304244", "public_id"=>"ADEAAAIp9XQBCEvzDGR0C1M2i5Q8PdwzTgd1kDA", "position"=>"Regional Director at Zuora", "location"=>"London, United Kingdom", "photo"=>"https://media.licdn.com/mpr/mpr/shrink_100_100/AAEAAQAAAAAAAAXuAAAAJGViNmYyMDIwLTkyNzEtNDBlMS04MGU1LTE3NGNjNDI0OWZmYw.jpg"}, {"name"=>"Sunita Varsani", "id"=>"41695464", "public_id"=>"ADEAAAJ8OOgBeJldNn_LRAePOL73kRP-qDpt9V0", "position"=>"HR Director at Fifosys", "location"=>"London, United Kingdom", "photo"=>"https://static.licdn.com/scds/common/u/images/themes/katy/ghosts/person/ghost_person_100x100_v1.png"}, {"name"=>"Kaan Azmi", "id"=>"24183179", "public_id"=>"ADEAAAFxAYsB7Xj1w9FrdiefJ6WId2KMxT-_1mg", "position"=>"Director at Russell King Associates", "location"=>"London, United Kingdom", "photo"=>"https://media.licdn.com/mpr/mpr/shrink_100_100/AAEAAQAAAAAAAAf5AAAAJGYzMzVhNDNjLWQ1ZjYtNDYyOS05YmJmLTcxNWZmNGQ2ODE3MQ.jpg"}, {"name"=>"Jonathan Butterfield", "id"=>"2134124", "public_id"=>"ADEAAAAgkGwB7Md44VAtc-_omrfZB68BcaGyvKo", "position"=>"Director at Talent International Holdings Pty Limited", "location"=>"London, United Kingdom", "photo"=>"https://media.licdn.com/mpr/mpr/shrink_100_100/AAEAAQAAAAAAAAY7AAAAJGY4M2FiNjhhLTBiYjgtNGY0OC1iYWMxLTQ4NjNjZjE1MjZkYw.jpg"}, {"name"=>"Eleonora Ferrero", "id"=>"33705437", "public_id"=>"ADEAAAICTd0Be1JxxAwumGEidhsdU6s3TUWdS4Y", "position"=>"Director of European Operations at Mind The Bridge Foundation", "location"=>"London, United Kingdom", "photo"=>"https://media.licdn.com/mpr/mpr/shrink_100_100/p/3/000/273/23d/03561d0.jpg"}, {"name"=>"Marcin Kierdelewicz", "id"=>"5318990", "public_id"=>"ADEAAABRKU4B-GlX0zzxUJCYcJ4ktXRT2WJjW24", "position"=>"Director, Global Channel Business Development at Canonical Ltd.", "location"=>"London, United Kingdom", "photo"=>"https://media.licdn.com/mpr/mpr/shrink_100_100/AAEAAQAAAAAAAAOoAAAAJGFiM2U2ZTZlLTMyZWEtNDJmYy1hZjNiLTg1Nzc3OWM3NmZhZg.jpg"}, {"name"=>"Fraser Riddington", "id"=>"5123489", "public_id"=>"ADEAAABOLaEBVD1ZJcJb1USsCPgbUrrRaFW6F5c", "position"=>"Director at WIDEN THE NET", "location"=>"London, United Kingdom", "photo"=>"https://media.licdn.com/mpr/mpr/shrink_100_100/p/1/000/00c/3a9/1d9464b.jpg"}], "user"=>{"email"=>"mikhail.chuprynski@gmail.com", "uid"=>"102594557413371756317"}}
    page.driver.post '/people/find', hash
    expect(response.status).to eq(200)
    expect(User.count).to eq(1)

    user = User.first
    expect(user.calls_left).to eq(10)
    expect(user.profiles.size).to eq(0)
    expect(Profile.count).to eq(7)


    page.driver.post '/home/add_profiles', hash
    user.reload
    expect(user.calls_left).to eq(3)
    expect(user.profiles.size).to eq(7)
    expect(user.profiles_with_hidden_emails.size).to eq(0)
    expect(user.profiles_with_revealed_emails.size).to eq(7)
    expect(user.revealed_ids.size).to eq(7)
    expect(JSON.parse(page.body, symbolize_names: true)[:status][:calls_left].to_i).to eq(3)

    page.driver.post '/people/find', hash
    page.driver.post '/home/add_profiles', hash
    user.reload
    expect(user.calls_left).to eq(3)
    expect(user.profiles.size).to eq(7)
    expect(user.profiles_with_hidden_emails.size).to eq(0)
    expect(user.profiles_with_revealed_emails.size).to eq(7)
    expect(user.revealed_ids.size).to eq(7)

    hash = {"source"=>"linkedin", "uid"=>"102594557413371756317", "email"=>"mikhail.chuprynski@gmail.com", "version"=>1, "data"=>[{"name"=>"Sandra Divova", "id"=>"378564585", "public_id"=>"ADEAABaQb-kB8kUowbHRrs8URfodM0mdUQ2gSnI", "position"=>"Business Development at Devs.lt", "location"=>"Lithuania", "photo"=>"https://media.licdn.com/mpr/mpr/shrink_100_100/AAEAAQAAAAAAAAMOAAAAJGY3ZmUzNmZmLTIwMzUtNDFhOC1iNTAzLTljZDY5MDFjMWE0Yw.jpg"}, {"name"=>"Luke Cervino", "id"=>"363088946", "public_id"=>"ADEAABWkTDIBPgLOtDl2eUFGhaybvxR9jkvUDp0", "position"=>"Head of Projects – Talent Acquisition at Global {M}", "location"=>"London, United Kingdom", "photo"=>"https://media.licdn.com/mpr/mpr/shrink_100_100/AAEAAQAAAAAAAAILAAAAJDYzM2Q2MTkyLTdiYmItNDcyMy04MmEyLWQ1NDFmOTFiZGU4OA.jpg"}, {"name"=>"Natasha Zaharova", "id"=>"408152247", "public_id"=>"ADEAABhT6LcBBh_NwTt9jzAYUtJVRjcoRHCUoT4", "position"=>"HR Researcher - iTechArt Group", "location"=>"Belarus", "photo"=>"https://media.licdn.com/mpr/mpr/shrink_100_100/AAEAAQAAAAAAAAH7AAAAJDEyOTZjNzRjLWEzMzktNDI0MC1iYzU3LTlhMTU3MzU1MWE5Ng.jpg"}, {"name"=>"Maksim Inshakov", "id"=>"474823675", "public_id"=>"ADEAABxNO_sBOcO-bYyVwKGMjmO1zBsxi8G-RQ8", "position"=>"HR Business Partner IT at various companies, KeyStaff Recruitment", "location"=>"Belarus", "photo"=>"https://media.licdn.com/mpr/mpr/shrink_100_100/AAEAAQAAAAAAAAPjAAAAJDk1ZmYyNTAzLTg3M2UtNDJmMy1iOWY3LWZlNmQ4Mzk0MmY4MQ.jpg"}, {"name"=>"Hanna Novik", "id"=>"402548794", "public_id"=>"ADEAABf-aDoBURJdPLActoNoMtIsPO7S-z5eCQM", "position"=>"Marketing Specialist – Softacom Ltd.", "location"=>"Belarus", "photo"=>"https://media.licdn.com/mpr/mpr/shrink_100_100/AAEAAQAAAAAAAAPTAAAAJGIxODYwNjFkLTY1MjctNGVlMi1hZjM0LWNiZGI2OWQyOWZkYw.jpg"}, {"name"=>"Alex Shestel", "id"=>"424517797", "public_id"=>"ADEAABlNoKUBUnQKUEqpjr259JlT2wDnFB3NwCA", "position"=>"software engineering, founder, business development", "location"=>"Austin, Texas Area", "photo"=>"https://media.licdn.com/mpr/mpr/shrink_100_100/AAEAAQAAAAAAAAdBAAAAJGVkZjVkMTc3LTEyMjAtNGU5NC1hZDJkLTMwZTVjMzg1MWY1Yg.jpg"}, {"name"=>"Marina Kondrashonok", "id"=>"271475932", "public_id"=>"ADEAABAuZNwBjKFATlWUn7xR0pAGw7cNoYUYUQM", "position"=>"HR Manager Looking for:iOS", "location"=>"Belarus", "photo"=>"https://media.licdn.com/mpr/mpr/shrink_100_100/AAEAAQAAAAAAAAWLAAAAJGE4MzAxNjY4LTExOWYtNDg5Yy1hZDA2LWQ0MWVmYmE5OGE2Mw.jpg"}, {"name"=>"Vladislav Gramovich", "id"=>"310544262", "public_id"=>"ADEAABKCh4YBcxZCxQ0axafw26JfNj215tg36oc", "position"=>"CMO at ITS Partner", "location"=>"Belarus", "photo"=>"https://media.licdn.com/mpr/mpr/shrink_100_100/AAEAAQAAAAAAAAPdAAAAJDIxMzZkMDI2LWJiOTYtNGNmMi1iYjgyLWI1ZDIwNjY2NmYxNQ.jpg"}, {"name"=>"Olga Gotskaya", "id"=>"382617534", "public_id"=>"ADEAABbOR74BN1eeqUYByBys6ywkD93PYJ4dzhg", "position"=>"Looking for Mobile developer (Tallinn, Estonia)", "location"=>"Ukraine", "photo"=>"https://media.licdn.com/mpr/mpr/shrink_100_100/AAEAAQAAAAAAAAdpAAAAJGFlYTkxNmY3LTg3ZTYtNDkyOC1hMmViLWY4NDM0ZjViOWFhMA.jpg"}, {"name"=>"Alex Shoub", "id"=>"186327619", "public_id"=>"ADEAAAsbIkMBBi3SfCyg58DbT1Addbath5-wX-E", "position"=>"Senior Graphic Designer at APRO Software", "location"=>"Belarus", "photo"=>"https://media.licdn.com/mpr/mpr/shrink_100_100/AAEAAQAAAAAAAAPvAAAAJDU1NTQ5YzJkLTE2ZjEtNDg1My1hOGViLTk0Mjc1YWYwM2FhNg.jpg"}], "profile"=>{}}
    page.driver.post '/people/find', hash
    page.driver.post '/home/add_profiles', hash
    user.reload
    expect(user.calls_left).to eq(0)
    expect(user.profiles.size).to eq(17)
    expect(user.profiles_with_hidden_emails.size).to eq(7)
    expect(user.profiles_with_revealed_emails.size).to eq(10)
    expect(user.revealed_ids.size).to eq(10)

  end
end