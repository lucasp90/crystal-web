require "kemal"
require "./bmdb"

db = BMDB.new

class BookmarksView
    getter bookmarks

    def initialize(@bookmarks : Array(Bookmark))
    end

    ECR.def_to_s "#{__DIR__}/bookmarks.ecr"
end

get "/" do
  "Hello World!"
end

get "/bookmarks" do
    bookmarks = db.read_all
    BookmarksView.new(bookmarks).to_s
end

post "/bookmarks" do | env |
    url = env.params.body["url"]
    db.create Bookmark.new(url)
    env.redirect "/bookmarks"
end

post "/bookmarks/:id/destroy" do | env |
    id = env.params.url["id"].to_i64
    db.destroy(id)
    env.redirect "/bookmarks"
end

Kemal.run
