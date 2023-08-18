# frozen_string_literal: true

require 'google_drive'
require 'googleauth'
require_relative '../helpers/cohort_files'

# Handles Google Drive session and file formatting for this speciffic program
class GoogleSession
  include CohortFiles
  def initialize(credentials_file)
    @session = GoogleDrive::Session.from_service_account_key(credentials_file)
  end

  def get_file(cohort, mod, week)
    week = week.gsub(' ', '_')
    mod = mod.gsub(' ', '_')

    locate_file(cohort, week, mod)
  end

  def locate_file(cohort, week, mod)
    cohort_folder = @session.file_by_title(cohort)
    raise "Folder #{cohort} was not found" unless cohort_folder

    module_folder = cohort_folder.file_by_title(modulos[mod]['folder'])
    raise "Module folder #{modulos[mod]['folder']} was not found" unless module_folder

    file = module_folder.file_by_title(format_file_title(week, mod))
    raise "File #{format_file_title(week, mod)} was not found" unless file

    file
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
