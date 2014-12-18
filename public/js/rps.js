view = {}
view.buttons = {}
view.dialog = {}
function init()
{

<<<<<<< HEAD
		view.title = $('<h1>')
		$(view.title).text("Rock, Paper, Scissors - Green Monkeys' Edition")
		view.buttons.template = _.template('<button type="button" class="btn btn-lg btn-<%= type %> glyphicon glyphicon-<%= iconName %>" id="<%= text %>"><%= text %></button>')
		//$('#main').css('background-image','url("/img/splash.png")')
		$('#header').height('50px')
		$('#main').height('80%')
		//$('#header').css('background-color','#228E6A')
		$('body').css('background-color','#228E6A')
		//$('#header').css('color','#FFC50C')
		
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

		//view.modal('Welcome!', buttons)


}

function login()
{










}

function signup(e)
{
	e.preventDefault()	



	
}	
