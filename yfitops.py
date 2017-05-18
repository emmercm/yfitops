#!/usr/bin/env python2

import base64
import cherrypy
import random
import requests
import spotipy
import spotipy.oauth2
import string
import sys
import time
import webbrowser
import xml.etree.ElementTree as et

SCRIPT_NAME = 'yfitops'

CLIENT_ID = '53cba83ffc2e48d39f43ec187cb10482'
CLIENT_SECRET = '0e291e61e2e74f17a902e9f822e0c532'
CLIENT_REDIR = 'http://127.0.0.1:8080/callback'
CLIENT_SCOPE = 'playlist-read-private user-library-read user-read-private'

SPOTIFY_TOKEN_INFO = None


# Disable STDERR because of spotipy warnings
class NullStream(object):
    def write(self, s):
        pass


sys.stderr = NullStream()


def log(s):
    # Insert timestamp before first non-special ASCII character
    s = str(s)
    for i, c in enumerate(s):
        if ord(c) >= 32:
            s = s[:i] + '[' + time.strftime('%H:%M:%S') + '] ' + s[i:]
            break
    sys.stdout.write(s)


# Emulate spotipy.util.prompt_for_user_token() but use Spotify_Login() for authentication
def spotify_oauth():
    # Start spotipy.oauth2 and get cached tokens
    oauth = spotipy.oauth2.SpotifyOAuth(CLIENT_ID, CLIENT_SECRET, CLIENT_REDIR, scope=CLIENT_SCOPE,
                                        cache_path='.spotipy-cache')
    token_info = oauth.get_cached_token()
    if not token_info:
        # Tokens not cached, login and cache them
        spotify_login()
        token_info = SPOTIFY_TOKEN_INFO
        token_info = oauth._add_custom_values_to_token_info(token_info)
        oauth._save_token_info(token_info)
    return token_info['access_token']


# Handle Spotify's OAuth 2 authentication
def spotify_login():
    # Build Spotify authorize URL and print / open in browser
    authorize_state = ''.join(random.choice(string.ascii_letters + string.digits) for _ in range(16))
    authorize_params = {'client_id': CLIENT_ID, 'response_type': 'code', 'redirect_uri': CLIENT_REDIR,
                        'state': authorize_state, 'scope': CLIENT_SCOPE}
    authorize = requests.get('https://accounts.spotify.com/authorize', params=authorize_params)
    log("\nTo accept application authorization, please navigate here:\n\n" + authorize.url + "\n")
    webbrowser.open(authorize.url)

    # Receive Spotify callbacks
    class TokenHandler(object):
        @cherrypy.expose
        @cherrypy.tools.allow(methods=['GET'])
        def callback(self, **kwargs):
            global SPOTIFY_TOKEN_INFO
            # Receive /authorize callback, send /token request
            if 'code' in cherrypy.request.params:
                if cherrypy.request.params['state'] == authorize_state:
                    token_headers = {'Authorization': 'Basic ' + base64.b64encode(CLIENT_ID + ':' + CLIENT_SECRET)}
                    token_params = {'grant_type': 'authorization_code', 'code': cherrypy.request.params['code'],
                                    'redirect_uri': CLIENT_REDIR}
                    token = requests.post('https://accounts.spotify.com/api/token', headers=token_headers,
                                          data=token_params)
                    # Receive /token response
                    token_response = token.json()
                    if 'access_token' in token_response and 'refresh_token' in token_response:
                        SPOTIFY_TOKEN_INFO = token_response
                        log("\nAuthentication succeeded\n")
                        yield '<h1 style="font-family:Arial; color:green; text-align:center; margin-top:100px;">' +\
                              SCRIPT_NAME + ' authentication succeeded</h1>'
                    else:
                        log("\nAuthentication failed\n")
                        yield '<h1 style="font-family:Arial; color:red; text-align:center; margin-top:100px;">' +\
                              SCRIPT_NAME + ' authentication failed</h1>'
                    cherrypy.engine.exit()

    cherrypy.config.update({'server.socket_port': 8080, 'environment': 'embedded'})
    cherrypy.quickstart(TokenHandler())


def spotify_pager(pager, xml_root, xml_name, expand=False):
    while True:
        # If the current pager does not have the key 'items' try to look for it in sub-items
        if type(pager) is dict and 'items' not in pager:
            for key in pager.keys():
                if type(pager[key]) is dict and 'items' in pager[key]:
                    pager = pager[key]
                    break
        # Process current items in pager
        log("Processing " + str(pager['offset'] + 1) + "-" + str(pager['offset'] + len(pager['items'])) + " / " + str(
            pager['total']) + " " + xml_name + "s...\n")
        for item in pager['items']:
            if expand:
                if item['type'] == 'album':
                    item = spotify.album(item['id'])
                if item['type'] == 'playlist':
                    item = spotify.user_playlist(item['owner']['id'], item['id'])
            xml_elem = et.SubElement(xml_root, xml_name)
            var_to_xml(xml_elem, item)
        # Get next set of items from pager
        if pager['next']:
            pager = spotify.next(pager)
        else:
            break


def var_to_xml(root, item, name=None):
    if name is None:
        name = root.tag
    if type(item) is dict:
        for key in item.keys():
            if type(item[key]) is dict or type(item[key]) is list:
                child = et.SubElement(root, key)
                var_to_xml(child, item[key], key)
            else:
                var_to_xml(root, item[key], key)
    elif type(item) is list:
        if name[-1:] == 's':
            name = name[:-1]
        for it in item:
            child = et.SubElement(root, name)
            var_to_xml(child, it, name)
    else:
        if root.tag == name:
            root.text = unicode(item)
        else:
            root.attrib[name] = unicode(item)


# http://effbot.org/zone/element-lib.htm#prettyprint
def elementtree_indent(elem, level=0):
    i = '\n' + level * '\t'
    if len(elem):
        if not elem.text or not elem.text.strip():
            elem.text = i + '\t'
        if not elem.tail or not elem.tail.strip():
            elem.tail = i
        for elem in elem:
            elementtree_indent(elem, level + 1)
        if not elem.tail or not elem.tail.strip():
            elem.tail = i
    else:
        if level and (not elem.tail or not elem.tail.strip()):
            elem.tail = i


# Create XML root
xml_root = et.Element(SCRIPT_NAME)
xml_root.attrib['generated'] = time.strftime('%x %X')

# Login to Spotify
spotify_token = spotify_oauth()
# Start Spotify, set authentication
spotify = spotipy.Spotify(auth=spotify_token)
# Get authenticated user information
current_user = spotify.current_user()
current_user_id = current_user['id']
current_user_country = current_user['country']
log("\nLogged in as: " + current_user_id + "\n\n")

# Fetch user information
log("Fetching user profile...\n")
xml_current_user = et.SubElement(xml_root, 'current_user')
var_to_xml(xml_current_user, current_user)
print ""

# Fetch spotify featured
xml_featured = et.SubElement(xml_root, 'featured')

log("Fetching featured playlists...\n")
featured_playlists = spotify.featured_playlists(country=current_user_country)
xml_featured_playlists = et.SubElement(xml_featured, 'playlists')
spotify_pager(featured_playlists, xml_featured_playlists, 'playlist')
print ""

# Fetch new releases
xml_new_releases = et.SubElement(xml_root, 'new_releases')

log("Fetching new album releases...\n")
new_releases_albums = spotify.new_releases(country=current_user_country)
xml_new_releases_albums = et.SubElement(xml_new_releases, 'albums')
spotify_pager(new_releases_albums, xml_new_releases_albums, 'album', True)
print ""

# Fetch user saved items
xml_user_saved = et.SubElement(xml_root, 'user_saved')

log("Fetching saved tracks...\n")
saved_tracks = spotify.current_user_saved_tracks()
xml_user_saved_tracks = et.SubElement(xml_user_saved, 'tracks')
xml_user_saved_tracks_items = et.SubElement(xml_user_saved_tracks, 'items')
spotify_pager(saved_tracks, xml_user_saved_tracks_items, 'item')
print ""

# Fetch user playlists
log("Fetching user playlists...\n")
playlists = spotify.user_playlists(current_user_id)
xml_playlists = et.SubElement(xml_root, 'user_playlists')
spotify_pager(playlists, xml_playlists, 'playlist', True)
print ""

# Fetch owner profiles
log("Fetching playlist owner profiles...\n")
owners = []
for owner in xml_root.findall('.//owner[@id]'):
    if owner.attrib['id'] != current_user_id:
        owners.append(owner.attrib['id'])
owners = sorted(set(owners))
if len(owners) > 0:
    xml_users = et.SubElement(xml_root, 'users')
    for i, owner in enumerate(owners):
        log("Processing " + str(i) + " / " + str(len(owners)) + " users...\n")
        user = spotify.user(owner)
        xml_user = et.SubElement(xml_users, 'user')
        var_to_xml(xml_user, user)
print ""

# Write XML output
xml_filename = SCRIPT_NAME + '-' + time.strftime('%Y%m%d-%H%M%S') + '.xml'
log("Writing XML to " + xml_filename + "...\n")
with open(xml_filename, 'w') as xml_file:
    xml_file.write('<?xml version="1.0" encoding="utf-8"?>\n')
    xml_file.write('<?xml-stylesheet type="text/xsl" href="' + SCRIPT_NAME + '.xsl"?>\n')
    elementtree_indent(xml_root)
    et.ElementTree(xml_root).write(xml_file, xml_declaration=False, encoding='utf-8', method='xml')
print ""
