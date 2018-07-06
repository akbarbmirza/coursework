#
# file: get_article_urls.py
#
# description: fetches article urls from the NYTimes API
#
# usage: get_articles.py <api_key>
#
# requirements: a NYTimes API key
#   available at https://developer.nytimes.com/signup
#

import requests
import json
import sys
import time

ARTICLE_SEARCH_URL = 'https://api.nytimes.com/svc/search/v2/articlesearch.json'

if __name__ == '__main__':
    if len(sys.argv) != 4:
        sys.stderr.write('usage: %s <api_key> <section_name> <num_articles>' % sys.argv[0])
        sys.exit(1)
    
    api_key = sys.argv[1]
    section_name = sys.argv[2]
    num_articles = int(sys.argv[3])

    filename = section_name + ".tsv"
    with open(filename, mode='w', encoding='utf-8') as f:
        f.write("section_name\tweb_url\tpub_date\tsnippet\n")

    i = 0
    while i < num_articles / 10:
        params = {
        'api-key': api_key,
        'fq': 'section_name:%s' % section_name,
        'sort': 'newest',
        'page': i
        }

        print(params)

        r = requests.get(ARTICLE_SEARCH_URL,
            params)
        # print(r)
        data = json.loads(r.content)

        for doc in data['response']['docs']:
            web_url = doc['web_url']
            pub_date = doc['pub_date']
            snippet = doc['snippet'].replace('\n', '')
            
            # print('Writing to ' + filename)
            with open(filename, mode='a', encoding='utf-8') as f:
                f.write("%s\t%s\t%s\t%s\n" %
                    (section_name, web_url, pub_date, snippet))
        
        # increment our page iterator
        i += 1
        time.sleep(1)
        
        
        
    
