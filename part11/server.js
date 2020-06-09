const fs = require('fs')
const http = require('http')
const socketio = require('socket.io')
let list= []
let listBoards = []
let number=0
let checksOnBoard=2
const checking = (x,y,check,user,checks) => {
	if (check>6) {
		return true
	}
	if (checks[check]==0) {
		return false
	}
	checks[check] = 0
	if (check==1) {
		return true
	}
	if (x<9 && user[x+1][y]==check) {
		if(x+check-1>9)
		{
			return false
		}
		for (var i = 0; i <check; i++) {
			if (user[x+i][y]!=check) {
				return false
			}
		}
		for (var i = 0; i <check; i++) {
			user[x+i][y] = check * 7
			
		}
	}
	else if (user[x][y+1] && user[x][y+1]==check) {
		if(y+check-1>9)
		{
			return false
		}
		for (var i = 0; i <check; i++) {
			if (user[x][y+i]!=check) {
				return false
			}
		}
		for (var i = 0; i <check; i++) {
			user[x][y+i] = check*7
		}
	}
	return true
}
const readFile = file => new Promise((resolve, reject) =>
    fs.readFile(file, 'utf8', (err, data) => err ? reject(err) : resolve(data)))

const delay = msecs => new Promise(resolve => setTimeout(resolve, msecs))

const server = http.createServer(async (request, response) =>
    response.end(await readFile(request.url.substr(1))))

const io = socketio(server)

const boardCheck = (socket) =>{
	socket.on('board', user=> {
		const checks = [0,1,2,3,4,5]
    	for (var i = 0; i <10; i++) {
			for (var j = 0; j < 10; j++) {
				if (user[i][j]!=0) {
					check = user[i][j]
					if (checking(i,j,check,user,checks)==false) {
						io.sockets.emit('error','Someone\'s Ships are out of bounds ')
					}
				}
			}
		}
		for (var i = 0; i <6; i++) {
			if (checks[i]!=0) {
				io.sockets.emit('error', 'Someone\'s ships are not enough ')
			}
		}
		checksOnBoard = checksOnBoard -1 
		listBoards = [...listBoards,user]
    })
}
io.sockets.on('connection', socket => {
    console.log('a client connected')
    list = [...list,socket.id]
    number= number+1
    if (list.length%2==0) {
    	io.sockets.emit('details',[2,number])
    	boardCheck(socket)
    	io.sockets.emit('start', 1)

    }
    else if (list.length%2==1) {
    	io.sockets.emit('details',[1,number])
    	boardCheck(socket)

    }
    if (checksOnBoard==0) {
    	io.sockets.emit('game',[1,number])
    	io.sockets.on('attack', (x,y) =>{ 
    		board1 = listBoards[1]
    		if (board1[x][y]!=0) {
    			io.sockets.emit('attacked', [2,number+1])

    		}
    		else{
    			io.sockets.emit('saved', [2,number+1])
    		}

    	})

    }
    socket.on('disconnect', () => console.log('a client disconnected'))
})

server.listen(8000)
