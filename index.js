//var Web3 = require('./lib/web3');

// dont override global variable
//if (typeof window !== 'undefined' && typeof window.Web3 === 'undefined') {
//    window.Web3 = Web3;
//}

 window.addEventListener('load', function () {
			console.log(window);
			if (window.ethereum) {
				window.web3 = new Web3(window.ethereum);
				window.ethereum.enable();
				return true;
			}
			return false;
 });
function minus(event){
	event.path[1].remove();
	return false;
}
function add(){
	var field = document.getElementsByClassName("form-textarea")[0].cloneNode(true);
	console.log(field);
	field.getElementsByClassName("address-btn")[0].onclick=minus;
	field.getElementsByClassName("address-btn")[0].innerHTML="-";
	document.getElementsByClassName("form-fieldset")[0].appendChild(field);	
	return false;
}