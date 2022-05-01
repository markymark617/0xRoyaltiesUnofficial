//SPDX-License-Identifier: agpl-3.0
//-U+2654- ♔ - 0xRoyalties
pragma solidity ^0.8.0;
import "./common-contracts/SafeMath.sol";
import "./common-contracts/AccessControl.sol";

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
