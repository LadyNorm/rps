view = {}
view.buttons = {}

function init()
{

		console.log('test')
		view.title = $('<h1>')
		$(view.title).text("Rock, Paper, Scissors - Green Monkeys' Edition")
		view.buttons.template = _.template('<button type="button" class="btn btn-lg btn-<%= type %> glyphicon glyphicon-<%= iconName %>" id="<%= text %>"><%= text %></button>')

		$('#header').height('50px')
		//$('#header').css('background-color','#228E6A')
		//$('body').css('background-color','#228E6A')+
		//$('#header').css('color','#FFC50C')

		buttonAttribs = [{type:'primary', iconName:'user', text:'Sign-In'},{type:'success', iconName:'pencil', text:'Sign-Up'}]
		$.each(buttonAttribs, function(i,v){
			code = view.buttons.template(v)
			$('#header').append(code)
		})
		$('#Sign-In').css('float','right')
		$('#Sign-Up').css('float','right')
		$('#Sign-In').css('margin-top','3px')
		$('#Sign-Up').css('margin-top','3px')
		$('#header').append(view.title)
}

function login()
{










}

function signup()
{




	
}	
