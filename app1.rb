
class App < Sinatra::Application
	get '/' do
		"Hello Fotini"
		"Hello from Berat too"
	end

	get '/form' do
		haml:form
	end
end

