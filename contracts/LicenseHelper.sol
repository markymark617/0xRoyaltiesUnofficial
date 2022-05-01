//SPDX-License-Identifier: agpl-3.0
//-U+2654- ♔ - 0xRoyalties
pragma solidity ^0.8.0;
import "./common-contracts/SafeMath.sol";
import "./common-contracts/AccessControl.sol";
import "./LicenseGlobals.sol";

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