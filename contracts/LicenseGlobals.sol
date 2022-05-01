//SPDX-License-Identifier: agpl-3.0
//-U+2654- ♔ - 0xRoyalties
pragma solidity ^0.8.0;

//ERCs
import "./common-contracts/ERC/interfaces/IERC721.sol";

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