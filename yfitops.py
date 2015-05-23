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
class NullStream():
	def write(self, s):
		pass
sys.stderr = NullStream()


# Emulate spotipy.util.prompt_for_user_token() but use Spotify_Login() for authentication
def Spotify_OAuth():
	# Start spotipy.oauth2 and get cached tokens
	spotify_oauth = spotipy.oauth2.SpotifyOAuth(CLIENT_ID, CLIENT_SECRET, CLIENT_REDIR, scope=CLIENT_SCOPE, cache_path='.spotipy-cache')
	token_info = spotify_oauth.get_cached_token()
	if not token_info:
		# Tokens not cached, login and cache them
		Spotify_Login()
		token_info = SPOTIFY_TOKEN_INFO
		token_info = spotify_oauth._add_custom_values_to_token_info(token_info)
		spotify_oauth._save_token_info(token_info)
	return token_info['access_token']

# Handle Spotify's OAuth 2 authentication
def Spotify_Login():
	# Build Spotify authorize URL and print / open in browser
	authorize_state = ''.join(random.choice(string.ascii_letters + string.digits) for _ in range(16))
	authorize_params = {'client_id':CLIENT_ID, 'response_type':'code', 'redirect_uri':CLIENT_REDIR, 'state':authorize_state, 'scope':CLIENT_SCOPE}
	authorize = requests.get('https://accounts.spotify.com/authorize', params=authorize_params)
	print "\nTo accept application authorization, please navigate here:\n\n" + authorize.url
	webbrowser.open(authorize.url)
	
	# Receive Spotify callbacks
	class TokenHandler(object):
		AccessToken = None
		RefreshToken = None
		@cherrypy.expose
		def callback(self, **kwargs):
			global SPOTIFY_TOKEN_INFO
			# Receive /authorize callback, send /token request
			if 'code' in cherrypy.request.params:
				if cherrypy.request.params['state'] == authorize_state:
					token_headers = {'Authorization':'Basic '+base64.b64encode(CLIENT_ID+':'+CLIENT_SECRET)}
					token_params = {'grant_type':'authorization_code', 'code':cherrypy.request.params['code'], 'redirect_uri':CLIENT_REDIR}
					token = requests.post('https://accounts.spotify.com/api/token', headers=token_headers, data=token_params)
					# Receive /token response
					token_response = token.json()
					if 'access_token' in token_response and 'refresh_token' in token_response:
						SPOTIFY_TOKEN_INFO = token_response
						print "\nAuthentication successful"
					else:
						print "\nAuthentication failed"
					cherrypy.engine.exit()
	cherrypy.config.update({'server.socket_port':8080, 'environment':'embedded'})
	cherrypy.quickstart(TokenHandler())

def SpotifyPager(pager, xml_root, xml_name, expand=False):
	while True:
		# If the current pager does not have the key 'items' try to look for it in sub-items
		if type(pager) is dict and not 'items' in pager:
			for key in pager.keys():
				if type(pager[key]) is dict and 'items' in pager[key]:
					pager = pager[key]
					break
		# Process current items in pager
		print "Processing " + str(pager['offset']+1) + "-" + str(pager['offset']+len(pager['items'])) + " / " + str(pager['total']) + " " + xml_name + "s..."
		for item in pager['items']:
			if expand == True:
				if item['type'] == 'album':
					item = spotify.album(item['id'])
				if item['type'] == 'playlist':
					item = spotify.user_playlist(item['owner']['id'], item['id'])
			xml_elem = et.SubElement(xml_root, xml_name)
			Var2XML(xml_elem, item)
		# Get next set of items from pager
		if pager['next']:
			pager = spotify.next(pager)
		else:
			break;

def Var2XML(root, item, name=None):
	if name is None:
		name = root.tag
	if type(item) is dict:
		for key in item.keys():
			if type(item[key]) is dict or type(item[key]) is list:
				child = et.SubElement(root, key)
				Var2XML(child, item[key], key)
			else:
				Var2XML(root, item[key], key)
	elif type(item) is list:
		if name[-1:] == 's': name = name[:-1]
		for it in item:
			child = et.SubElement(root, name)
			Var2XML(child, it, name)
	else:
		if root.tag == name:
			root.text = unicode(item)
		else:
			root.attrib[name] = unicode(item)

# http://effbot.org/zone/element-lib.htm#prettyprint
def ElementTree_Indent(elem, level=0):
	i = '\n' + level*'\t'
	if len(elem):
		if not elem.text or not elem.text.strip():
			elem.text = i + '\t'
		if not elem.tail or not elem.tail.strip():
			elem.tail = i
		for elem in elem:
			ElementTree_Indent(elem, level+1)
		if not elem.tail or not elem.tail.strip():
			elem.tail = i
	else:
		if level and (not elem.tail or not elem.tail.strip()):
			elem.tail = i


# Create XML root
xml_root = et.Element(SCRIPT_NAME)
xml_root.attrib['generated'] = time.strftime('%x %X')

# Login to Spotify
spotify_token = Spotify_OAuth()
# Start Spotify, set authentication
spotify = spotipy.Spotify(auth=spotify_token)
# Get authenticated user information
current_user = spotify.current_user()
current_user_id = current_user['id']
current_user_country = current_user['country']
print "Logged in as: " + current_user_id + "\n"


# Fetch user information
print "Fetching user profile..."
xml_current_user = et.SubElement(xml_root, 'current_user')
Var2XML(xml_current_user, current_user)
print ""


# Fetch spotify featured
xml_featured = et.SubElement(xml_root, 'featured')

print "Fetching featured playlists..."
featured_playlists = spotify.featured_playlists(country=current_user_country)
xml_featured_playlists = et.SubElement(xml_featured, 'playlists')
SpotifyPager(featured_playlists, xml_featured_playlists, 'playlist')
print ""


# Fetch new releases
xml_new_releases = et.SubElement(xml_root, 'new_releases')

print "Fetching new album releases..."
new_releases_albums = spotify.new_releases(country=current_user_country)
xml_new_releases_albums = et.SubElement(xml_new_releases, 'albums')
SpotifyPager(new_releases_albums, xml_new_releases_albums, 'album', True)
print ""


# Fetch user saved items
xml_user_saved = et.SubElement(xml_root, 'user_saved')

print "Fetching saved tracks..."
saved_tracks = spotify.current_user_saved_tracks()
xml_user_saved_tracks = et.SubElement(xml_user_saved, 'tracks')
xml_user_saved_tracks_items = et.SubElement(xml_user_saved_tracks, 'items')
SpotifyPager(saved_tracks, xml_user_saved_tracks_items, 'item')
print ""


# Fetch user playlists
print "Fetching user playlists..."
playlists = spotify.user_playlists(current_user_id)
xml_playlists = et.SubElement(xml_root, 'user_playlists')
SpotifyPager(playlists, xml_playlists, 'playlist', True)
print ""


# Write XML output
xml_filename = SCRIPT_NAME + '-' + time.strftime('%Y%m%d-%H%M%S') + '.xml'
print "Writing XML to " + xml_filename + "..."
with open(xml_filename, 'w') as xml_file:
	xml_file.write('<?xml version="1.0" encoding="utf-8"?>\n')
	xml_file.write('<?xml-stylesheet type="text/xsl" href="'+SCRIPT_NAME+'.xsl"?>\n')
	ElementTree_Indent(xml_root)
	et.ElementTree(xml_root).write(xml_file, xml_declaration=False, encoding='utf-8', method='xml')
print ""