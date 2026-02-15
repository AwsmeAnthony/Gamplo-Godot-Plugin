# Gamplo Godot Plugin v1.1
<p style="margin: 20px;">A Pulgin to murge Gamplo with Godot!</p>
The Godot Gamplo Plugin currently supports both AutoLogin and Achievemnts! I plan to add more soon!


# How To Use
<h2> setup </h2>
Set <code>addons/gamplo_plugin/Gamplo.gd</code> as a autoload 


<h2> AutoLogin </h2>
<p style="margin: 20px;"><code>Gamplo.gamplo_data</code> will retun with</p>



<pre class="code-block"><code>{
  "sessionId": "xyz789...",
  "player": {
    "id": "user_id",
    "username": "player1",
    "displayName": "Player One",
    "image": "https://gamplo.com/api/files/avatars/..."
  }
}</code></pre>

<p style="margin: 20px;">If you would like to get the players <code>displayName</code> your code would look somthing like</p>

<pre class="code-block"><code>if Gamplo.gamplo_data == {}:
  return
	
username.text = Gamplo.gamplo_data["player"]["displayName"]</code></pre>

<h2> Achievements </h2>
<p style="margin: 20px;">To unlock an Achievemnt call</p>

<pre class="code-block"><code>Gamplo.unlock_achievement(key)</code></pre>

