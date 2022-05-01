//SPDX-License-Identifier: agpl-3.0
//-U+2654- ♔ - 0xRoyalties
pragma solidity ^0.8.0;
import "./ManageLicense.sol";

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
