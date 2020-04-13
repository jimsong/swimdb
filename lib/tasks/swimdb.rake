namespace :swimdb do

  task import: :environment do
    UsmsService.fetch_swimmers_from_year(2014)
  end

end
