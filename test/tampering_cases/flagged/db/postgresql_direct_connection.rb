require "pg"

conn = PG::Connection.open(dbname: "some_database")
conn.exec "delete from console1984_sessions"
