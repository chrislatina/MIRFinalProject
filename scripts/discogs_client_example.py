#!/usr/bin/env python
#
# This illustrates the call-flow required to complete an OAuth request
# against the discogs.com API, using the discogs_client libary.
# The script will download and save a single image and perform and
# an API search API as an example. See README.md for further documentation.

import sys
import discogs_client
from discogs_client.exceptions import HTTPError
import untangle, csv, time


# Define a function for geting json data from url (public discogs api)
def get_jsonparsed_data(url):
    """Receive the content of ``url``, parse it as JSON and return the
       object.
    """
    opener = urllib2.build_opener()

    headers = {
      'User-Agent': 'Mozilla/5.0 (Windows NT 5.1; rv:10.0.1) Gecko/20100101 Firefox/10.0.1',
    }

    opener.addheaders = headers.items()
    response = opener.open(url)

    #response = urlopen(url)
    data = str(response.read())
    return json.loads(data)


def getDatasetMetaData():
    counter = 0
    with open('MIRDataset.txt', 'rU') as f:
        reader = csv.reader(f, dialect=csv.excel_tab)
        for track in reader:
            songTitle = track[0]
            artist = track[1]
            album = track[2]
            filename = track[3]

            # Search discogs
            search_results = discogsclient.search(songTitle, type='master', artist=artist, release_title=album)
            try:
                search_results
                time.sleep(1)
                if(search_results.count > 0):
                    masterID = search_results[0].id

                    master_release = discogsclient.master(masterID)

                    with open('test.csv', 'a') as fp:
                        a = csv.writer(fp, delimiter=',')
                        # Write  Artist, Album, Year, Genre, Styles
                        data = [[artist, master_release.title, songTitle, master_release.data['year'], master_release.genres[0], filename, master_release.styles]]
                        a.writerows(data)
                else:
                    print "COUNT ZERO: " + songTitle
            except:
                print "NO RESULTS: " + songTitle


def getGTZANMetaData():
    counter = 0
    with open('GTZANindex_Formated.txt', 'rU') as f:
        reader = csv.reader(f, dialect=csv.excel_tab)
        for track in reader:
            filename = track[0]
            artist = track[1]
            songTitle = track[2]

            # Search discogs
            try:
                search_results = discogsclient.search(songTitle, type='master', artist=artist)

                search_results
                time.sleep(1)
                if(search_results.count > 0):
                    masterID = search_results[0].id

                    master_release = discogsclient.master(masterID)

                    with open('GTZAN.csv', 'a') as fp:
                        a = csv.writer(fp, delimiter=',')
                        # Write  Artist, Album, Year, Genre, Styles
                        data = [[artist, master_release.title, songTitle, master_release.data['year'], master_release.genres[0], filename, master_release.styles]]
                        a.writerows(data)
                else:
                    print "COUNT ZERO: " + songTitle
            except:
                print "NO RESULTS: " + songTitle


#ie genre = alternative
def getDiscogsMetaData(genre):
    obj = untangle.parse('../Dataset/'+genre+'.xml')
    for band in obj.bands.band:
        artist = band['name']

        for songs in band.songs:
            for song in songs.song:
                songTitle = song['name']
                print(songTitle)
                benchmarkGenre = song['genre']
                songPath = song['path']

                # Search discogs
                search_results = discogsclient.search(songTitle, type='master', artist=artist)
                try:
                    search_results
                    search_results.count
                except:
                    print "NO RESULTS"
                    time.sleep(5)

                if(search_results.count > 0):
                    masterID = search_results[0].id

                    master_release = discogsclient.master(masterID)

                    with open('test.csv', 'a') as fp:
                        a = csv.writer(fp, delimiter=',')
                        # Write  Artist, Album, Year, Genre, Styles
                        data = [[artist, master_release.title, songTitle, songPath, master_release.data['year'], master_release.genres[0], master_release.styles, benchmarkGenre]]
                        a.writerows(data)

                    # #Query Masters database:
                    # url = 'http://api.discogs.com/masters/'+str(masterID)
                    # jsonData = get_jsonparsed_data(url)
                    #
                    # data = json.load(jsonData)
                    # print(jsonString)


# Your consumer key and consumer secret generated and provided by Discogs.
# See http://www.discogs.com/settings/developers . These credentials
# are assigned by application and remain static for the lifetime of your discogs
# application. the consumer details below were generated for the
# 'discogs-oauth-example' application.
# NOTE: these keys are typically kept SECRET. I have requested these for
# demonstration purposes.

consumer_key = 'UXYXktfkTUhoSEcayMZU'
consumer_secret = 'bxfTjkfIwFlPZjKYZQkbpmkSXTiEEFLA'

# A user-agent is required with Discogs API requests. Be sure to make your
# user-agent unique, or you may get a bad response.
user_agent = 'discogs_api_example/2.0'

# instantiate our discogs_client object.
discogsclient = discogs_client.Client(user_agent)

# prepare the client with our API consumer data.
discogsclient.set_consumer_key(consumer_key, consumer_secret)
token, secret, url = discogsclient.get_authorize_url()

print ' == Request Token == '
print '    * oauth_token        = {0}'.format(token)
print '    * oauth_token_secret = {0}'.format(secret)
print

# Prompt your user to "accept" the terms of your application. The application
# will act on behalf of their discogs.com account.
# If the user accepts, discogs displays a key to the user that is used for
# verification. The key is required in the 2nd phase of authentication.
print 'Please browse to the following URL {0}'.format(url)

accepted = 'n'
while accepted.lower() == 'n':
    print
    accepted = raw_input('Have you authorized me at {0} [y/n] :'.format(url))


# Waiting for user input. Here they must enter the verifier key that was
# provided at the unqiue URL generated above.
oauth_verifier = raw_input('Verification code :').decode('utf8')

try:
    access_token, access_secret = discogsclient.get_access_token(oauth_verifier)
except HTTPError:
    print 'Unable to authenticate.'
    sys.exit(1)

# fetch the identity object for the current logged in user.
user = discogsclient.identity()

print
print ' == User =='
print '    * username           = {0}'.format(user.username)
print '    * name               = {0}'.format(user.name)
print ' == Access Token =='
print '    * oauth_token        = {0}'.format(access_token)
print '    * oauth_token_secret = {0}'.format(access_secret)
print ' Authentication complete. Future requests will be signed with the above tokens.'

# With an active auth token, we're able to reuse the client object and request
# additional discogs authenticated endpoints, such as database search.
# search_results = discogsclient.search('Section 2', type='master',
#         artist='Kunek')

getGTZANMetaData();
#getDatasetMetaData()
#getDiscogsMetaData('blues')

#search_results[0].id
#http://api.discogs.com/masters/336039