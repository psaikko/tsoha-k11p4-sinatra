include Rack::Utils

def h text 
	escape_html(text)
end

def is_admin? user
  user && user.admin
end
