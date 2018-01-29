# -*- coding: utf-8 -*-
"""
Spyder Editor

This is a temporary script file.
"""

from datetime import datetime
import elasticsearch
import json

data = {
    "account_number": 0,
    "balance": 16623,
    "firstname": "Bradshaw",
    "lastname": "Mckenzie",
    "age": 29,
    "gender": "F",
    "address": "244 Columbus Place",
    "employer": "Euron",
    "email": "bradshawmckenzie@euron.com",
    "city": "Hobucken",
    "state": "CO"
}

data


es_client = elasticsearch.Elasticsearch("localhost:9200")
doc = es_client.get(index='bank',doc_type='account',id='100')
doc
type(doc)
doc['_source']['email']

print(json.dumps(doc,indent=2))
print(json.dumps(es_client.get(index = 'bank', doc_type = 'account', id = '100', _source_include = ["firstname","lastname","email"]), indent = 2))
docs = es_client.mget(index='bank', doc_type='account', body = {'ids': ['100', '101']})
type(docs)

for doc in docs['docs']:
    print(doc['_source']['firstname'])
    
        
docs = es_client.search(index = 'bank',
                       doc_type = 'account',
                       body = {
                           'query': {
                               'match': {
                                   'state': 'NY'
                               }
                           }
                       })
    
    
print(json.dumps(docs,indent=2))


