get '/posts' do
  #display a list of all posts
end

get '/posts/new' do
  #return an HTML form for creating a new posts
end

post '/posts' do
  #create a new posts
end

get '/posts/:id' do
  #display a specific article posts
end

get '/posts/:id/edit' do
  #return an HTML form for editing posts
end

put '/posts/:id' do
  # update a specific posts
end

delete '/posts/:id' do
  #delete a specific posts
end
