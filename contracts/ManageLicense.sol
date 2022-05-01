//SPDX-License-Identifier: agpl-3.0
//-U+2654- ♔ - 0xRoyalties
pragma solidity ^0.8.0;
import "./LicenseHelper.sol";

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
