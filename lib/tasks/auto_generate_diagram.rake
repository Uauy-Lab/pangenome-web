# NOTE: only doing this in development as some production environments (Heroku)
# NOTE: are sensitive to local FS writes, and besides -- it's just not proper
# NOTE: to have a dev-mode tool do its thing in production.

class RailsERD::Domain
		def name
			puts "We are on the monkey fdsfdsfds patch"
			name = false
			if defined? Rails and Rails.application
				if Rails::VERSION::MAJOR >= 6
					name = Rails.application.class.module_parent.name
				else
					name = Rails.application.class.parent.name
				end
			end
			return name
	end
end

if Rails.env.development?
  print "about to add the tasks!"
  RailsERD.load_tasks
end

