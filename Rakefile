task :default => [:start]

desc 'Starts the application at port 8888'
task :start do
	exec "rackup -p 8888 config.ru"
end

desc 'Creates the database schema with default user: username/password inserted'
task :db do 
	touch 'db/data.db' unless File.exist?('db/data.db')
	exec "sequel -m ./db/migrations -M 1 -E sqlite://./db/data.db"
end

