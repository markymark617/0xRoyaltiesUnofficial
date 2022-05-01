//SPDX-License-Identifier: agpl-3.0
//-U+2654- ♔ - 0xRoyalties
pragma solidity ^0.8.0;
import "../common-contracts/SafeMath.sol";
import "../common-contracts/AccessControl.sol";

//ERCs
import "../common-contracts/ERC/interfaces/IERC721.sol";


/*
 *    ADD INTERFACES!
*/

contract LicenseGlobals {

    ////////////////////////////////////////////////
    //                  VARS                      //
    ////////////////////////////////////////////////
    
        IERC721 licensedToken;
        // enum Exclusivity {EXCLUSIVE, NONEXCLUSIVE}

        struct License {
            address licenseCreator;
            uint256 tokenId;
            uint256 registeredOn;
            string governingLawJurisdiction;
        }
        
        struct GenericRoyaltyShares {
            uint256 royaltyPercentage1;
            uint256 royaltyPercentage2;
            uint256 royaltyPercentage3;
            uint256 royaltyPercentage4;
            uint256 royaltyPercentage5;
            uint256 royaltyPercentage6;
            uint256 royaltyPercentage7;
            uint256 royaltyPercentage8;
        }

        // struct RoyaltyPayment {
        //     uint256 invoiceNumber;
        //     RoyaltyType _royaltyType;
        //     uint256 amount;
        //     //uint256 paymentNum;
        // }

        mapping(uint256 => uint256) internal tokenToLicenseMapping; //tokenId => licenseId
        mapping(uint256 => License) public licenses; //licenses[licenseId]
        mapping(uint256 => GenericRoyaltyShares) public royaltySplits; //royaltySplits[licenseId]
        mapping(uint256 => bool) internal idHasBeenGenerated; //used to check uniqueness of licenseId


    ////////////////////////////////////////////////
    //                MODIFIERS                   //
    ////////////////////////////////////////////////
        modifier onlyTokenOwner(uint256 _tokenId, address _msgSender, address _tokenAddress)
        {
            require(_msgSender == IERC721(_tokenAddress).ownerOf(_tokenId),
                    "LICENSE: ONLY TOKEN OWNER"
            );

            _;
        }
        
        modifier checkLicenseExists(uint256 _licenseId)
        {
            require(idHasBeenGenerated[_licenseId] == true,
                    "LICENSING: licenseId does not exist"
            );
            
            _;
        }

    /////////////////////////////////////////////////
    //                 EVENTS                      //
    /////////////////////////////////////////////////
        event LicenseCreated(uint256 tokenId, uint256 licenseId, address licenseCreator);
        event RoyaltySplitsAdded(uint256 tokenId, uint256 licenseId,
            uint256 royaltySplit1, uint256 royaltySplit2, uint256 royaltySplit3, uint256 royaltySplit4,
            uint256 royaltySplit5, uint256 royaltySplit6, uint256 royaltySplit7, uint256 _royaltySplit8
        );
}

contract LicenseHelper is LicenseGlobals, AccessController {
    using SafeMath for uint256;
    
    ////////////////////////////////////////////////
    //              GETTER FUNCTIONS              //
    ////////////////////////////////////////////////
        function getLicenseByLicenseId(uint256 _licenseId)
            external
            view
            checkLicenseExists(_licenseId)
            returns(uint256,address,uint256,string memory)
        {
            return(
                licenses[_licenseId].tokenId,
                licenses[_licenseId].licenseCreator,
                licenses[_licenseId].registeredOn,
                licenses[_licenseId].governingLawJurisdiction
            );
        }
        
        function getSpecificRoyaltySplit(uint256 _licenseId, uint8 _royaltyType)
            internal
            view
            checkLicenseExists(_licenseId)
            returns(uint256 requestedSplit)
        {
            uint256[8] memory allSplits = [
                royaltySplits[_licenseId].royaltyPercentage1,
                royaltySplits[_licenseId].royaltyPercentage2,
                royaltySplits[_licenseId].royaltyPercentage3,
                royaltySplits[_licenseId].royaltyPercentage4,
                royaltySplits[_licenseId].royaltyPercentage5,
                royaltySplits[_licenseId].royaltyPercentage6,
                royaltySplits[_licenseId].royaltyPercentage7,
                royaltySplits[_licenseId].royaltyPercentage8
            ];

            requestedSplit = allSplits[_royaltyType];
        }

        function getTokenIdFromLicenseId(uint256 _licenseId)
            external
            view
            returns(uint256 _tokenId)
        {
            _tokenId = licenses[_licenseId].tokenId;
        }

        function getLicenseIdFromTokenId(uint256 _tokenId)
            public
            view
            returns(uint256 licenseId)
        {
            licenseId = tokenToLicenseMapping[_tokenId];
        }
        
        function hasValidLicense(uint256 _tokenId)
            external
            view
            returns(bool)
        {
            return(idHasBeenGenerated[tokenToLicenseMapping[_tokenId]]);
        }

    ////////////////////////////////////////////////
    //              HELPER FUNCTIONS              //
    ////////////////////////////////////////////////
        function generateId(
            address _senderAddr,
            uint256 _tokenId,
            uint256 _timestamp
        )
            internal
            returns(uint256 _licenseId)
        {
            _licenseId = uint256(
                keccak256(
                    abi.encodePacked(_senderAddr, _tokenId, _timestamp)
                )
            );

            checkIdUniqueness(_licenseId);
        }

        function checkIdUniqueness(uint256 _licenseId)
            internal
        {
            require(idHasBeenGenerated[_licenseId] != true,
                "LICENSING: ID has already been generated, try again"
            );

            idHasBeenGenerated[_licenseId] = true;
        }
        
        function verifyIdExists(uint256 _licenseId)
            public
            view
            returns(bool)
        {
            return(idHasBeenGenerated[_licenseId]);
        }

    ////////////////////////////////////////////////
    //             ROYALTY FUNCTIONS              //
    ////////////////////////////////////////////////
        function calcRoyaltyPayment(
            uint256 _licenseId,
            uint256 _amountAfterFees,
            uint8 _royaltyType
        )
            public
            view
            returns(uint256 pmtAmount)
        {
            pmtAmount = _amountAfterFees.mul(getSpecificRoyaltySplit(_licenseId, _royaltyType)).div(100);
        }
}

contract ManageLicense is LicenseHelper {

     ////////////////////////////////////////////////
     //        MANAGE A LICENSE FUNCTIONS         //
    ////////////////////////////////////////////////
            //ALL LICENSES DEFAULT TO US JURISDICTION
        function createTokenLicense(
            uint256 _tokenId,
            address _msgSender,
            address _tokenAddress,
            uint256 _royaltySplit1,
            uint256 _royaltySplit2,
            uint256 _royaltySplit3,
            uint256 _royaltySplit4,
            uint256 _royaltySplit5,
            uint256 _royaltySplit6,
            uint256 _royaltySplit7,
            uint256 _royaltySplit8
        )
            public
            onlyTokenOwner(_tokenId, _msgSender, _tokenAddress)
            whenNotPaused
            returns(uint256 _licenseId)
        {
            _licenseId = _createALicense(_tokenId);

            _addGenericRoyaltySplits(
                _tokenId,
                _licenseId,
                _royaltySplit1,
                _royaltySplit2,
                _royaltySplit3,
                _royaltySplit4,
                _royaltySplit5,
                _royaltySplit6,
                _royaltySplit7,
                _royaltySplit8
            );
        }

        function _addGenericRoyaltySplits(
            uint256 _tokenId,
            uint256 _licenseId,
            uint256 _royaltySplit1,
            uint256 _royaltySplit2,
            uint256 _royaltySplit3,
            uint256 _royaltySplit4,
            uint256 _royaltySplit5,
            uint256 _royaltySplit6,
            uint256 _royaltySplit7,
            uint256 _royaltySplit8
        )
            internal
        {
            _checkRoyaltySplit(_royaltySplit1);
            _checkRoyaltySplit(_royaltySplit2);
            _checkRoyaltySplit(_royaltySplit3);
            _checkRoyaltySplit(_royaltySplit4);
            _checkRoyaltySplit(_royaltySplit5);
            _checkRoyaltySplit(_royaltySplit6);
            _checkRoyaltySplit(_royaltySplit7);
            _checkRoyaltySplit(_royaltySplit8);
            
            royaltySplits[_licenseId].royaltyPercentage1 = _royaltySplit1;
            royaltySplits[_licenseId].royaltyPercentage2 = _royaltySplit2;
            royaltySplits[_licenseId].royaltyPercentage3 = _royaltySplit3;
            royaltySplits[_licenseId].royaltyPercentage4 = _royaltySplit4;
            royaltySplits[_licenseId].royaltyPercentage5 = _royaltySplit5;
            royaltySplits[_licenseId].royaltyPercentage6 = _royaltySplit6;
            royaltySplits[_licenseId].royaltyPercentage7 = _royaltySplit7;
            royaltySplits[_licenseId].royaltyPercentage8 = _royaltySplit8;

            emit RoyaltySplitsAdded(
                _tokenId,
                _licenseId,
                _royaltySplit1,
                _royaltySplit2,
                _royaltySplit3, 
                _royaltySplit4,
                _royaltySplit5,
                _royaltySplit6,
                _royaltySplit7,
                _royaltySplit8
            );
        }
        
        function _checkRoyaltySplit(uint256 _royaltySplitInput)
            internal
            pure
        {
            require(_royaltySplitInput <= 100,
                    "LICENSING: INVALID ROYALTY SPLIT");
        }

        function _createALicense(uint256 _tokenId)
            internal
            returns(uint256 _licenseId)
        {
            _licenseId = generateId(
                msg.sender,
                _tokenId,
                block.timestamp
            );
            
            licenses[_licenseId].tokenId = _tokenId;
            licenses[_licenseId].licenseCreator = msg.sender;
            licenses[_licenseId].registeredOn = block.timestamp;
            licenses[_licenseId].governingLawJurisdiction = "US";

            tokenToLicenseMapping[_tokenId] = (_licenseId);
            emit LicenseCreated(_tokenId, _licenseId, msg.sender);
        }

        //will only update current license gov juris value
        function updateGoverningJurisdiction(
            uint256 _tokenId,
            address _msgSender,
            address _tokenAddress,
            string memory _newJuridiction
        )
            public
            onlyTokenOwner(getLicenseIdFromTokenId(_tokenId), _msgSender, _tokenAddress)
            whenNotPaused
        {
            require(bytes(_newJuridiction).length != 0,
                    "LICENSE: cannot submit empty Jurisdiction"
            );

            licenses[getLicenseIdFromTokenId(_tokenId)].governingLawJurisdiction = _newJuridiction;
        }

        /*
                PLEASE UPDATE BY CREATING A NEW LICENSE WITH SAME TOKEN ID
        */
}

contract TokenLicensing is ManageLicense {

    ////////////////////////////////////////////////
    //                  CORE                      //
    ////////////////////////////////////////////////
        constructor(
            address payable licensedTokenAddr
        )
            payable 
        {
            licensedToken = IERC721(licensedTokenAddr);
        }

        receive() external payable {
            //revert to prevent accidental value lock
            revert("NO PMTS TO TOKEN LICENSING");
        }   
}




contract LicenseAgreements is AccessController{
    using SafeMath for uint256;

    ////////////////////////////////////////////////
    //                  VARS                      //
    ////////////////////////////////////////////////
        struct Agreement {
            address buyerAddr;
            uint256 licenseId;
            uint256 childTokenId;
        }

        mapping(uint256 => Agreement) public agreementDetails;              //agreementDetails[agreementId] => Agreement struct
        mapping(uint256 => mapping(uint256 => uint256)) public agreements;  //agreements[_childTokenId][_parentTokenId] => agreementId

        mapping(uint256 => uint256) public tokenLineage;                    //tokenLineage[_newlyMintedTokenId] => parentTokenId aka base token aka original token
        mapping(uint256 => uint256) public tokenGenerationNumber;           //tokenGenerationNumber[tokenId] => generation counter

        mapping(uint256 => bool) internal agreementIdHasBeenGenerated;         //agreementIdHasBeenGenerated[_agreementId] => true/false
        mapping(address => bool) public approvedAgreementMakerContracts;     //only licenseMarketplace can create agreements

        event AgreementSigned(address buyer, uint256 tokenId, uint256 agreementId);

        modifier onlyApprovedAgreementMaker(address _msgSender)
        {
            require(approvedAgreementMakerContracts[_msgSender] == true,
                    "AGREEMENTS: ONLY APPROVED CONTRACTS CAN STORE DATA"
            );

            _;
        }

    ////////////////////////////////////////////////
    //           ADMIN SETUP FUNCTION             //
    ////////////////////////////////////////////////
        function approveAgreementMaker(address _approvedAgreementMaker)
            external
            onlyAdmin
        {
            approvedAgreementMakerContracts[_approvedAgreementMaker] = true;
        }

    ////////////////////////////////////////////////
    //                  CORE                      //
    ////////////////////////////////////////////////
        function signAgreement(address _buyerAddr, uint256 _licenseId, uint256 _tokenId, uint256 _childTokenId, uint256 _timestamp)
            public
            onlyApprovedAgreementMaker(msg.sender)
            returns(uint256 _agreementId)
        {
            _agreementId =  generateAgreementId(
                                _buyerAddr,
                                _tokenId,
                                _childTokenId,
                                _licenseId,
                                _timestamp
                            );
            
            agreements[_childTokenId][_tokenId] = _agreementId;
            agreementDetails[_agreementId].buyerAddr = _buyerAddr;
            agreementDetails[_agreementId].licenseId = _licenseId;
            
            //CHILD TOKEN DETAILS
            tokenLineage[_childTokenId] = _tokenId;
            agreementDetails[_agreementId].childTokenId = _childTokenId;
            
            _updateTokenGeneration(_childTokenId, _tokenId);
            
            emit AgreementSigned(_buyerAddr, _tokenId, _agreementId);
        }

        function _updateTokenGeneration(uint256 _childTokenId, uint256 _parentTokenId)
            internal
        {
            require(tokenGenerationNumber[_parentTokenId] < 10,
                    "AGREEMENTS: CANNOT HAVE > 10 CHILDREN"
            );
            
            tokenGenerationNumber[_childTokenId] = tokenGenerationNumber[_parentTokenId].add(1);
        }

    ////////////////////////////////////////////////
    //              GETTER FUNCTIONS              //
    ////////////////////////////////////////////////
        function getAgreementId(uint256 _childTokenId)
            external
            view
            returns(uint256 agreementId)
        {
            agreementId = agreements[_childTokenId][tokenLineage[_childTokenId]];
        }

        function getChildTokenId(uint256 _agreementId)
            external
            view
            returns(uint256)
        {
            return(agreementDetails[_agreementId].childTokenId);
        }

        function getLicenseIdByAgreementId(uint256 _agreementId)
            external
            view
            returns(uint256)
        {
            return(agreementDetails[_agreementId].licenseId);
        }        

        function getAgreementBuyerAddress(uint256 _agreementId)
            external
            view
            returns(address)
        {
            return(agreementDetails[_agreementId].buyerAddr);
        }

    ////////////////////////////////////////////////
    //              HELPER FUNCTIONS              //
    ////////////////////////////////////////////////
        function generateAgreementId(
            address _senderAddr,
            uint256 _tokenId,
            uint256 _childTokenId,
            uint256 _licenseId,
            uint256 _timestamp
        )
            internal
            returns(uint256 agreementId)
        {
            agreementId = uint256(
                keccak256(
                    abi.encodePacked(_senderAddr, _tokenId, _childTokenId, _licenseId, _timestamp)
                )
            );

            checkIdUniqueness(agreementId);
        }

        function checkIdUniqueness(uint256 agreementId)
            internal
        {
            require(agreementIdHasBeenGenerated[agreementId] != true,
                   "AGREEMENTS: agreementId has already been generated, try again"
            );
            
            require(agreementId != 0,
                    "AGREEMENTS: agreementId CANNOT BE 0"
            );

            agreementIdHasBeenGenerated[agreementId] = true;
        }
}



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
