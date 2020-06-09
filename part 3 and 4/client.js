const socket = io()
const e= React.createElement
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
	if (user[x][y]==1) {
		return 'box ship-aircraft_carrier'
	}
	else
	{
		return 'box'
	}
}
const click = (x,y,ID) => {
	for (let i = 0; i < 5; i++) {
		if (y+i>9) {
			return
		}
		else if(user[x][y+i]!=0)
		{
			return
		}
	}
	for (let i = 0; i < 5; i++) {
		user[x][y+i] = 1
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
    			
    			
    	)),)),

        document.getElementById('root'))
}

setState({msg: 'Hello World'})
