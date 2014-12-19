view = {}
ctrl = {}
view.buttons = {}
view.dialog = {}
ctrl.players = {}
function init()
{
		
		splashImage = $('<canvas>')
		$(splashImage).width('100%')
		$(splashImage).height('100%')
		img = $('<img>')
		$(img).attr("src", "img/splash.png")
		$(img).attr("id", "splash")
        splash  = $('<center>').append(img)
        splash.append(splashImage)
		$('#main').append(splash)

		splashImage.height(400)
		splashImage.width(975)
		ctx = splashImage[0].getContext('2d');
        
        
        img = new Image();

        //drawing of the test image - img1
        img.onload = function () {
            ctx.translate(splashImage.width / 2, splashImage.height / 2)
            ctx.scale(-1, 1);
            ctx.drawImage(img, 0, 0, 975, img.height);
            ctx.restore()

        };

        img.src = 'img/splash.png';

		console.log('test')

		view.title = $('#title')
		//$(view.title).text("Rock, Paper, Scissors - Green Monkeys' Edition")
		view.buttons.template = _.template('<button type="button" class="btn btn-lg btn-<%= type %> glyphicon glyphicon-<%= iconName %>" id="<%= text %>"><%= text %></button>')
		//$('#main').css('background-image','url("/img/splash.png")')
		$('.title').height('50px')
		//$('.title').height('80%')
		$('.title').css('background-color','#195E19')
		$('body').css('background-color','#195E19')
		$('.title').css('color','#FFD700')


		
		
		$('#Sign-In').css('float','right')	
		$('#Sign-Up').css('float','right')
		$('#Sign-In').css('margin-top','3px')
		$('#Sign-Up').css('margin-top','3px')
		$('#Sign-Up').click(signup)
		$('#header').append(view.title)

		view.modal = function(title, content, mandatory, footer)
		{
			
			$(".modal-body").empty()
			$(".modal-body").append(content)
			if(!mandatory)
			{
				$("button.close").show()
				$(".modal-header").append($('<div>').addClass("modal-title"))
				blocking = {}
			}
			else
			{
				$("button.close").hide()
				blocking = {backdrop:'static'}
			}
			if(footer)
			{
				$(".modal-footer").empty()
				$(".modal-footer").append(footer)
			}
			else
			{
				$(".modal-footer").empty()
			}

			$('#modalDialog').modal(blocking)
			$(".modal-title").text(title)
			$('#modalDialog').css('opacity', '0.78')
			$('#modalDialog').mouseenter(function() {
  				$(this).css("opacity",".90")
			});
			$('#modalDialog').mouseleave(function() {
  				$(this).css("opacity","0.78")
			});

		}

		view.closeModal = function()
		{
			$('#modalDialog').modal('hide')
		}
		
		welcome()

}
function welcome()
{
		buttons = $('<center>')

		buttonAttribs = [{type:'primary', iconName:'user', text:'Sign-In'},{type:'success', iconName:'pencil', text:'Sign-Up'}]
		$.each(buttonAttribs, function(i,v){
			code = view.buttons.template(v)
			$(buttons).append(code)
		})

		view.modal('Welcome!', buttons, true)
		$('#Sign-In').css('margin-right','4px')
		$('#Sign-In').click(signin)
		$('#Sign-Up').click(signup)
}
function signin()
{

	signinForm = $("<form>")
	fields = ['username', 'password']
	$.each(fields, function(i, v){
		$label = $('<label>')
		$input = $('<input>')
		if(v == 'password')
			$input.attr('type',v)
		$input.attr('id', v)
		$label.attr('for', v)
		$input.attr('name', v)
		$label.text(v.charAt(0).toUpperCase() + v.slice(1)+":")
		$(signinForm).append($label)
		$(signinForm).append($input)
		$(signinForm).append($('<br>'))

	})
	footerButtons = $('<div>')
	
	submit = view.buttons.template({type:'primary', iconName:'user', text:'Sign-In'})
	cancel = view.buttons.template({type:'warning', iconName:'remove', text:'Cancel'})
	footerButtons.append(submit)
	footerButtons.append(cancel)

	//view.closeModal()
	view.modal("Login", signinForm, true, footerButtons)
	$('#Sign-In').css('margin-right','4px')
	$('#Cancel').click(welcome)
	$('#Sign-In').click(function(){
		var data = {}
		$("input").each(function(i,v){
					v = $(v)
					k = $(v).attr('id')
					data[k] = v.val()
			})
			console.log(data)
			$.ajax({
			  type: 'POST',
			  url: '/signin',
			  data:data
			}).success(function(response) {
				console.log(response)
				if(response["error"])
		  			$(view.signinForm).parent().append(ctrl.compiledErrorTemplate({error:response['error']}))
		  		else
		  		{
		  			response = JSON.parse(response)
		  			console.log(response)
				  	console.log("Signed In", response["session_id"])
				  	ctrl.sessionId = response["session_id"]
				  	ctrl.userId = response["user_id"]
				  	localStorage.setItem("sessionId", ctrl.sessionId)
				  	localStorage.setItem("userId", ctrl.userId)
				  	view.closeModal()
				  	startSession()
				}
			})
	})

}

function signup()
{
	signupForm = $("<form>")
	fields = ['username', 'password']
	$.each(fields, function(i, v){
		$label = $('<label>')
		$input = $('<input>')
		if(v == 'password')
			$input.attr('type',v)
		$input.attr('id', v)
		$label.attr('for', v)
		$input.attr('name', v)
		$label.text(v.charAt(0).toUpperCase() + v.slice(1)+":")
		$(signupForm).append($label)
		$(signupForm).append($input)
		$(signupForm).append($('<br>'))

	})
	footerButtons = $('<div>')
	
	submit = view.buttons.template({type:'primary', iconName:'user', text:'Sign-Up'})
	cancel = view.buttons.template({type:'warning', iconName:'remove', text:'Cancel'})
	footerButtons.append(submit)
	footerButtons.append(cancel)

	//view.closeModal()
	view.modal("Sign Up", signupForm, true, footerButtons)
	$('#Sign-Up').css('margin-right','4px')
	$('#Cancel').click(welcome)
	$('#Sign-Up').click(function(){
		var data = {}
		$("input").each(function(i,v){
					v = $(v)
					k = $(v).attr('id')
					data[k] = v.val()
			})
			console.log(data)
			$.ajax({
			  type: 'POST',
			  url: '/signup',
			  data:data
			}).success(function(response) {
				console.log(response)
				if(response["error"])
		  			$(view.signupForm).parent().append(ctrl.compiledErrorTemplate({error:response['error']}))
		  		else
		  		{
		  			console.log(response)
				  	console.log("Signed Up", response["sessionId"])
				  	ctrl.sessionId = response["sessionId"]
				  	ctrl.userId = response["user_id"]
				  	localStorage.setItem("sessionId", ctrl.sessionId)
				  	localStorage.setItem("userId", ctrl.userId)
				  	view.closeModal()
				  	startSession()
				}
			})
	})
}

function startSession()
{
	$table = $('<table>')
	
	$('center').remove()
	$('#splash').hide('fade')
	view.onlinePlayers = $('<div>').attr('id', 'onlinePlayers')

	view.currentGames = $('<div>').attr('id', 'currentGames')
	$(view.currentGames).width(500)
	columns = ["With", "Score", "Opponent's Score"]
	head = $('<thead>')
	table = $('<table>').addClass('table table-bordered table-hover table-condensed')
	$(table).append(head)
	$.each(columns, function(i,v){
		$(head).append($('<th>').text(v))
	})

	$(view.currentGames).append(table)
	$('#main').append(view.currentGames)
	$('#main').append(view.onlinePlayers)
	$('#main').append(view.currentGames)
	$(view.onlinePlayers).css('float', 'right')
	$(view.onlinePlayers).css("margin","3px").css("border","1px solid black").append($("<div>").append($("<div>").addClass('row').append($("<div>").addClass('col-md-4').attr('id','tableHolder'))).css('background-color', "FFFFFF"))
	$name = $('<th>').text('Name')
	$score = $('<th>').text('Score')
	$($table).addClass('table table-bordered table-hover table-condensed').append($('<thead>').append($name).append($score))
	$($table).attr('id', 'onlinePlayers')
	$($table).css('margin-left', '2px')
	$($table).css('margin-right', '2px')
	
	$('<dib>')


	online_players()
	current_games()
}

function endSession()
{







	
}

function playerInfo(playerId)
{
	//some get statement to get player info
	jQuery.get('/info/'+playerId, null, function(response){
		footerButtons = $('<div>')
		
		challengeb = view.buttons.template({type:'primary', iconName:'user', text:'Challenge'})
		cancel = view.buttons.template({type:'warning', iconName:'remove', text:'Close'})
		footerButtons.append(challengeb)
		footerButtons.append(cancel)
		view.modal("Player Info:", response, false, footerButtons)
		$('#Close').click(view.closeModal)

		$('#Challenge').click(function(){

			challenge(playerId)
		})
	})
	
}

function challenge(playerId)
{
	view.closeModal()
	data = {player_one_id:ctrl.userId,
		player_two_id:playerId}

	$.ajax({
  	type: "POST",
  	url: '/new_game',
  	data: data,
  	success: function(x){ console.log(x)	}
	});





}

function current_games()
{
	table = $('table', view.currentGames)
	table.css("background-color", 'white')
	data = {player_id: ctrl.userId}
	$.ajax({
  	type: "POST",
  	url: '/current_games',
  	data: data,
  	success: function(games){
  		games = JSON.parse(games)
  		console.table(games)
  		$.each(games, function(i,v){
  			row = $('<tr>').attr('id', 'game-'+v['hash'])
  			row.append($('<td>').text(v['opponent_username'])).append($('<td>').text(v['score'])).append($('<td>').text(v['opponent_score']))
  			$(table).append(row)
  			
  		})
  		$('tr', table).click(function(e){
			tgt = e.currentTarget
			console.log(tgt)
			gameHash = $(tgt).attr('id')
			console.log(gameHash)
			gameHash = gameHash.substring(gameHash.indexOf('-')+1, gameHash.length)
			
			play(gameHash)
			})
  	}
	});


}
function play(gameHash)
{
	submit = view.buttons.template({type:'primary', iconName:'user', text:'Submit'})
	cancel = view.buttons.template({type:'warning', iconName:'remove', text:'Cancel'})
	footerButtons.empty()
	footerButtons.append(submit)
	footerButtons.append(cancel)

	choices = "almost done"
	view.modal("Game", choices, false, footerButtons)
	$('#Cancel').click(view.closeModal)

	
	view.modal("YAY", "<ul><img id='rock' src='../img/rock.jpg' width='200px' height='200px' /><img id='paper' src='../img/paper.jpg'  width='200px' height='200px' /><img id='scissors' src='../img/scissors.jpg' width='200px' height='200px' /></ul>", false, "footer")
}
function online_players()
{
	jQuery.get('/online', null, function(players){
		console.log(players)

		$('tr', '#onlinePlayers').remove()
		players = JSON.parse(players)

		$.each(players, function(i,v){
			$table.append($('<tr>').addClass('active').attr('id','player-'+v['id']).append($('<td>').text(v['username'])).append($('<td>').text(v['score'])))

		})
		
		
		
		$("#tableHolder").append($('h4').text("Online Players").css('margin-left',"4px"))
		$("#tableHolder").append($table)

		$('tr', $table).click(function(e){
			tgt = e.currentTarget
			playerId = $(tgt).attr('id')
			playerId = playerId.substring(playerId.indexOf('-')+1, playerId.length)
			
			if (playerId != parseInt(localStorage.getItem('userId')))
				playerInfo(playerId)
		})
	})
}