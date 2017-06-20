pragma solidity ^0.4.6;
contract helloworld{
    
	string public name = "helloworld...";
	
	function changeName(string _newName){
	    
		name = _newName;
		
	}
	
}