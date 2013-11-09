task :default => [:start]

task :start do
	exec "rackup rack_app.ru"
end

task :db => ["db:init","db:migrate"] do
end

namespace :db do
	task :init do
		touch 'db/data.db' unless File.exist?('db/data.db')
	#initial implementation, moved to migration 001 
		ruby "scripts/init_db.rb"

	end


	task :migrate do
		exec "sequel -m ./db/migrations -M 1 -E sqlite://./db/data.db"
	end
end
