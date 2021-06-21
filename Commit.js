const fs = require('fs');
var util = require('util');
let new_data = [];
var rawdata;
const express = require('express');
const app = express();
var http = require('http').createServer(app);
var io = require('socket.io')(http);
const path = require('path');
const router = express.Router();
var    bodyParser= require('body-parser');
var sql = require("mssql");
var os = require("os");
var session = require('express-session');
const username = require('username');
var us = require("underscore");
const request = require('request');
var sql = require("mssql");
const captureWebsite = require('capture-website');
const schedule = require('node-schedule');

//var Handsontable = require('Handsontable');

// var bodyParser = require('body-parser')
// app.use( bodyParser.json() );       // to support JSON-encoded bodies
// app.use(bodyParser.urlencoded({     // to support URL-encoded bodies
  // extended: true
// })); 



//extra
function noDelaySetInterval(func, interval) { 
	func(); 
	return setInterval(func, interval); 
}

//Screenshot capture
const job = schedule.scheduleJob('0 8,20 * * *', function(){
let date = new Date().getUTCDate().toString() +"_"+ new Date().getUTCMonth().toString() +"_"+ new Date().getUTCFullYear().toString() +" "+ new Date().getHours().toString() +"_"+ new Date().getMinutes().toString();
console.log(date);
try {
captureWebsite.file('http://mfgrpa2:4000/', 'G:\\IMFS\\FAB\\PROD\\Hendy\\Commit files\\screenshot '+date+'.png', {
	width: 2000,
	height: 3000,
	delay: 10
});
console.log('ScreenShot Captured at '+ date);
}
catch(err){
console.log('ScreenShot Failed '+ err);
}
});

//Save PREVDATA.json
const job2 = schedule.scheduleJob('1 * * * *', function(){
let date = new Date().getUTCDate().toString() +"_"+ new Date().getUTCMonth().toString() +"_"+ new Date().getUTCFullYear().toString() +" "+ new Date().getHours().toString() +"_"+ new Date().getMinutes().toString();
console.log(date);
try {
var PREVDATA = JSON.stringify(json);
fs.writeFileSync('PREVDATA.json', PREVDATA);
}
catch(err){
console.log('PREVDATA.json Fail to Update'+ err);
}
});

var socket = io;
//variables
let time = 600000;
var process = [];
var exception = [];
var wsg = [];
let mainuser = [];
let json = [[]];
port = 4000;
let access_commit = ['yokeshbabuv','heyudao1','mfgrpa2','hendya','apratomo'];
////



/////////////////////////////////////////////////////SQL prod06
// initialize
let original = '';
let D_last_refresh = '';
let D_last_refresh2 = '';
let D_commit = [[]];
let D_commit2 = [[]];
let D_last_refresh_lot = '';
let D_lot = [[]];
let D_RLSrefer = '';
let passcode = "micron123";

var o = {
  set D_commit(x) {
	D_commit = x;
	io.emit('Refresh');
	
  },
  set D_commit2(x) {
	D_commit2 = x;
	io.emit('Refresh');
  },
  set D_lot(x) {
	D_lot = x;
	io.emit('Refresh');
  }
};


// config for your database
var config = {
	user: 'f10prod',
	password: '2020BestYear',
	server: 'fsmssprod06', 
	database: 'fab_lot_extraction',
	requestTimeout: 300000,	
	options: {
    encrypt: false
	}
};


sql.connect(config, setInterval(
function run () {	
//run query 
var sqlcommit = fs.readFileSync('.//Commit.sql').toString();
var sqlcommit2 = fs.readFileSync('.//Commit_PG.sql').toString();
var sqllot = fs.readFileSync('.//P3_Lot.sql').toString();


if (new Date().getHours() >= 7 && new Date().getHours() <= 8) {
 //console.log("No Refresh for 7AM to 9AM");
} else {
   	var requestsql = new sql.Request();
	requestsql.query(sqlcommit, function(err, result) {		
	if (err) {
		throw err;
	} 
	else {
		//console.log(Date().toString() +'\n' + 'Refreshed Commit Query\n');
		o.D_commit = result.recordset;
		D_last_refresh = result.recordsets[1];	
	}	
	})
	
	var requestsql2 = new sql.Request();
	requestsql2.query(sqlcommit2, function(err, result) {		
	if (err) {
		throw err;
	} 
	else {
		//console.log(Date().toString() +'\n' + 'Refreshed Commit Query\n');
		o.D_commit2 = result.recordset;
		D_last_refresh2 = result.recordsets[1];	
	}	
	})
	
	var requestsql3 = new sql.Request();
	requestsql3.query(sqllot, function(err, result) {		
	if (err) {
		throw err;
	} 
	else {
		//console.log(Date().toString() +'\n' + 'Refreshed lot Query\n');
		o.D_lot = result.recordset;
		D_last_refresh_lot = result.recordsets[1];	
	}	
	})
	
}

}
,time)
)


sql.connect(config, //setInterval(
function run () {	
//run query 
var sqlcommit = fs.readFileSync('.//Commit.sql').toString();
var sqlcommit2 = fs.readFileSync('.//Commit_PG.sql').toString();
var sqllot = fs.readFileSync('.//P3_Lot.sql').toString();

	var requestsql = new sql.Request();
	requestsql.query(sqlcommit, function(err, result) {		
	if (err) {
		throw err;
	} 
	else {
		//console.log(Date().toString() +'\n' + 'Refreshed Commit Query\n');
		o.D_commit = result.recordset;
		D_last_refresh = result.recordsets[1];	
	}	
	})
	
	var requestsql2 = new sql.Request();
	requestsql2.query(sqlcommit2, function(err, result) {		
	if (err) {
		throw err;
	} 
	else {
		//console.log(Date().toString() +'\n' + 'Refreshed Commit Query\n');
		o.D_commit2 = result.recordset;
		D_last_refresh2 = result.recordsets[1];	
	}	
	})
	
	var requestsql3 = new sql.Request();
	requestsql3.query(sqllot, function(err, result) {		
	if (err) {
		throw err;
	} 
	else {
		//console.log(Date().toString() +'\n' + 'Refreshed lot Query\n');
		o.D_lot = result.recordset;
		D_last_refresh_lot = result.recordsets[1];	
	}	
	})
	
}
//,time)
)

//}


//online.push( {usertype: 'onlineuser', id: domains.toString().replace('.imfs.micron.com','')} );



//////////////////function///////////////////////////////////////////////


/////////////////socket////////////////////////////////////////////////

io.on('connection', (socket) => {

socket.on('UserIP',()=>{
	var socketId = socket.id;
    var clientIp = socket.request.connection.remoteAddress;
    var ip = socket.conn.remoteAddress;
	ip = ip.replace(/^.*:/, '');
	try{
		require('dns').reverse(ip, function(err, domains) {
			if(err) {
				console.log("This is DNS Error: "+err.toString());
				return;
			}
			user = domains.toString().replace('.imfs.micron.com','');
			//console.log(Date().toString() +'\n' + user + ' Open the link\n');
			io.emit('Accessname',user);
		})
	}
	catch(e){
		user = "UNKNOWN";
		io.emit('Accessname',user);
	}
		
});

socket.on('Auth', (data) => {
    var socketId = socket.id;
    var clientIp = socket.request.connection.remoteAddress;
    var ip = socket.conn.remoteAddress;
	ip = ip.replace(/^.*:/, '');
	try{
		require('dns').reverse(ip, function(err, domains) {
			if(err) {
				console.log("This is DNS Error: "+err.toString());
				return;
			}
			user = domains.toString().replace('.imfs.micron.com','');
			// console.log(type);
			// console.log(user);
			
			if (data.type == "Edit Commit"){
				if (access_commit.indexOf(user) !== -1){
					//console.log(Date().toString() +'\n' + user +'('+data.socket+')' +' '+ data.type);
					redirect  = "http://mfgrpa2:" + port.toString() + "/Commit_Edit";
					access = "Y";
				}
				else{
					console.log(user +'('+data.socket+')' +' Cannot '+ data.type);
					redirect  = "";
					access = "N";			
				}
			}
			
			else if (data.type == "Edit Commit_Executed"){
				if (access_commit.indexOf(user) !== -1){
					console.log(Date().toString() +'\n' + user +'('+data.socket+')' +' '+ data.type);
					redirect  = "Commit Eddited (+)";
					access = "Y";
				}
				else{
					console.log('!!! '+user +'('+data.socket+')' +' Cannot Edit Commited but Commit Edited');
					redirect  = "Commit Eddited (-)";
					access = "N";		
				}
			}
			
			else if (data.type == "Add Access"){
				if (access_commit.indexOf(user) !== -1){
					console.log(Date().toString() +'\n' + user +'('+data.socket+')' +' '+ data.type);
					access_commit = data.data;
					//console.log(data.data);
					io.emit('iframereload');
					redirect = "Updated Access List"
					access = "Y";
				}
				else{
					console.log(user +'('+data.socket+')' +' Cannot '+ data.type);
					redirect  = " NOT allowed to edit access";
					access = "N";			
				}
			}

			
			else{
				console.log("Empty");
			}
			
			forward = {datetime: Date(), type: data.type,  Access :access, Socket: data.socket,  redirect: redirect, user: user};//console.log(forward);
			io.to(data.socket).emit('Access',forward);
		});
	}
	catch(e){
		forward = {datetime: Date(), type: data.type,  Access :'N', Socket: data.socket,  redirect: redirect, user: "Error Occured!! User "};//console.log(forward);
		io.to(data.socket).emit('Access',forward);
	}
}); 

socket.on('add_me', (data) => {
	var socketId = socket.id;
    var clientIp = socket.request.connection.remoteAddress;
    var ip = socket.conn.remoteAddress;
	ip = ip.replace(/^.*:/, '');
	try{
		require('dns').reverse(ip, function(err, domains) {
			if(err) {
				console.log("This is DNS Error: "+err.toString());
				return;
			}
			user = domains.toString().replace('.imfs.micron.com','');
			if (data.data == passcode){
				console.log(user+" self-added Access");
				try{
					access_commit = access_commit.toString() +','+ user;
					access_commit = access_commit.split(",");
					//console.log(access_commit);
					//access_commit.push(user);
				} catch (err){
					 console.log(err);
				}
				
				
				setTimeout(
				() => {
					io.emit('iframereload');
					io.emit('Accessname',access_commit);
				},2000)
			}
		})	
	}
	catch(e){
		console.log("Add_me Error");
	}
});


socket.on('commit_edit_result', (data) => {
	json = data;
	//console.log(json);
	io.emit('commit_update',data);
});


socket.on('remark_update', (data) => {
	json = data;
	//console.log(json);
	io.emit('commit_update',data);
});

socket.on('sqlcommit', () => {
	io.emit('send_sqlcommit',D_commit);
	io.emit('send_sqlcommit2',D_commit2);
	io.emit('send_refreshtime',D_last_refresh);
	io.emit('send_refreshtime2',D_last_refresh2);
	io.emit('send_lot',D_lot);
	io.emit('send_lot_refresh',D_last_refresh_lot);
	////console.log("commit is pulled");
});



socket.on('commit_getdata',() => {
	io.emit('commit_update',json);
});


socket.on('commit_access_user',() => {
	io.emit('access_user',access_commit);
});

socket.on('send_passcode',() => {
	io.emit('passcode_send',passcode);
});

// socket.on('to_lot_list',() => {
	// var lot_link = "http://mfgrpa2:" + port.toString() + "/lot_list"
	// io.emit('passcode_send',passcode);
// });





socket.on('disconnect', function () {
    var socketId = socket.id;
    var clientIp = socket.request.connection.remoteAddress;
    var ip = socket.conn.remoteAddress;
	ip = ip.replace(/^.*:/, '');
	try{
		require('dns').reverse(ip, function(err, domains) {
		if(err) {
			console.log(err.toString());
			return;
		}})
	}
	catch(e){
		
	}
	//main = main.filter(e => e.id !== domains.toString().replace('.imfs.micron.com','') );

	});
});



//Sending Query result
// app.get('/refreshtime_data', function (req, res) {
	// res.send(D_last_refresh);
// })

// app.get('/sqlcommit', function (req, res) {
	// res.send(D_commit);
// })

app.get('/last_refresh', function (req, res) {
	res.send(D_last_refresh);
})

app.get('/last_refresh2', function (req, res) {
	res.send(D_last_refresh2);
})

app.get('/last_refresh_lot', function (req, res) {
	res.send(D_last_refresh_lot);
})

app.get('/AccessLIST', function (req, res) {
	res.send(access_commit);
})

app.get('/commit_set', function (req, res) {
	res.send(json);
})

//tohtml
app.get('/',function (req,res) {
//console.log(Date().toString() +'\n' + "Client side Viewing.........\n");
res.sendFile('C:\\Users\\heyudao\\Documents\\Document\\F10N_MFG\\Commit\\Commit.html');
});


app.get('/Commit_Edit',function (req,res) {
//console.log(Date().toString() +'\n' + "Client side Viewing.........\n");
res.sendFile('C:\\Users\\heyudao\\Documents\\Document\\F10N_MFG\\Commit\\Commit - Edit.html');
});

app.get('/micron123',function (req,res) {
//console.log(Date().toString() +'\n' + "Client side Viewing.........\n");
res.sendFile('C:\\Users\\heyudao\\Documents\\Document\\F10N_MFG\\Commit\\Commit - Give Access.html');
});

app.get('/lot_list',function (req,res) {
//console.log(Date().toString() +'\n' + "Client side Viewing.........\n");
res.sendFile('C:\\Users\\heyudao\\Documents\\Document\\F10N_MFG\\Commit\\lot_list.html');
});

app.get('/handsontable',function (req,res) {
//console.log(Date().toString() +'\n' + "Client side Viewing.........\n");
res.sendFile('C:\\Users\\heyudao\\Documents\\Document\\F10N_MFG\\Dry Etch Target  LL Tracking report\\handsontable.full.min.js');
});




//http://10.193.196.134/
http.listen(port, function () {
	console.log(Date().toString() +'\n' + 'Server is running..\n');
	// setInterval(query, time);
	
	//Read PREVDATA.json
	json =  JSON.parse(fs.readFileSync('./PREVDATA.json', {encoding:'utf8', flag:'r'}));

});







