view = {}
view.buttons = {}
view.dialog = {}
function init()
{

		console.log('test')
		view.title = $('#title')
		//$(view.title).text("Rock, Paper, Scissors - Green Monkeys' Edition")
		view.buttons.template = _.template('<button type="button" class="btn btn-lg btn-<%= type %> glyphicon glyphicon-<%= iconName %>" id="<%= text %>"><%= text %></button>')

		$('.title').height('50px')
		//$('#title').css('font-family': 'PT Sans Caption', 'sans-serif')
		$('.title').css('background-color','#195E19')
		$('body').css('background-color','#195E19')+
		$('.title').css('color','#FFFFA3')

		
		
		$('#Sign-In').css('float','right')
		$('#Sign-Up').css('float','right')
		$('#Sign-In').css('margin-top','3px')
		$('#Sign-Up').css('margin-top','3px')
		$('#Sign-Up').click(signup)
		$('#header').append(view.title)

		view.modal = function(title, content, footer)
		{
			$(".modal-title").text(title)
			$(".modal-body").empty()
			$(".modal-body").append(content)

			if(footer)
			{
				$(".modal-footer").empty()
				$(".modal-body").append(footer)
			}
			else
			{
				$(".modal-footer").empty()
			}
			$('#modalDialog').modal('show')

		}
		buttons = $('<center>')
		buttonAttribs = [{type:'primary', iconName:'user', text:'Sign-In'},{type:'success', iconName:'pencil', text:'Sign-Up'}]
		$.each(buttonAttribs, function(i,v){
			code = view.buttons.template(v)
			$(buttons).append(code)
		})

		view.modal('Welcome!', buttons)


}

function login()
{










}

function signup(e)
{
	e.preventDefault()	



	
}	
