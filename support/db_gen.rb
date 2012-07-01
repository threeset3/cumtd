#!/usr/bin/ruby

# TODO backup database
# TODO remove database
# create database

require 'rubygems'
require 'sqlite3'
require 'json'
require 'rest-client'

module Cumtd
  class DatabaseGenerator
    DB_NAME = 'cumtdDB.db'

    STOP_TABLE_SQL = <<-SQL
      CREATE TABLE stopTable (
      _id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
      _stop VARCHAR(15) UNIQUE,
      _name VARCHAR(50),
      _latitude INTEGER,
      _longitude INTEGER,
      _favorite BOOLEAN);
    SQL

    INDEXES_SQL = <<-SQL
      CREATE INDEX _stop_idx ON stopTable (_stop);
      CREATE INDEX _lat_idx ON stopTable (_latitude);
      CREATE INDEX _long_idx ON stopTable (_longitude);
      CREATE INDEX _fav_idx ON stopTable (_favorite)
    SQL

    INSERT_SQL = <<-SQL
      INSERT INTO stopTable
      (_stop, _name, _latitude, _longitude, _favorite)
      VALUES (?, ?, ?, ?, ?)
    SQL

    def initialize(db_name = DB_NAME)
      @db_path = "./#{db_name}"
    end

    def run
      puts "deleting database"
      delete_database

      puts "creating database and tables"
      create_database_and_tables

      puts "inserting stop data"
      insert_stop_datas(StopData.new().execute)
    end

    def delete_database
      File.delete(@db_path)
    end

    def create_database_and_tables
      @db = SQLite3::Database.new @db_path
      @db.execute STOP_TABLE_SQL
      @db.execute INDEXES_SQL
    end

    def insert_stop_datas(stop_datas)
      stop_datas.each do |stop_data|
        @db.execute(INSERT_SQL, stop_data[:stop_id], stop_data[:name],
                    stop_data[:latitude], stop_data[:longitude], 0)
      end
    end
  end

  class StopData
    CUMTD_API_KEY = "9353bd1b2c2d4f7f814b698d5006be92"
    GET_STOPS_URL = "http://developer.cumtd.com/api/v2.1/json/GetStops"
    # multiplier needed to store lat/long as integers in db
    LAT_LONG_MULTIPLIER = 1000000

    def fetch_stop_data
      @response = RestClient.get GET_STOPS_URL, {:params => {:key => CUMTD_API_KEY}}
    end

    def format_stop_data
      json = JSON.parse(@response)
      raw_stops = json['stops']

      @stops = []
      raw_stops.each do |raw_stop|
        stop_points = raw_stop['stop_points']
        stop_points.each do |stop_point|
          formatted_stop = {
            :stop_id => stop_point['stop_id'],
            :name => stop_point['stop_name'],
            :latitude => stop_point['stop_lat'] * LAT_LONG_MULTIPLIER,
            :longitude => stop_point['stop_lon'] * LAT_LONG_MULTIPLIER
          }
          @stops << formatted_stop 
        end
      end
    end

    def execute
      puts "fetching stop data"
      fetch_stop_data

      puts "formatting stop data"
      format_stop_data
      @stops
    end
  end
end

Cumtd::DatabaseGenerator.new.run
