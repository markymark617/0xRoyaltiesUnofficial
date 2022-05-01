// SPDX-License-Identifier: MIT
//-U+2654- ♔ - 0xRoyalties

pragma solidity ^0.8.0;

contract AccessController {

    /////////////////////////////////////////////////
    //                   EVENTS                    //
    /////////////////////////////////////////////////
        event OwnerSet(address newOwnerAddress);
        event RemovedAdmin(address prevAdminAddress);
        event AddedAdmin(address newAdminAddress);
        
        event Paused();
        event Unpaused();

    ////////////////////////////////////////////////
    //                  VARS                      //
    ////////////////////////////////////////////////
        address public ownerAddress;
        address public adminAddress;

        bool public paused = false;
        
        //owner is included as an admin
        mapping (address => bool) isAdmin;

    ////////////////////////////////////////////////
    //                  MODIFIERS                 //
    ////////////////////////////////////////////////
        modifier onlyOwner()
        {
            require(
                msg.sender == ownerAddress,
                'AccessControl: msg.sender must be owner'
            );
            _;
        }

        modifier onlyAdmin()
        {
            require(
                isAdmin[msg.sender] == true,
                'AccessControl: msg.sender must be admin'
            );
            _;
        }

        modifier whenNotPaused()
        {
            require(
                !paused,
                'AccessControl: currently paused'
            );
            _;
        }

        modifier whenPaused
        {
            require(
                paused,
                'AccessControl: currenlty not paused'
            );
            _;
        }


    ////////////////////////////////////////////////
    //                  CORE                      //
    ////////////////////////////////////////////////
        constructor() 
        {
            ownerAddress = msg.sender;
            isAdmin[ownerAddress] = true;
        
            emit OwnerSet(ownerAddress);
            emit AddedAdmin(ownerAddress);
        }


    ////////////////////////////////////////////////
    //                  Functions                 //
    ////////////////////////////////////////////////
        function updateOwner(address _newOwnerAddress) 
            external
            onlyOwner
        {
            require(
                _newOwnerAddress != address(0x0),
                'AccessControl: invalid CEO address'
            );
            ownerAddress = _newOwnerAddress;
            emit OwnerSet(ownerAddress);
        }

        function setAdmin(address _newAdminAddress)
            public
            onlyOwner
        {
            require(
                _newAdminAddress != address(0x0),
                'AccessControl: invalid worker address'
            );
            //remove prev admin
            isAdmin[adminAddress] = false;
            emit RemovedAdmin(adminAddress);
            
            //set new admin + add to mapping
            adminAddress = _newAdminAddress;
            isAdmin[adminAddress] == true;
            emit AddedAdmin(adminAddress);
        }

        function pause()
            external
            onlyAdmin
            whenNotPaused
        {
            paused = true;
            emit Paused();
        }

        function unpause()
            external
            onlyAdmin
            whenPaused
        {
            paused = false;
            emit Unpaused();
        }

}