const socket = io()
var usernum = 0
var totalnum =0
var submitted = 0
let usercheck = false
let submitclick = false
const e= React.createElement
let message = ""
var currentShip = 'aircraft_carrier'
var user = [[0,0,0,0,0,0,0,0,0,0],
			[0,0,0,0,0,0,0,0,0,0],
			[0,0,0,0,0,0,0,0,0,0],
			[0,0,0,0,0,0,0,0,0,0],
			[0,0,0,0,0,0,0,0,0,0],
			[0,0,0,0,0,0,0,0,0,0],
			[0,0,0,0,0,0,0,0,0,0],
			[0,0,0,0,0,0,0,0,0,0],
			[0,0,0,0,0,0,0,0,0,0],
			[0,0,0,0,0,0,0,0,0,0],]
var comp = [[0,0,0,0,0,0,0,0,0,0],
			[0,0,0,0,0,0,0,0,0,0],
			[0,0,0,0,0,0,0,0,0,0],
			[0,0,0,0,0,0,0,0,0,0],
			[0,0,0,0,0,0,0,0,0,0],
			[0,0,0,0,0,0,0,0,0,0],
			[0,0,0,0,0,0,0,0,0,0],
			[0,0,0,0,0,0,0,0,0,0],
			[0,0,0,0,0,0,0,0,0,0],
			[0,0,0,0,0,0,0,0,0,0],]
const delay = secs => new Promise(resolve => setTimeout(resolve, 1000*secs))
socket.on('details', data => {
	if (usercheck==false) {
		usernum = data[0]
		totalnum = data[1]
		usercheck=true
		message= "waiting for player please wait"
		setState()
	}
		
	
})
socket.on('start', ()=> {
	message =`Player ${usernum} : Game Started Submit your board ` 
	setState()})
const shipsize = {
    'aircraft_carrier': 5,
    'battleship': 4,
    'cruiser': 3,
    'destroyer': 2,
    'submarine': 1
}
const state = {}
const checkBox = (x,y) => {
	if (user[x][y]==5) {
		return 'box ship-aircraft_carrier'
	}
	else if(user[x][y]==4)
	{
		return 'box ship-battleship'
	}
	else if(user[x][y]==3)
	{
		return 'box ship-cruiser'
	}
	else if(user[x][y]==2)
	{
		return 'box ship-destroyer'
	}
	else if(user[x][y]==1)
	{
		return 'box ship-submarine'
	}
	else
	{
		return 'box'
	}
}
const checkBox2 = (x,y) => {
	if (comp[x][y]==5) {
		return 'box ship-aircraft_carrier'
	}
	else if(comp[x][y]==4)
	{
		return 'box ship-battleship'
	}
	else if(comp[x][y]==3)
	{
		return 'box ship-cruiser'
	}
	else if(comp[x][y]==2)
	{
		return 'box ship-destroyer'
	}
	else if(comp[x][y]==1)
	{
		return 'box ship-submarine'
	}
	else
	{
		return 'box'
	}
}
const rightClick = (x,y,ID) => {
	for (var i = 0; i <10; i++) {
		for (var j = 0; j < 10; j++) {
			if (user[i][j]==shipsize[currentShip]) {
				user[i][j] = 0
			}
		}
	}
	for (let i = 0; i < shipsize[currentShip]; i++) {
		if (x+i>9) {
			return
		}
		else if(user[x+i][y]!=0)
		{
			return
		}
	}
	for (let i = 0; i < shipsize[currentShip]; i++) {
		user[x+i][y] = shipsize[currentShip]
	}
	setState()
}
const click = (x,y,ID) => {
	for (var i = 0; i <10; i++) {
		for (var j = 0; j < 10; j++) {
			if (user[i][j]==shipsize[currentShip]) {
				user[i][j] = 0
			}
		}
	}
	for (let i = 0; i < shipsize[currentShip]; i++) {
		if (y+i>9) {
			return
		}
		else if(user[x][y+i]!=0)
		{
			return
		}
	}
	for (let i = 0; i < shipsize[currentShip]; i++) {
		user[x][y+i] = shipsize[currentShip]
	}
	setState()
}
const makeBox = (x, y ,ID) => React.createClass({
	render: () =>{
		return React.createElement('div', {id:ID, className: checkBox(x,y), onClick: () => click(x,y,ID), onContextMenu: () => rightClick(x,y,ID)})
	}
})
const makeBox2 = (x, y ,ID) => React.createClass({
	render: () =>{
		return React.createElement('div', {id:ID, className: checkBox2(x,y), onClick: () => {}, onContextMenu: () => {}})
	}
})

const submitGame = event => {
	{event.preventDefault()
	if (submitclick==true) 
		socket.emit('board', user)
		socket.on('error', msg => {
			message = msg + "Start game " + " Again"
			setState()
			submitclick=true
		})
	submitclick = false	
	}
	setState()
}
const setState = updates => {
    Object.assign(state, updates)
   	let id = 0

    ReactDOM.render(React.createElement('div', {id:'board'},
    	React.createElement('form', {onSubmit: submitGame }, message,
    		React.createElement('input', {type: 'submit'} )),
    	user.map((x,i)=>
    	React.createElement('div', {id:'row'},
    	x.map((y,j)=> 
    			React.createElement(makeBox(i,j,++id))
    			
    			
    	)),),
    	(React.createElement('select', {onChange : ev => currentShip =(ev.target.value)},
    		React.createElement('option', {} , 'aircraft_carrier'),
    		React.createElement('option', {} , 'battleship'),
    		React.createElement('option', {} , 'cruiser'),
    		React.createElement('option', {} , 'destroyer'),
    		React.createElement('option', {} , 'submarine'),
    		)),
    	comp.map((x,i)=>
    	React.createElement('div', {id:'row'},
    	x.map((y,j)=> 
    			React.createElement(makeBox2(i,j,++id))
    			
    			
    	)),)),
        document.getElementById('root'))
}

setState({msg: 'Hello World'})
