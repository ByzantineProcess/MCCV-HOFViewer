extends Node2D

var halloffamejson
var body2
var games = ['MG_ROCKET_SPLEEF', 'MG_SURVIVAL_GAMES', 'MG_PARKOUR_WARRIOR', 'MG_ACE_RACE', 'MG_BINGO_BUT_FAST', 'MG_TGTTOSAWAF', 'MG_SKYBLOCKLE', 'MG_SKY_BATTLE', 'MG_HOLE_IN_THE_WALL', 'MG_BATTLE_BOX', 'MG_BUILD_MART', 'MG_SANDS_OF_TIME', 'MG_DODGEBOLT', 'MG_PARKOUR_TAG', 'MG_GRID_RUNNERS', 'MG_MELTDOWN', 'GLOBAL_STATISTICS', 'LEGACY_STATISTICS']

var gsize = {}

func _ready():
	
	randomize()
	var halloffamereq = HTTPRequest.new()
	add_child(halloffamereq)
	halloffamereq.connect("request_completed", self, "_http_request_completed")
	halloffamereq.request("https://api.mcchampionship.com/v1/halloffame")

func _http_request_completed(result, response_code, headers, body):
	if response_code != 200:
		_ready()
	body2 = body
	regen()


func regen():
	halloffamejson = parse_json(body2.get_string_from_utf8())
	for x in games:
		if halloffamejson["data"][x].values().size() == 0:
			games.remove(games.find(x))
			halloffamejson.data.erase(x)
		else:
			gsize.merge({x: int(halloffamejson["data"][x].values().size())})
	print(games.size())
	

	
	var randgame = RandomNumberGenerator.new()
	randgame.seed = randi()
	randgame = randgame.randi_range(0,13)
	
	
	var randindex = RandomNumberGenerator.new()
	randindex.seed = randi()
	randindex = randindex.randi_range(0, halloffamejson.values()[1][games[randgame]].keys().size() -1)
	
	while randindex < 0:
		randindex.seed = randi()
		randindex = randindex.randi_range(0, halloffamejson.values()[1][games[randgame]].keys().size() -1)
	
	
	$Display/GameIcon.animation = games[randgame]
	
	$Display/GameName.text = matchgame(games[randgame])
	$Display/TitleName.text = halloffamejson.values()[1][games[randgame]].keys()[randindex]
	$Display/Name.text = halloffamejson.values()[1][games[randgame]].values()[randindex].values()[2]
	$Display/Value.text = str(halloffamejson.values()[1][games[randgame]].values()[randindex].values()[3])
	
	var http_request = HTTPRequest.new()
	add_child(http_request)
	http_request.connect("request_completed", self, "_img_request_completed")
	# Perform the HTTP request. The URL below returns a PNG image as of writing.
	var error = http_request.request("https://crafthead.net/helm/" + halloffamejson.values()[1][games[randgame]].values()[randindex].values()[2])
	if error != OK:
		push_error("An error occurred in the HTTP request.")


# Called when the HTTP request is completed.
func _img_request_completed(result, response_code, headers, body):
	var image = Image.new()
	var error = image.load_png_from_buffer(body)
	if error != OK:
		push_error("Couldn't load the image.")

	var texture = ImageTexture.new()
	texture.create_from_image(image)

	# Display the image in a TextureRect node.
	$Display/Avatar.texture = texture
	$Animator.play("main")

func matchgame(txt):
	var games = {'MG_ROCKET_SPLEEF': "Rocket Spleef", 'MG_SURVIVAL_GAMES': "Survival Games", 'MG_PARKOUR_WARRIOR': "Parkour Warrior", 'MG_ACE_RACE': "Ace Race", 'MG_BINGO_BUT_FAST': "Bingo But Fast", 'MG_TGTTOSAWAF':"TGTTOSAWAF", 'MG_SKYBLOCKLE': "Skyblockle", 'MG_SKY_BATTLE': "Sky Battle", 'MG_HOLE_IN_THE_WALL': "Hole in the Wall", 'MG_BATTLE_BOX': "Battle Box", 'MG_BUILD_MART': "Big Sales at Build Mart", 'MG_SANDS_OF_TIME': "Sands of Time", 'MG_DODGEBOLT': "Dodgebolt", 'MG_PARKOUR_TAG': "Parkour Tag", 'MG_GRID_RUNNERS': "Grid Runners", 'MG_MELTDOWN': "Meltdown", 'GLOBAL_STATISTICS': "Global Statistics", 'LEGACY_STATISTICS': "Foot Race"}
	return games[txt]


func _on_Animator_animation_finished(anim_name):
	regen()
