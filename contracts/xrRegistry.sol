//SPDX-License-Identifier: agpl-3.0
//-U+2654- ♔ - 0xRoyalties
pragma solidity ^0.8.0;
import "./common-contracts/AccessControl.sol";

contract xrRegistry is AccessController{

    /*
    * TOKEN MANAGEMENT
    *   Will be used as:
    *   tokenManager[msg.sender] to return NFT address to use to get token for licensing + minting.
    */
    mapping(address => address) tokenManager; //tokenManager[myProjectsContractAddress] => nftAddress

    //REGISTRATION MANAGEMENT
    mapping(address => bool) private isRegistered; //isRegistered[MyProjectsContractAddress] => true/false - only updated here

    address RoyaltyNFT;
    mapping(address => address) registeredContractAdminAddress; //registeredContractAdminAddress[msg.sender] = registered contract addr

    //registering without a token defaults to the generic RoyaltyNFT provided by 0xR
    function register(
        address _candidateAddress
    )
        public
        payable
    {
        //charge .025ETH registration fee
            //send to 0xR revenue sharing contract

        tokenManager[_candidateAddress] = RoyaltyNFT;

        isRegistered[_candidateAddress] = true;

        updateContractController(msg.sender, _candidateAddress);
    }

    function register(
        address _candidateAddress,
        address _tokenCandidateAddress
    )
        public
        payable
    {
        //charge .025ETH registration fee
            //send to 0xR revenue sharing contract

        registerToken(
            _candidateAddress,
            _tokenCandidateAddress    
        );

        isRegistered[_candidateAddress] = true;
        updateContractController(msg.sender, _candidateAddress);
    }

    function registerToken(
        address _candidateAddress,
        address _tokenCandidateAddress
    )
        internal
    {
                //check token meets requirements:
                    //implicitly requiring ERC165 implementation?
            //require is ERC721
            //require is ERC21 Minting
            //require is ERC721 Metadata

            tokenManager[_candidateAddress] = _tokenCandidateAddress;
    }

    function updateContractController(
        address _msgSender,
        address _registeredContract
    )
        internal
    {
        registeredContractAdminAddress[_msgSender] = _registeredContract;
    }

    function updateTokenForRegisteredContract(
        address _registeredContractAddr,
        address _newTokenAddr
    )
        external
    {
        require(registeredContractAdminAddress[msg.sender] == _registeredContractAddr);

        tokenManager[_registeredContractAddr] = _newTokenAddr;
    }


    function isSenderRegistered(address _queriedAddress)
        public
        view
        returns(bool)
    {
        return(isRegistered[_queriedAddress]);
    }

}