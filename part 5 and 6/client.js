const socket = io()
const e= React.createElement
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
const delay = secs => new Promise(resolve => setTimeout(resolve, 1000*secs))

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
const click = (x,y,ID) => {
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
		console.log(y+i)
	}
	setState()
}
const makeBox = (x, y ,ID) => React.createClass({
	render: () =>{
		return React.createElement('div', {id:ID, className: checkBox(x,y), onClick: () => click(x,y,ID)})
	}
})
const setState = updates => {
    Object.assign(state, updates)
   	let id = 0

    ReactDOM.render(React.createElement('div', {id:'board'},
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
    		))),
        document.getElementById('root'))
}

setState({msg: 'Hello World'})
