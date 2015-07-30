#!/usr/bin/env python
# encoding: utf-8

# this script reads files from imdb dataset interface (ftp://ftp.sunet.se/pub/tv+movies/imdb/)
# and parses them as JSON dicts to index them into elasticsearch database using python api

from elasticsearch import Elasticsearch
from elasticsearch import helpers
from hashlib import sha1
import datetime
import re

LIST = ["ACTRESSES", "ACTORS", "RATINGS"] 

def main(buffer, listname):
    print datetime.datetime.now().strftime("%Y-%m-%d %H:%M") + ": reading " + listname
    # data in imdb files begin after the line starting with "<listname> LIST
    if ( listname == "ACTORS" or listname == "ACTRESSES" ):
        lines = buffer.split('%s LIST' % listname)[1]
        actorslist = lines.split('\n\n')
        index_actors(actorslist, 'actors')
    elif ( lisname == "RATINGS" ):
        lines = buffer.split('MOVIE RATINGS REPORT')[1]
        ratingslist = lines.split('\n')
        index_ratings(ratingslist, 'ratings')
    else:
        print "invalid file"

def index_ratings(ratingslist, es_index_name):
    items = []
    idx = 0
    es = Elasticsearch()

    for ratings in ratingslist[2:]:
        idx += 1
        votes = ratings[19:23]
        rating = ratings[25:29]
        movie = ratings[32:]

        try:
            year = re.search(r"\(\d*\)", movie)
            year = year.group()[1:-1]
        except:
            year = ""

        if (len(movie.split(' (')) > 1 and len(movie.split(' )')) > 1):
            title = movie.split(' (')[0] + ' ' + movie.split(' )')[1]
        else:
            title = movie

        newitem = {
                '_index': "imdb",
                '_type': es_index_name,
                '_id': sha1(rating+title+year).hexdigest(),
                '_source': {
                    'title': title.decode('latin1'),
                    'votes': votes,
                    'rating': rating,
                    'year': year
                }
            }
        items.append(newitem)

        if ( idx > 1000 ):
            print datetime.datetime.now().strftime("%Y-%m-%d %H:%M") + ": indexing " + es_index_name
            helpers.bulk(es, items)
            items = []
            idx = 0  

def index_actors(actorslist, es_index_name):
    items = []
    actor_count = 0
    es = Elasticsearch()

    for item in actorslist[3:]:
        item = [x.split('\t') for x in item.split('\n\t\t\t')]
        idx = 0
        actor_count += 1

        # get all movies by actor
        for movies in item:
            if ( idx == 0 ):
                name = movies[0]
                try:
                    movie = movies[1]
                except:
                    movie = ""
            else:
                movie = movies[0]

            idx += 1

            try:
                role = re.search(r"\[.*?\]", movie)
                role = role.group()[1:-1]
            except:
                role = ""

            try:
                year = re.search(r"\(\d*\)", movie)
                year = year.group()[1:-1]
            except:
                year = ""

            title = movie.split(' (')[0]

            newitem = {
                '_index': "imdb",
                '_type': es_index_name,
                '_id': sha1(name+title+year).hexdigest(),
                '_source': {
                    'name': name.decode('latin1'),
                    'role': role.decode('latin1'),
                    'year': year,
                    'title': title.decode('latin1')
                }
            }
            items.append(newitem)

        if ( actor_count > 1000 ):
            print datetime.datetime.now().strftime("%Y-%m-%d %H:%M") + ": indexing " + es_index_name
            helpers.bulk(es, items)
            items = []
            actor_count  = 0

if __name__ == '__main__':
    for listname in LIST:
        with open('./data/%s.list' % listname.lower()) as f:
            buffer = f.read()
        main(buffer, listname)