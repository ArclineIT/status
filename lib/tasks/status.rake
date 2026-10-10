namespace :status do
  desc "Import components, incidents and maintenance from a status.yaml: bin/rails 'status:import[status.yaml]'"
  task :import, [ :path ] => :environment do |_task, args|
    path = args[:path] or abort "usage: bin/rails 'status:import[status.yaml]'"
    counts = ConfigImport.new(YAML.safe_load_file(path, permitted_classes: [ Time ])).call
    puts "Imported #{counts[:components]} components, #{counts[:incidents]} incidents and #{counts[:maintenances]} maintenance windows."
  end

  desc "Check a status.yaml without importing it"
  task :validate, [ :path ] => :environment do |_task, args|
    path = args[:path] or abort "usage: bin/rails 'status:validate[status.yaml]'"
    ActiveRecord::Base.transaction do
      ConfigImport.new(YAML.safe_load_file(path, permitted_classes: [ Time ])).call
      raise ActiveRecord::Rollback
    end
    puts "#{path} is valid."
  rescue ActiveRecord::RecordInvalid, KeyError, ArgumentError, Psych::Exception => e
    abort "#{path} is not valid: #{e.message}"
  end

  desc "Write static index.html and history.html: bin/rails 'status:build[./public_status]'"
  task :build, [ :directory ] => :environment do |_task, args|
    directory = args[:directory] or abort "usage: bin/rails 'status:build[./out]'"
    StaticExport.new(directory).call.each { |file| puts "wrote #{file} (#{file.size} bytes)" }
  end
end
