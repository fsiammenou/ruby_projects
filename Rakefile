task :default => [:start]

task :start do
	exec "rackup -p 8888 config.ru"
end

task :db => ["db:init","db:migrate"] do
end

namespace :db do
	task :init do
		touch 'db/data.db' unless File.exist?('db/data.db')
		ruby "scripts/init_db.rb"
	end

	task :migrate do
		exec "sequel -m ./db/migrations -M 1 -E sqlite://./db/data.db"
	end
end