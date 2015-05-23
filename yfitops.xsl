<?xml version="1.0" encoding="ISO-8859-1"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
	<xsl:template match="/yfitops">
		<html>
			<head>
				<link href='http://fonts.googleapis.com/css?family=Montserrat' rel='stylesheet' type='text/css' />
				
				<link href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.4/css/bootstrap.min.css" rel="stylesheet" />
				<link href="https://maxcdn.bootstrapcdn.com/font-awesome/4.3.0/css/font-awesome.min.css" rel="stylesheet" />
				
				<link href="https://cdn.datatables.net/1.10.7/js/jquery.dataTables.min.js" rel="stylesheet" />
				<link href="https://cdn.datatables.net/plug-ins/1.10.7/integration/bootstrap/3/dataTables.bootstrap.css" rel="stylesheet" />
				
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
						color: #80B702;
					}
					
					
					/* Global */
					body {
						font-family: 'Montserrat', sans-serif;
					}
					
					
					/* #nav */
					#nav {
						background-color: #222326;
					}
					#nav[data-spy='affix'] {
						width: 25%;  /* col-md-3 */
						top: 0;
						right: 0;
						bottom: 0;
						left: 0;
						overflow-y: scroll;
					}
					#nav a {
						color: #949599;
					}
					
					#nav li > a {
						padding: 5px 10px;
						overflow-x: hidden;
						white-space: nowrap;
						text-overflow: ellipsis;
					}
					#nav li > a:hover {
						background-color: #222326;
					}
					
					#nav > li:not(:last-child) {
						margin-bottom: 25px;
					}
					
					#nav > li > a {
						text-transform: uppercase;
					}
					#nav > li > ul > li .fa {
						margin-right: 15px;
						color: #FFFFFF;
					}
					#nav > li > ul > li > a {
						padding-left: 20px;
					}
					#nav > li > ul > li.active > a {
						padding-left: 17px;
						background-color: #2E2F33;
						color: #D9DBE1;
						border-left: 3px solid #94D800;
					}
					
					
					/* #content */
					body {
						background-color: #121314;
					}
					#content {
						padding: 20px;
						background-color: #121314;
						color: #DFE0E5;
					}
					#content section {
						display: none;
					}
					#content a {
						color: #DFE0E5;
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
					
					#content #current_user .playlist-header img {
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
					}
					#content .playlist-header h5 {
						font-size: 12px;
					}
					
					#content .playlist-subheader {
						padding: 7px 0;
						color: #88898C;
						border-top: 1px solid #222326;
						border-bottom: 1px solid #222326;
					}
					
					#content .table > thead > tr > th {
						font-size: 12px;
						color: #949599;
						text-transform: uppercase;
						border-width: 0;
					}
					#content .table > thead > tr > th:not(:first-child) {
						border-left:  1px solid #222326;
					}
					#content .table > tbody > tr > td {
						color: #949599;
						border-color: #222326;
					}
					
					#content .playlist-playlists h1 {
						padding-bottom: 10px;
						font-size: 14px;
						color: #88898C;
						text-transform: uppercase;
						border-bottom: 1px solid #222326;
					}
					#content .playlist-playlists ul.list-inline > li {
						width: 25%;
						margin-bottom: 25px;
						vertical-align: top;
					}
					#content .playlist-playlists ul.list-inline > li div {
						margin: 0;
					}
					#content .playlist-playlists ul.list-inline > li div:last-child {
						padding: 0 10px;
						background-color: #222326;
					}
				</style>
			</head>
			<body>
				<div class="row row-no-margin">
					<div class="col-md-3 col-no-padding">
						<ul id="nav" class="nav" data-spy="affix">
							<!-- MAIN -->
							<xsl:if test="current_user">
								<li>
									<a href="#main">Main</a>
									<ul class="nav">
										<li>
											<a href="#current_user"><i class="fa fa-user" />Profile</a>
										</li>
									</ul>
								</li>
							</xsl:if>
							<!-- YOUR MUSIC -->
							<xsl:if test="user_saved[descendant::*]">
								<li>
									<a href="#user_saved">Your Music</a>
									<ul class="nav">
										<xsl:if test="user_saved/tracks">
											<li>
												<a href="#user_saved_tracks"><i class="fa fa-music" />Songs</a>
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
													<xsl:attribute name="href">#<xsl:value-of select="@id" /></xsl:attribute>
													<i class="fa fa-music" />
													<xsl:value-of select="@name" />
													<xsl:if test="owner/@id != /*/current_user/@id"> by <xsl:value-of select="owner/@id" /></xsl:if>
												</a>
											</li>
										</xsl:for-each>
									</ul>
								</li>
							</xsl:if>
						</ul>
					</div>
					
					<div id="content" class="col-md-9 col-no-padding">
						<!-- MAIN -->
						<xsl:if test="current_user">
							<section id="main">
								<!-- Profile -->
								<section id="current_user">
									<div class="row playlist-header">
										<div class="col-md-2">
											<img class="lazy">
												<xsl:attribute name="data-original"><xsl:value-of select="current_user/images/image/@url"></xsl:value-of></xsl:attribute>
											</img>
										</div>
										<div class="col-md-10">
											<h4>User</h4>
											<h2>
												<a>
													<xsl:attribute name="href"><xsl:value-of select="current_user/external_urls/@spotify" /></xsl:attribute>
													<xsl:value-of select="current_user/@display_name" />
												</a>
											</h2>
										</div>
									</div>
									<div class="row playlist-subheader">
										<div class="col-md-12">
											ID:
											<a>
												<xsl:attribute name="href"><xsl:value-of select="current_user/external_urls/@spotify" /></xsl:attribute>
												<xsl:value-of select="current_user/@id" />
											</a>
											&#8226; <xsl:value-of select="current_user/followers/@total" /> followers
										</div>
									</div>
									<div class="row playlist-playlists">
										<div class="col-md-12">
											<h1>Public Playlists</h1>
											<ul class="list-inline">
												<xsl:for-each select="user_playlists/playlist[@public='True']/owner[@id = /*/current_user/@id]/..">
													<li>
														<a>
															<xsl:attribute name="href">#<xsl:value-of select="@id" /></xsl:attribute>
															<div class="row">
																<img class="lazy">
																	<xsl:attribute name="data-original"><xsl:value-of select="images/image/@url" /></xsl:attribute>
																</img>
															</div>
															<div class="row">
																<h5><xsl:value-of select="@name" /></h5>
																<h5><xsl:value-of select="followers/@total" /> follower<xsl:if test="followers/@total != 1">s</xsl:if></h5>
															</div>
														</a>
													</li>
												</xsl:for-each>
											</ul>
										</div>
									</div>
								</section>
							</section>
						</xsl:if>
						<!-- YOUR MUSIC -->
						<xsl:if test="user_saved[descendant::*]">
							<section id="user_saved">
								<!-- Songs -->
								<xsl:if test="user_saved/tracks">
									<section id="user_saved_tracks">
										<div class="row">
											<div class="col-md-12">
												<xsl:apply-templates select="user_saved/tracks/items" />
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
										<xsl:attribute name="id"><xsl:value-of select="@id" /></xsl:attribute>
										
										<div class="row playlist-header">
											<div class="col-md-2">
												<img class="lazy">
													<xsl:attribute name="data-original"><xsl:value-of select="images/image/@url" /></xsl:attribute>
												</img>
											</div>
											<div class="col-md-10">
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
											<div class="col-md-12">
												Created by:
												<a>
													<xsl:attribute name="href"><xsl:value-of select="owner/external_urls/@spotify" /></xsl:attribute>
													<xsl:value-of select="owner/@id" />
												</a>
												&#8226; <xsl:value-of select="tracks/@total" /> songs,
												<xsl:if test="sum(tracks/items/item/track/@duration_ms) >= 3600000"><xsl:value-of select="floor(sum(tracks/items/item/track/@duration_ms) div 3600000)" /> hr </xsl:if>
												<xsl:value-of select="floor((sum(tracks/items/item/track/@duration_ms) mod 3600000) div 60000)" /> min
												&#8226; <xsl:value-of select="followers/@total" /> follower<xsl:if test="followers/@total != 1">s</xsl:if>
											</div>
										</div>
										<div class="row">
											<div class="col-md-12">
												<xsl:apply-templates select="tracks/items" />
											</div>
										</div>
									</section>
								</xsl:for-each>
							</section>
						</xsl:if>
					</div>
				</div>
				
				<script src="https://code.jquery.com/jquery-1.11.3.min.js"></script>
				
				<script src="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.4/js/bootstrap.min.js"></script>
				
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
						
						// Navigation click events
						$("a[href*='#']").click(function() {
							// #nav .active toggling
							var $a = $(this);
							$nav.find('li.active').removeClass('active');
							$nav.find("a[href='"+$a.attr('href')+"']").parent().addClass('active');
							// #content display toggling
							$section = $('#'+$a.attr('href').substring(1));
							$('#content').find('section:visible').hide();
							$section.show();
							$section.parents(':not(:visible)').show();
							// jquery_lazyload
							$section.find('img.lazy').not("[src*='http']").lazyload({effect:"fadeIn"});
							// DataTables.js re-layout
							$section.find('table.dataTable').css('width','');
							$section.find('table.dataTable').DataTable().columns.adjust().draw();
						});
						// Trigger navigation click event on page load
						if(window.location.hash != '') {
							$("#nav li > a[href='"+window.location.hash+"']").click();
						} else {
							$("#nav > li > ul > li > a").first().click();
						}
					});
				]]></script>
			</body>
		</html>
	</xsl:template>
	
	<xsl:template match="items[descendant::item]">
		<table class="table">
			<thead>
				<tr>
					<th>Track</th>
					<th>Artist</th>
					<th class="text-right">Time</th>
					<th>Album</th>
					<th>Added</th>
					<th>
						<xsl:if test="not(item/added_by[@id])"><xsl:attribute name="style">display:none;</xsl:attribute></xsl:if>
						User
					</th>
				</tr>
			</thead>
			<tbody>
				<xsl:for-each select="item">
					<tr>
						<td>
							<a>
								<xsl:attribute name="href"><xsl:value-of select="track/external_urls/@spotify" /></xsl:attribute>
								<xsl:value-of select="track/@name" />
							</a>
						</td>
						<td>
							<xsl:for-each select="track/artists/artist">
								<xsl:if test="position()>1">, </xsl:if>
								<a>
									<xsl:attribute name="href"><xsl:value-of select="external_urls/@spotify" /></xsl:attribute>
									<xsl:value-of select="@name" />
								</a>
							</xsl:for-each>
						</td>
						<td class="text-right">
							<xsl:value-of select="floor(round(track/@duration_ms div 1000) div 60)" />:<xsl:value-of select="concat(substring('0',1,2-string-length(round(track/@duration_ms div 1000) mod 60)), round(track/@duration_ms div 1000) mod 60)" />
						</td>
						<td>
							<a>
								<xsl:attribute name="href"><xsl:value-of select="track/album/external_urls/@spotify" /></xsl:attribute>
								<xsl:value-of select="track/album/@name" />
							</a>
						</td>
						<td>
							<xsl:value-of select="substring(@added_at,1,10)" />
						</td>
						<td>
							<xsl:if test="not(added_by[@id])"><xsl:attribute name="style">display:none;</xsl:attribute></xsl:if>
							<a>
								<xsl:attribute name="href"><xsl:value-of select="added_by/external_urls/@spotify" /></xsl:attribute>
								<xsl:value-of select="added_by/@id" />
							</a>
						</td>
					</tr>
				</xsl:for-each>
			</tbody>
		</table>
	</xsl:template>
</xsl:stylesheet>