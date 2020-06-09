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
const makeBox = () => React.createClass({
	render: () =>{
		return React.createElement('div', {className:'box'})
	}
})
const setState = updates => {
    Object.assign(state, updates)
    ReactDOM.render(React.createElement('div', {id:'board'},
    	user.map(x=> 
    			React.createElement(makeBox())
    			
    	)),

        document.getElementById('root'))
}

setState({msg: 'Hello World'})
