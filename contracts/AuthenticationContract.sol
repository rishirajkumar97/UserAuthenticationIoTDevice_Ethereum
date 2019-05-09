pragma solidity ^0.5.0;
contract AuthenticationContract{
    uint256 count=0; //count for all the tokens

    address [] admins; // admins of the system
    struct Token{ // struct for the information of a given token
        bytes32 UID;
        address user;
        address dev;
    }
    Token [] public Tokens ;//token array
    mapping (address => address []) public users_devices;
    mapping (address => Token[]) public device_tokens;
    mapping (bytes32 => string )public data_mapping;
    
    
   constructor()public {
        admins.push(msg.sender); //creater of contract is the first admin
    }
    

    modifier onlyAdmin{ // for user check at modifications
        bool admin=false;
        for(uint256 i = 0; i < admins.length;i++){
            if(msg.sender==admins[i]){
                admin=true;
                break;
            }
        }
        if(admin == true)
        _;
    }

    function addAdmin(address newAdmin)public onlyAdmin{ 
                admins.push(newAdmin);
                emit AdminAdded(newAdmin,msg.sender);
            
        
        
    }
    
     
    function addUserDeviceMapping(address user, address device)public onlyAdmin{ 
        bool deviceExists=false;
        for(uint256 i = 0; i<users_devices[user].length; i++){
        if(users_devices[user][i]==device){ 
                deviceExists=true;
                break;
            }
        }

       
        if(deviceExists == false){
        users_devices[user].push(device);
        emit UserDeviceMappingAdded(user,device,msg.sender); }
        
    }
    function delAdmin (address admin) public onlyAdmin{ 
        if(admins.length<2 || admin==msg.sender)
            revert('delAdmin failed');
        else {
            uint256 i = 0;
            while(i < admins.length){
                if(admins[i]== admin){
                    delete admins[i];
                    emit AdminDeleted(admin,msg.sender);
                }
                i++;
            }
        }
    }
    function delUser(address user) public onlyAdmin{ 
        delete users_devices[user];
        emit UserDeviceAllMappingDeleted(user,msg.sender);
    }
    function requestAuthentication(address device,string memory datacode) public { 
        // Check if device exists in fog-device mapping
        bool deviceExists=false;
        for(uint256 i = 0; i<users_devices[msg.sender].length; i++){
            if(users_devices[msg.sender][i]==device){ // check the devices of a user
                deviceExists=true;
                break;
            }
        }
        if(!deviceExists){
            //trigger DeviceDoesnotExist event
            emit DeviceDoesnotExist(device,msg.sender);
        }
        else{
            emit Authenticated(msg.sender,device);
            bytes32 UID= keccak256(abi.encodePacked(device,msg.sender,block.difficulty));
            Tokens.push(Token(UID,msg.sender,device));
            data_mapping[UID]=datacode;
            emit TokenCreated(UID,msg.sender,device);
        }
    }
    function validateTokens()public {
        bool validate=false;
        
        for(uint256 i = 0 ; i<Tokens.length;i++){
            if(Tokens[i].dev == msg.sender){
                bytes32 tkid = keccak256(abi.encodePacked(msg.sender,Tokens[i].user,block.difficulty));
                
                if(Tokens[i].UID == tkid){
                    validate=true;
                    emit SucessfulyRetrievedData(data_mapping[tkid]);
                    delete Tokens[i];
                    emit ValidationSuccess( msg.sender );
                }
            }
	    else{
		revert();
	    }
        }
    }
    event AdminAdded(address newAdmin, address addingAdmin);
    event UserDeviceMappingAdded(address user, address device, address addingAdmin);
    event UserDeviceAllMappingDeleted(address user,  address deletingAdmin);
    event AdminDeleted(address newAdmin, address deletingAdmin); 
    event TokenCreated(bytes32 uid, address user, address device);
    event Authenticated(address user, address device);
    event DeviceDoesnotExist(address device, address sender);
    event ValidationSuccess(address sender);
    event SucessfulyRetrievedData(string data);

}

contract user{
function Auth(address addrAuthenticationContract,address device,string memory payload)public{
        AuthenticationContract ob1 = AuthenticationContract(addrAuthenticationContract);
        ob1.requestAuthentication(device,payload);
    }
}
contract device{
function Validate(address addrAuthenticationContract)public{
	AuthenticationContract ob2=AuthenticationContract(addrAuthenticationContract);
	ob2.validateTokens();
	}
}

