require "db"
require "sqlite3"

# Class that represents a bookmark.
# `id` will be 0 if it's not saved in the database.
# `url` is not nillable
class Bookmark
  DB.mapping({
    id:  Int64,
    url: String,
  })

  def initialize(@url)
    @id = 0
  end
end

# Usage:
#
# ```
# require "./bmdb"
#
# db = BMDB.new
# pp! db.read_all # => []
#
# b = Bookmark.new "https://crystal-lang.org"
# pp! b # => #<Bookmark:0x106a13ce0 @id=0_i64, @url="https://crystal-lang.org">
# db.create b
# pp! b # => #<Bookmark:0x106a13ce0 @id=1_i64, @url="https://crystal-lang.org">
#
# pp! db.read_all # => [#<Bookmark:0x10ff07620 @id=1_i64, @url="https://crystal-lang.org">]
#
# db.close
# ```
#
class BMDB
    @db : DB::Database
  
    def initialize(database_url = "sqlite3://bookmarks.db")
      @db = DB.open database_url
  
      @db.exec %(
        CREATE TABLE IF NOT EXISTS bookmarks
          ( id INTEGER PRIMARY KEY AUTOINCREMENT
          , url TEXT
          )
      )
    end
  
    def close
      @db.close
    end
  
    def read_all
      Bookmark.from_rs(@db.query("SELECT id, url FROM bookmarks"))
    end
  
    def create(b : Bookmark)
      b.id = @db.exec("INSERT INTO bookmarks (url) VALUES (?)", b.url).last_insert_id
      b
    end
  
    def destroy(id : Int64)
      @db.exec("DELETE FROM bookmarks where id = ?", id)
    end
  end
  