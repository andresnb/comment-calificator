require 'google_drive'
require 'googleauth'
require_relative 'helpers/cohort_files'

class Google
  inlcude CohortFiles
  def initialize(credentials_file)
    @session = GoogleDrive::Session.from_service_account_key(credentials_file)
  end

  def get_file(cohort, mod, week)
    week = week.gsub(' ', '_')
    mod = mod.gsub(' ', '_')

    cohort_folder = @session.file_by_title(cohort)
    module_folder = cohort_folder.file_by_title(modulos[mod]['folder'])

    module_folder.file_by_title(format_file_title(week, mod))
  end

  def format_file_title(week, mod)
    "#{week}-#{project_type(mod, week)}-#{project_name(mod, week)}"
  end

  def project_type(mod, week)
    modulos[mod]['projects'][week][:type]
  end

  def project_name(mod, week)
    modulos[mod]['projects'][week][:name]
  end
end
