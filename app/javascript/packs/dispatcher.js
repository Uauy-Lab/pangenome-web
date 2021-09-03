
//Based on the code from: https://stackoverflow.com/questions/2190850/create-a-custom-callback-in-javascript#2190872
class Dispatcher{
	#events = {};
	
	dispatch(eventName, data){
		const event = this.#events[eventName]
		if(event){
			event.fire(data)
		}
	}
	
	//start listen event
	on(eventName, callback){
		let event = this.#events[eventName]
		if(!event){
			event = new DispatcherEvent(eventName)
			this.#events[eventName] = event
		}
		event.registerCallback(callback);
		console.log(this.#events);
	}
	
	//stop listen event
	off(eventName, callback){
		const event = this.#events[eventName]
		if(event){
			delete this.#events[eventName]
		}
	}
}

class DispatcherEvent{
	#eventName;
	#callbacks;
	constructor(eventName){
		this.#eventName = eventName
		this.#callbacks = []
	}
	
	registerCallback(callback){
		this.#callbacks.push(callback)
	}
	
	fire(data){
		this.#callbacks.forEach((callback=>{
			callback(data)
		}))
	}
}

window.Dispatcher = Dispatcher;
window.DispatcherEvent = DispatcherEvent;