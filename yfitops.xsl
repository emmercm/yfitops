<?xml version="1.0" encoding="ISO-8859-1"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
	<xsl:template match="/yfitops">
		<html>
			<head>
				<title>
					<xsl:value-of select="local-name()" />
					- <xsl:value-of select="current_user/@display_name" />
					- <xsl:value-of select="@generated" />
				</title>
				
				<link href='http://fonts.googleapis.com/css?family=Montserrat' rel="stylesheet" type="text/css" />
				
				<link href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.5/css/bootstrap.min.css" rel="stylesheet" />
				
				<link href="https://cdn.datatables.net/plug-ins/1.10.7/integration/bootstrap/3/dataTables.bootstrap.css" rel="stylesheet" />
				
				<link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/font-awesome/4.4.0/css/font-awesome.min.css" />
				
				<style type="text/css">
					/* Bootstrap changes */
					.row-no-margin {
						margin-left: 0;
						margin-right: 0;
					}
					.col-no-padding {
						padding-left: 0;
						padding-right: 0;
					}
					table.dataTable thead .sorting_asc::after,
					table.dataTable thead .sorting_desc::after {
						opacity: 1;
						color: #00DA6A;
					}
					
					
					/* Global */
					body {
						font-family: 'Montserrat', sans-serif;
					}
					
					
					/* #nav */
					#nav {
						background-color: #282828;
					}
					#nav[data-spy='affix'] {
						width: 25%;  /* col-xs-3 */
						top: 0;
						right: 0;
						bottom: 0;
						left: 0;
						overflow-y: scroll;
					}
					#nav a {
						color: #ADAFB2;
					}
					
					#nav li > a {
						padding: 5px 10px;
						overflow-x: hidden;
						white-space: nowrap;
						text-overflow: ellipsis;
					}
					#nav li > a:hover {
						background-color: #282828;
					}
					
					#nav > li:not(:last-child) {
						margin-bottom: 25px;
					}
					
					#nav > li > a {
						text-transform: uppercase;
					}
					#nav > li > ul > li .glyphicon {
						margin-right: 15px;
						color: #ADAFB2;
					}
					#nav > li > ul > li > a {
						padding-left: 20px;
					}
					#nav > li > ul > li.active .glyphicon {
						color: #FFFFFF;
					}
					#nav > li > ul > li.active > a {
						padding-left: 17px;
						color: #FFFFFF;
						border-left: 3px solid #00DA6A;
					}
					
					
					/* #content */
					body {
						background-color: #181818;
					}
					#content {
						padding: 20px;
						background-color: #181818;
						color: #DFE0E5;
						overflow: hidden;
					}
					#content section {
						display: none;
					}
					#content a {
						color: #FFFFFF;
					}
					#content img.lazy {
						width: 100%;
					}
					
					#content .row:not(:first-child) {
						margin-top: 10px;
					}
					#content .row:not(:last-child) {
						margin-bottom: 10px;
					}
					
					#content #current_user .playlist-header img,
					#content #users .playlist-header img {
						-webkit-border-radius: 999px;
						   -moz-border-radius: 999px;
						        border-radius: 999px;
					}
					#content .playlist-header h4 {
						margin-top: 0;
						font-size: 14px;
						color: #88898C;
						text-transform: uppercase;
					}
					#content .playlist-header h2 {
						margin-top: 5px;
						font-weight: normal;
						font-size: 40px;
					}
					#content .playlist-header h5 {
						font-size: 12px;
					}
					
					#content .playlist-subheader {
						padding: 7px 0;
						color: #88898C;
						border-top: 1px solid #282828;
						border-bottom: 1px solid #282828;
					}
					
					#content .table > thead > tr > th {
						font-size: 12px;
						color: #949599;
						text-transform: uppercase;
						border-width: 0;
					}
					#content .table > thead > tr > th:not(:first-child) {
						border-left:  1px solid #282828;
					}
					#content .table > tbody > tr > td {
						color: #949599;
						border-color: #282828;
					}
					#content .table > tbody > tr > td.unavailable,
					#content .table > tbody > tr > td.unavailable * {
						color: #35373B;
					}
					#content .table > thead > tr > th.nowrap,
					#content .table > tbody > tr > td.nowrap {
						white-space: nowrap;
					}
					#content .table .glyphicon-warning-sign {
						float: right;
						color: #777777;
					}
					
					#content .playlist-playlists {
						color: #88898C;
					}
					#content .playlist-playlists h1 {
						padding-bottom: 10px;
						font-size: 14px;
						text-transform: uppercase;
						border-bottom: 1px solid #282828;
					}
					#content .playlist-playlists h5:not(:first-child) a {
						color: #88898C;
					}
					#content .playlist-playlists ul.list-inline > li {
						width: 25%;
						margin-bottom: 25px;
						vertical-align: top;
					}
					#content .playlist-playlists ul.list-inline > li > div {
						margin: 0;
					}
					#content .playlist-playlists ul.list-inline > li > div:last-child {
						padding: 0 10px;
						background-color: #282828;
					}
					#content .playlist-playlists ul.list-inline > li > div > * {
						overflow: hidden;
						text-overflow: ellipsis;
					}
				</style>
			</head>
			<body>
				<div class="row row-no-margin">
					<div class="col-xs-3 col-no-padding">
						<ul id="nav" class="nav" data-spy="affix">
							<!-- MAIN -->
							<xsl:if test="current_user | featured[child::*] | new_releases[child::*]">
								<li>
									<a href="#main">Main</a>
									<ul class="nav">
										<!-- Profile -->
										<xsl:if test="current_user">
											<li>
												<a href="#current_user"><span class="glyphicon glyphicon-user" />Profile</a>
											</li>
										</xsl:if>
										
										<!-- Browse -->
										<xsl:if test="featured[child::*] | new_releases[child::*]">
											<li>
												<a href="#browse"><span class="glyphicon glyphicon-folder-open" />Browse</a>
											</li>
										</xsl:if>
									</ul>
								</li>
							</xsl:if>
							
							<!-- YOUR MUSIC -->
							<xsl:if test="user_saved[child::*]">
								<li>
									<a href="#user_saved">Your Music</a>
									<ul class="nav">
										<xsl:if test="user_saved/tracks">
											<li>
												<a href="#user_saved_tracks"><span class="glyphicon glyphicon-music" />Songs</a>
											</li>
											<li>
												<a href="#user_saved_albums"><span class="glyphicon glyphicon-cd" />Albums</a>
											</li>
										</xsl:if>
									</ul>
								</li>
							</xsl:if>
							
							<!-- PLAYLISTS -->
							<xsl:if test="user_playlists/playlist">
								<li>
									<a href="#user_playlists">Playlists</a>
									<ul class="nav">
										<xsl:for-each select="user_playlists/playlist">
											<li>
												<a>
													<xsl:attribute name="href">#<xsl:value-of select="@uri" /></xsl:attribute>
													<span class="glyphicon glyphicon-music" />
													<xsl:value-of select="@name" />
													<xsl:if test="owner/@id != /*/current_user/@id"> by <xsl:apply-templates select="owner" /></xsl:if>
												</a>
											</li>
										</xsl:for-each>
									</ul>
								</li>
							</xsl:if>
							
							<!-- (USERS) -->
							<xsl:if test="users/user">
								<li style="display:none;">
									<a href="#users">Users</a>
									<ul class="nav">
										<xsl:for-each select="users/user">
											<li>
												<a>
													<xsl:attribute name="href">#<xsl:value-of select="@uri" /></xsl:attribute>
													<span class="glyphicon glyphicon-user" />
													<xsl:value-of select="@display_name" />
												</a>
											</li>
										</xsl:for-each>
									</ul>
								</li>
							</xsl:if>
						</ul>
					</div>
					
					<div id="content" class="col-xs-9 col-no-padding">
						<!-- MAIN -->
						<xsl:if test="current_user">
							<section id="main">
								<!-- Profile -->
								<section id="current_user">
									<xsl:apply-templates select="current_user" />
								</section>
								
								<!-- Browse -->
								<section id="browse">
									<xsl:if test="featured/playlists">
										<div class="row playlist-playlists">
											<div class="col-xs-12">
												<h1>Featured Playlists</h1>
												<ul class="list-inline">
													<xsl:apply-templates select="featured/playlists/playlist" />
												</ul>
											</div>
										</div>
									</xsl:if>
									<xsl:if test="new_releases/albums">
										<div class="row playlist-playlists">
											<div class="col-xs-12">
												<h1>New Releases</h1>
												<ul class="list-inline">
													<xsl:apply-templates select="new_releases/albums/album" />
												</ul>
											</div>
										</div>
									</xsl:if>
								</section>
							</section>
						</xsl:if>
						
						<!-- YOUR MUSIC -->
						<xsl:if test="user_saved[child::*]">
							<section id="user_saved">
								<!-- Songs -->
								<xsl:if test="user_saved/tracks">
									<section id="user_saved_tracks">
										<div class="row">
											<div class="col-xs-12">
												<xsl:apply-templates select="user_saved/tracks/items" />
											</div>
										</div>
									</section>
									<section id="user_saved_albums">
										<div class="row playlist-playlists">
											<div class="col-xs-12">
												<ul class="list-inline">
													<xsl:for-each select="user_saved/tracks/items/item/track/album[not(preceding::album/@id = @id)]">
														<xsl:apply-templates select="." />
													</xsl:for-each>
												</ul>
											</div>
										</div>
									</section>
								</xsl:if>
							</section>
						</xsl:if>
						
						<!-- PLAYLISTS -->
						<xsl:if test="user_playlists/playlist">
							<section id="user_playlists">
								<xsl:for-each select="user_playlists/playlist">
									<section>
										<xsl:attribute name="id"><xsl:value-of select="@uri" /></xsl:attribute>
										<div class="row playlist-header">
											<div class="col-xs-2">
												<xsl:apply-templates select="images" />
											</div>
											<div class="col-xs-10">
												<h4>
													<xsl:if test="@collaborative = 'True'">Collaborative</xsl:if>
													Playlist
												</h4>
												<h2>
													<a>
														<xsl:attribute name="href"><xsl:value-of select="external_urls/@spotify" /></xsl:attribute>
														<xsl:value-of select="@name" />
													</a>
												</h2>
												<xsl:if test="@description != 'None'">
													<h5><xsl:value-of select="@description" disable-output-escaping="yes" /></h5>
												</xsl:if>
											</div>
										</div>
										<div class="row playlist-subheader">
											<div class="col-xs-12">
												Created by:
												<a>
													<xsl:attribute name="href"><xsl:apply-templates select="owner/external_urls" /></xsl:attribute>
													<xsl:apply-templates select="owner" />
												</a>
												&#8226; <xsl:value-of select="tracks/@total" /> songs,
												<xsl:if test="sum(tracks/items/item/track/@duration_ms) >= 3600000"><xsl:value-of select="floor(sum(tracks/items/item/track/@duration_ms) div 3600000)" /> hr </xsl:if>
												<xsl:value-of select="floor((sum(tracks/items/item/track/@duration_ms) mod 3600000) div 60000)" /> min
												&#8226; <xsl:value-of select="followers/@total" /> follower<xsl:if test="followers/@total != 1">s</xsl:if>
											</div>
										</div>
										<div class="row">
											<div class="col-xs-12">
												<xsl:apply-templates select="tracks/items" />
											</div>
										</div>
									</section>
								</xsl:for-each>
							</section>
						</xsl:if>
						
						<!-- (USERS) -->
						<xsl:if test="users/user">
							<section id="users">
								<xsl:for-each select="users/user">
									<section>
										<xsl:attribute name="id"><xsl:value-of select="@uri" /></xsl:attribute>
										<xsl:apply-templates select="." />
									</section>
								</xsl:for-each>
							</section>
						</xsl:if>
					</div>
				</div>
				
				<script src="https://code.jquery.com/jquery-1.11.3.min.js"></script>
				
				<script src="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.5/js/bootstrap.min.js"></script>
				
				<script src="https://cdnjs.cloudflare.com/ajax/libs/jquery_lazyload/1.9.5/jquery.lazyload.min.js"></script>
				
				<script src="https://cdn.datatables.net/1.10.7/js/jquery.dataTables.min.js"></script>
				<script src="https://cdn.datatables.net/plug-ins/1.10.7/integration/bootstrap/3/dataTables.bootstrap.min.js"></script>
				
				<script><![CDATA[
					$(document).ready(function() {
						var $nav = $('#nav');
						
						// DataTables.js
						$('#content table').dataTable({
							paging: false,
							aaSorting: [],
							bFilter: false,
							bInfo: false
						});
						
						// History backwards/forwards (includes hash changes)
						window.onpopstate = function(event) {
							var $a = $nav.find("a[href='"+window.location.hash+"']");
							// Ensure navigation item exists and is second-level
							if(!$a.length) {
								$a = $("#nav a").first();
							}
							if($a.parents('ul').length < 2) {
								$a = $a.closest('li').find('ul a').first();
							}
							if(window.location.hash != $a.attr('href').substring(1)) {
								history.replaceState({}, "", $a.attr('href'));
							}
							// #nav .active toggling
							$nav.find('li.active').removeClass('active');
							$a.parents('li').addClass('active');
							// #nav scrolling
							var $nav_li = $a.closest('li');
							if(!$nav_li.length) {
								$nav_li = $nav.children('li').first();
							}
							if(($nav_li.position().top + $nav_li.height() > $nav.scrollTop() + $nav.height()) || ($nav_li.position().top < $nav.scrollTop)) {
								$nav.scrollTop( $nav_li.position().top );
							}
							
							// #content display toggling
							var $section = $("section[id='"+window.location.hash.substring(1)+"']");
							$('#content').find('section:visible').hide();
							$section.show();
							$section.parents(':not(:visible)').show();
							// jquery_lazyload
							$section.find('img.lazy').not("[src^='http']").show().lazyload({effect:"fadeIn"});
							// DataTables.js re-layout
							onResize();
						}
						// Fake a history event on page load
						if(window.location.hash == '') {
							history.replaceState({}, "", $("#nav > li > ul > li > a").first().attr('href'));
						}
						window.onpopstate();
						
						var resizeTimeout;
						$(window).resize(function() {
							resizeTimeout = setTimeout(onResize, 250);
						});
					});
					
					function onResize() {
						// DataTables.js re-layout
						$dataTable = $('#content section:visible section:visible table.dataTable');
						$dataTable.css('width','');
						$dataTable.DataTable().columns.adjust().draw();
					}
				]]></script>
			</body>
		</html>
	</xsl:template>
	
	<xsl:template match="items[child::item]">
		<table class="table">
			<thead>
				<tr>
					<th>Song</th>
					<th>Artist</th>
					<th>Album</th>
					<th class="nowrap"><i class="fa fa-calendar-o" /></th>
					<th class="nowrap text-right"><i class="fa fa-clock-o" /></th>
					<th class="nowrap">
						<xsl:if test="not(item/added_by[@id])"><xsl:attribute name="style">display:none;</xsl:attribute></xsl:if>
						User
					</th>
				</tr>
			</thead>
			<tbody>
				<xsl:for-each select="item">
					<tr>
						<td>
							<xsl:attribute name="class">
								<xsl:if test="/*/current_user/@country and track/available_markets/available_market and not(track/available_markets/available_market/text() = /*/current_user/@country)">unavailable</xsl:if>
							</xsl:attribute>
							<a>
								<xsl:attribute name="href"><xsl:value-of select="track/external_urls/@spotify" /></xsl:attribute>
								<xsl:value-of select="track/@name" />
							</a>
							<xsl:if test="track/@explicit = 'True'">
								<span class="glyphicon glyphicon-warning-sign" title="EXPLICIT" />
							</xsl:if>
						</td>
						<td>
							<xsl:apply-templates select="track/artists" />
						</td>
						<td>
							<xsl:attribute name="class">
								<xsl:if test="/*/current_user/@country and track/album/available_markets/available_market and not(track/album/available_markets/available_market/text() = /*/current_user/@country)">unavailable</xsl:if>
							</xsl:attribute>
							<a>
								<xsl:attribute name="href"><xsl:value-of select="track/album/external_urls/@spotify" /></xsl:attribute>
								<xsl:value-of select="track/album/@name" />
							</a>
						</td>
						<td class="nowrap">
							<xsl:value-of select="substring(@added_at,1,10)" />
						</td>
						<td class="nowrap text-right">
							<xsl:value-of select="floor(round(track/@duration_ms div 1000) div 60)" />:<xsl:value-of select="concat(substring('0',1,2-string-length(round(track/@duration_ms div 1000) mod 60)), round(track/@duration_ms div 1000) mod 60)" />
						</td>
						<td class="nowrap">
							<xsl:if test="not(added_by[@id])"><xsl:attribute name="style">display:none;</xsl:attribute></xsl:if>
							<a>
								<xsl:attribute name="href"><xsl:apply-templates select="added_by/external_urls" /></xsl:attribute>
								<xsl:apply-templates select="added_by" />
							</a>
						</td>
					</tr>
				</xsl:for-each>
			</tbody>
		</table>
	</xsl:template>
	
	<xsl:template match="playlist | album">
		<li>
			<div class="row">
				<a>
					<xsl:attribute name="href">
						<xsl:variable name="item_id" select="@id" />
						<xsl:if test="count(/*/user_playlists/playlist[@id = $item_id]) > 0">#<xsl:value-of select="@uri" /></xsl:if>
						<xsl:if test="count(/*/user_playlists/playlist[@id = $item_id]) = 0"><xsl:value-of select="external_urls/@spotify" /></xsl:if>
					</xsl:attribute>
					<xsl:apply-templates select="images" />
				</a>
			</div>
			<div class="row">
				<h5>
					<a>
						<xsl:attribute name="href">
							<xsl:variable name="item_id" select="@id" />
							<xsl:if test="count(/*/user_playlists/playlist[@id = $item_id]) > 0">#<xsl:value-of select="@uri" /></xsl:if>
							<xsl:if test="count(/*/user_playlists/playlist[@id = $item_id]) = 0"><xsl:value-of select="external_urls/@spotify" /></xsl:if>
						</xsl:attribute>
						<xsl:value-of select="@name" />
					</a>
				</h5>
				<xsl:if test="followers">
					<h5>
						<xsl:value-of select="followers/@total" /> follower<xsl:if test="followers/@total != 1">s</xsl:if>
					</h5>
				</xsl:if>
				<xsl:if test="artists">
					<h5>
						<xsl:apply-templates select="artists" />
					</h5>
				</xsl:if>
				<xsl:if test="not(artists) and parent::track/artists">
					<h5>
						<xsl:apply-templates select="parent::track/artists" />
					</h5>
				</xsl:if>
				<xsl:if test="owner[@id != /*/current_user/@id]">
					<h5>
						<a>
							<xsl:attribute name="href"><xsl:apply-templates select="owner/external_urls" /></xsl:attribute>
							<xsl:apply-templates select="owner" />
						</a>
					</h5>
				</xsl:if>
			</div>
		</li>
	</xsl:template>
	
	<xsl:template match="artists[child::artist]">
		<xsl:for-each select="artist">
			<xsl:if test="position() > 1">, </xsl:if>
			<a>
				<xsl:attribute name="href"><xsl:value-of select="external_urls/@spotify" /></xsl:attribute>
				<xsl:value-of select="@name" />
			</a>
		</xsl:for-each>
	</xsl:template>
	
	<xsl:template match="user | current_user">
		<div class="row playlist-header">
			<div class="col-xs-2">
				<xsl:apply-templates select="images" />
			</div>
			<div class="col-xs-10">
				<h4>User</h4>
				<h2>
					<a>
						<xsl:attribute name="href"><xsl:value-of select="external_urls/@spotify" /></xsl:attribute>
						<xsl:choose>
							<xsl:when test="@display_name != 'None'">
								<xsl:value-of select="@display_name" />
							</xsl:when>
							<xsl:otherwise>
								<xsl:value-of select="@id" />
							</xsl:otherwise>
						</xsl:choose>
					</a>
				</h2>
			</div>
		</div>
		<div class="row playlist-subheader">
			<div class="col-xs-12">
				ID:
				<a>
					<xsl:attribute name="href"><xsl:value-of select="external_urls/@spotify" /></xsl:attribute>
					<xsl:value-of select="@id" />
				</a>
				&#8226; <xsl:value-of select="followers/@total" /> followers
			</div>
		</div>
		<div class="row playlist-playlists">
			<div class="col-xs-12">
				<h1>Public Playlists</h1>
				<ul class="list-inline">
					<xsl:variable name="owner_id" select="@id" />
					<xsl:choose>
						<xsl:when test="@id = /*/current_user/@id">
							<xsl:apply-templates select="/*/user_playlists/playlist[@public='True']/owner[@id = $owner_id]/.." />
						</xsl:when>
						<xsl:otherwise>
							<xsl:apply-templates select="playlists/playlist/owner[@id = $owner_id]/.." />
						</xsl:otherwise>
					</xsl:choose>
				</ul>
			</div>
		</div>
	</xsl:template>
	
	<xsl:template match="owner | added_by">
		<xsl:variable name="owner_id" select="@id" />
		<xsl:choose>
			<xsl:when test="/*/current_user/@id = $owner_id">
				<xsl:value-of select="/*/current_user/@display_name" />
			</xsl:when>
			<xsl:when test="/*/users/user[@id = $owner_id] and /*/users/user[@id = $owner_id]/@display_name != 'None'">
				<xsl:value-of select="/*/users/user[@id = $owner_id]/@display_name" />
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="@id" />
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	<xsl:template match="external_urls[parent::owner] | external_urls[parent::added_by]">
		<xsl:variable name="owner_id" select="../@id" />
		<xsl:choose>
			<xsl:when test="/*/current_user/@id = $owner_id">#current_user</xsl:when>
			<xsl:when test="/*/users/user[@id = $owner_id]">#<xsl:value-of select="/*/users/user[@id = $owner_id]/@uri" /></xsl:when>
			<xsl:otherwise><xsl:value-of select="@spotify" /></xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<xsl:template match="images">
		<img src="data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABAQMAAAAl21bKAAAAA1BMVEUAAACnej3aAAAAAXRSTlMAQObYZgAAAApJREFUCNdjYAAAAAIAAeIhvDMAAAAASUVORK5CYII=" class="lazy">
			<xsl:attribute name="data-original"><xsl:value-of select="image/@url" /></xsl:attribute>
		</img>
	</xsl:template>
</xsl:stylesheet>