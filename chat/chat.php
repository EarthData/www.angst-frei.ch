<?php
if (isset($_POST['submit'])){
/* Attempt MySQL server connection. Assuming
you are running MySQL server with default
setting (user 'root' with no password) */
$link = mysqli_connect("localhost",
			"root", "", "chat_app");

// Check connection
if($link === false){
	die("ERROR: Could not connect. "
		. mysqli_connect_error());
}

// Escape user inputs for security
$un= mysqli_real_escape_string(
	$link, $_REQUEST['uname']);
$m = mysqli_real_escape_string(
	$link, $_REQUEST['msg']);
date_default_timezone_set('Europe/Berlin');
$ts=date('y-m-d h:ia');

// Attempt insert query execution
$sql = "INSERT INTO chats (uname, msg, dt)
		VALUES ('$un', '$m', '$ts')";
if(mysqli_query($link, $sql)){
	;
} else{
	echo "ERROR: Message not sent!!!";
}
// Close connection
mysqli_close($link);
}
?>
<html>
<head>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta charset=utf-8 />
    <link rel="stylesheet" href="https://direktuebertragung.live/vollbild.css">
    <link rel="shortcut icon" href="favicon.ico" type="image/x-icon">
    <meta name="description" content="RT DE - LIVE">
    <meta name="twitter:card" content="summary_large_image"/>
    <meta name="twitter:image:src" content="https://direktuebertragung.live/rtde/thumbnail.jpg"/>
    <meta property="og:image" content="https://direktuebertragung.live/rtde/thumbnail.jpg"/>
    <meta name="twitter:title" content="Sendekanal von RT DE"/>
    <meta name="robots" content="index, follow">
    <title>RT DE - LIVE</title>
      
    <link href="https://unpkg.com/video.js/dist/video-js.css" rel="stylesheet">
    <link href="./chat.css" rel="stylesheet">
    <script src="https://unpkg.com/video.js/dist/video.js"></script>
    <script src="https://unpkg.com/videojs-contrib-hls/dist/videojs-contrib-hls.js"></script>
</head>

<body onload="show_func()">

<video id="my_video_1" class="video-js vjs-fluid vjs-default-skin" controls preload="auto"
  data-setup='{}'>
  <source src="https://rt-ger.gcdn.co/live/rtdeutsch/playlist.m3u8" type="application/x-mpegURL">
</video>
      
<script>
  var player = videojs('my_video_1');
  player.play();
</script>

<div id="container">
<main>

<script>
function show_func(){

var element = document.getElementById("chathist");
	element.scrollTop = element.scrollHeight;

}
</script>

<form id="myform" action="chat.php" method="POST" >
<div class="inner_div" id="chathist">
<?php
$host = "localhost";
$user = "root";
$pass = "";
$db_name = "chat_app";
$con = new mysqli($host, $user, $pass, $db_name);

$query = "SELECT * FROM chats";
$run = $con->query($query);
$i=0;

while($row = $run->fetch_array()) :
if($i==0){
$i=5;
$first=$row;
?>
<div id="triangle1" class="triangle1"></div>
<div id="message1" class="message1">
<span style="color:white;float:right;">
<?php echo $row['msg']; ?></span> <br/>
<div>
<span style="color:black;float:left;
font-size:10px;clear:both;">
	<?php echo $row['uname']; ?>,
		<?php echo $row['dt']; ?>
</span>
</div>
</div>
<br/><br/>
<?php
}
else
{
if($row['uname']!=$first['uname'])
{
?>
<div id="triangle" class="triangle"></div>
<div id="message" class="message">
<span style="color:white;float:left;">
<?php echo $row['msg']; ?>
</span> <br/>
<div>
<span style="color:black;float:right;
		font-size:10px;clear:both;">
<?php echo $row['uname']; ?>,
		<?php echo $row['dt']; ?>
</span>
</div>
</div>
<br/><br/>
<?php
}
else
{
?>
<div id="triangle1" class="triangle1"></div>
<div id="message1" class="message1">
<span style="color:white;float:right;">
<?php echo $row['msg']; ?>
</span> <br/>
<div>
<span style="color:black;float:left;
		font-size:10px;clear:both;">
<?php echo $row['uname']; ?>,
	<?php echo $row['dt']; ?>
</span>
</div>
</div>
<br/><br/>
<?php
}
}
endwhile;
?>
</div>
	<footer>
		<table>
		<tr>
		<th>
			<input class="input1" type="text"
					id="uname" name="uname"
					placeholder="From">
		</th>
		<th>
			<textarea id="msg" name="msg"
				rows='3' cols='50'
				placeholder="Type your message">
			</textarea></th>
		<th>
			<input class="input2" type="submit"
			id="submit" name="submit" value="send">
		</th>			
		</tr>
		</table>			
	</footer>
</form>
</main>
</div>
<img src="https://statistik.space/piwik/matomo.php?idsite=17&rec=1" style="border:0" alt="" / width=0 height=0>

</body>
</html>

